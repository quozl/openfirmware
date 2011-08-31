0 0  " d42a0800"  " /" begin-package
" audio" name
my-space h# 800 reg

0 value sspa-base  \ E.g. h# 2a.0c00 +io
0 value adma-base  \ E.g. h# 2a.0800 +io
: sspa!  ( n offset -- )  sspa-base + rl!  ;  \ Write a register in SSPA1
: sspa@  ( offset -- n )  sspa-base + rl@  ;  \ Read a register in SSPA1
: adma!  ( n offset -- )  adma-base + rl!  ;
: adma@  ( offset -- n )  adma-base + rl@  ;

: audio-clock-on  ( -- )
   h# 600 h# 28.290c io!  d# 10 us  \ Enable
   h# 610 h# 28.290c io!  d# 10 us  \ Release reset
   h# 710 h# 28.290c io!  d# 10 us  \ Enable
   h# 712 h# 28.290c io!  d# 10 us  \ Release reset

[ifdef] 24mhz
   \  * 10 / 27 gives about 147.456
   \ The M/N divisor gets 199.33 MHz (Figure 283 - clock tree - in Datasheet)
   \ But the M/N divisors always have an implicit /2 (section 7.3.7 in datasheet),
   \ so the input frequency is 99.67 with respect to NOM (sic) and DENOM.
   \ we want 24.576 MHz SYSCLK.  99.67 * 18 / 73 = 24.575 so 50 ppm error.
   d# 18 d# 15 lshift d# 73 or h# d000.0000 or  h# 050040 io!
[else]
   \  * 10 / 27 gives about 147.456
   \ The M/N divisor gets 199.33 MHz (Figure 283 - clock tree - in Datasheet)
   \ But the M/N divisors always have an implicit /2 (section 7.3.7 in datasheet),
   \ so the input frequency is 99.67 with respect to NOM (sic) and DENOM.
   \ we want 12.288 MHz SYSCLK.  99.67 * 9 / 73 = 12.2876 so 50 ppm error.
   d# 9 d# 15 lshift d# 73 or h# d000.0000 or  h# 050040 io!
[then]

   h# 05.0024 io@  h# 20 or  h# 05.0024 io!  \ Enable 12S clock out to SSPA1

   h# 10800 h# 38 sspa!
  
[ifdef] 24mhz
   \ Bits 14:9 set the divisor from SYSCLK to BITCLK.  The setting below
   \ is d# 16, which gives BITCLK = 3.072 MHz.  That's 32x 48000, just enough
   \ for two (stereo) 16-bit samples.
   h#  2183 h# 34 sspa!  \ Divisor 16 - BITCLK = 3.072 Mhz
[else]
   h#  1183 h# 34 sspa!  \ Divisor  8 - BITCLK = 3.072 Mhz
[then]
;

: reset-rx  ( -- )  h# 8000.0002 h# 0c sspa!  ;

: active-low-rx-fs  ( -- ) 
   h# 0c sspa@  h# 8001.0000 or  h# 0c sspa!
;
: active-high-rx-fs  ( -- ) 
   h# 0c sspa@  h# 10000 invert and  h# 8000.0000 or  h# 0c sspa!
;
: setup-sspa-rx  ( -- )
   reset-rx

   h# 8000.0000  \ Dual phase (stereo)
   0 d# 24 lshift or  \ 1 word in phase 2
   2 d# 21 lshift or  \ 16 bit word in phase 2
   0 d# 19 lshift or  \ 0 bit delay
   2 d# 16 lshift or  \ 16-bit audio sample in phase 2
   0 d#  8 lshift or  \ 1 word in phase 1
   2 d#  5 lshift or  \ 16 bit word in phase 1
   0 d#  3 lshift or  \ Left justified data
   2 d#  0 lshift or  \ 16-bit audio sample in phase 1
   h# 08 sspa!   \ Receive control register

   h# 8000.0000          \ Enable writes
   d# 15 d# 20 lshift or \ Frame sync width
\ We choose the master/slave configuration later, in enable-sspa-rx
   0     d# 18 lshift or \ Internal clock - master configuration
   0     d# 17 lshift or \ Sample on rising edge of clock
   1     d# 16 lshift or \ Active low frame sync (I2S standard)
   d# 31 d#  4 lshift or \ Frame sync period
   1     d#  2 lshift or \ Flush the FIFO
   h# 0c sspa!

   h# 10 h# 10 sspa!   \ Rx FIFO limit
;
: master-rx  ( -- )  h# 0c sspa@  h# 8004.0001 or  h# 0c sspa!  ;  \ Master, on
: slave-rx  ( -- )  h# 0c sspa@  h# 8000.0001 or  h# 0c sspa!  ;  \ Slave, on
: disable-sspa-rx  ( -- )  h# 0c sspa@  h# 8000.0004 or  h# 4.0001 invert and    h# 0c sspa!  ;

: reset-tx  ( -- )  h# 8000.0002 h# 8c sspa!  ;

: active-low-tx-fs  ( -- )
   h# 8c sspa@  h# 8001.0000 or  h# 8c sspa!
;
: active-high-tx-fs  ( -- )
   h# 8c sspa@  h# 10000 and  h# 8000.0000 or  h# 8c sspa!
;
: setup-sspa-tx  ( -- )
   reset-tx

   h# 8000.0000  \ Dual phase (stereo)
   0 d# 24 lshift or  \ 1 word in phase 2
   2 d# 21 lshift or  \ 16 bit word in phase 2
   0 d# 19 lshift or  \ 0 bit delay
   2 d# 16 lshift or  \ 16-bit audio sample in phase 2
   1 d# 15 lshift or  \ Transmit last sample when FIFO empty
   0 d#  8 lshift or  \ 1 word in phase 1
   2 d#  5 lshift or  \ 16 bit word in phase 1
   0 d#  3 lshift or  \ Left justified data
   2 d#  0 lshift or  \ 16-bit audio sample in phase 1
   h# 88 sspa!   \ Transmit control register

   h# 8000.0000          \ Enable writes
   d# 15 d# 20 lshift or \ Frame sync width
\ We choose the master/slave configuration later, in master-tx
   0     d# 18 lshift or \ External clock - slave configuration (Rx is master)
   0     d# 17 lshift or \ Sample on rising edge of clock

\ Empirically, this needs to be backwards from what we think it should be
   0     d# 16 lshift or \ Active high frame sync (should be active low, but that gives backwards results)

   d# 31 d#  4 lshift or \ Frame sync period
   1     d#  2 lshift or \ Flush the FIFO
   h# 8c sspa!

   h# 10 h# 90 sspa!  \ Tx FIFO limit
;
: master-tx  ( -- )  h# 8c sspa@  h# 8004.0001 or  h# 8c sspa!  ;  \ Master, on
: slave-tx  ( -- )  h# 8c sspa@  h# 8000.0001 or  h# 8c sspa!  ;  \ Slave, on
: disable-sspa-tx  ( -- )  h# 8c sspa@  h# 8000.0004 or  h# 4.0001 invert and  h# 8c sspa!  ;

h# e000.0000 constant audio-sram
h# fc0 constant /audio-buf
audio-sram           constant out-bufs
audio-sram h# 1f80 + constant out-desc
audio-sram h# 2000 + constant in-bufs
audio-sram h# 3f80 + constant in-desc

\ Descriptor format:
\ Byte count
\ Source
\ Destination
\ link

0 value my-out-desc  \ out-desc or out-desc h# 20 +
0 value out-adr
0 value out-len
0 value my-in-desc   \ in-desc or in-desc h# 20 +
0 value in-adr
0 value in-len
: set-descriptor   ( next dest source length adr -- )
   >r  r@ l!  r@ la1+ l!  r@ 2 la+ l!  r> 3 la+ l!
;
: make-out-ring  ( -- )
   out-desc h# 10 +  sspa-base h# 80 +  out-bufs               /audio-buf   out-desc          set-descriptor
   out-desc          sspa-base h# 80 +  out-bufs /audio-buf +  /audio-buf   out-desc  h# 10 + set-descriptor
   out-desc  h# 30 adma!   \ Link to first descriptor
   out-desc to my-out-desc
;
: start-out-ring  ( -- )
   1 h# 80 adma!           \ Enable DMA completion interrupts
   h# 0081.3020   h# 40 adma! \ 16 bits, pack, fetch next, enable, chain, hold dest, inc src
;
: stop-out-ring  ( -- )  h# 100000 h# 40 adma!  ;

: make-in-ring  ( -- )
   in-desc h# 10 +  in-bufs               sspa-base   /audio-buf   in-desc          set-descriptor
   in-desc          in-bufs /audio-buf +  sspa-base   /audio-buf   in-desc  h# 10 + set-descriptor
   in-desc  h# 34 adma!   \ Link to first descriptor
   in-desc to my-in-desc
;
: start-in-ring  ( -- )
   1 h# 84 adma!           \ Enable DMA completion interrupts
\   h# 0081.3008   h# 44 adma! \ 16 bits, pack, fetch next, enable, chain, inc dest, hold src
   h# 00a1.31c8   h# 44 adma! \ 16 bits, pack, fetch next, enable, chain, burst32, inc dest, hold src
;

: copy-out  ( -- )
   my-out-desc >r                        ( r: desc )
   out-len /audio-buf min                ( this-len r: desc )
   dup r@ l!                             ( this-len r: desc )
   out-adr  r@ la1+ l@  third  move      ( this-len r: desc )
   out-adr  over +  to out-adr           ( this-len r: desc )
   out-len  swap -  to out-len           ( r: desc )
   out-len  if
      r> 3 la+ l@  to my-out-desc
   else
      0 r> 3 la+ l!  \ When there is no more data, terminate the list
   then
;

: copy-in  ( -- )
   in-len /audio-buf min                       ( this-len )
   my-in-desc 2 la+ l@  in-adr  third  move    ( this-len )
   in-adr  over +  to in-adr                   ( this-len )
   in-len  over -  to in-len                   ( this-len )
   drop                                        ( )
   my-in-desc 3 la+ l@ to my-in-desc
;

[ifdef] cl2-a1
: choose-smbus  ( -- )  h# 30 1 set-twsi-target  ;
[else]
: choose-smbus  ( -- )  h# 34 1 set-twsi-target  ;
[then]

\ Reset is unconnected on current boards
\ : audio-reset  ( -- )  8 gpio-clr  ;
\ : audio-unreset  ( -- )  8 gpio-set  ;
: codec@  ( reg# -- w )  choose-smbus  1 2 twsi-get  swap bwjoin  ;
: codec!  ( w reg# -- )  choose-smbus  >r wbsplit r> 3 twsi-out  ;
: codec-i@  ( index# -- w )  h# 6a codec!  h# 6c codec@  ;
: codec-i!  ( w index# -- )  h# 6a codec!  h# 6c codec!  ;

: codec-set  ( bitmask reg# -- )  tuck codec@  or  swap codec!  ;
: codec-clr  ( bitmask reg# -- )  tuck codec@  swap invert and  swap codec!  ;
: codec-field  ( value-mask field-mask reg# -- )
   >r r@ codec@      ( value-mask field-mask value r: reg# )
   swap invert and   ( value-mask masked-value r: reg# )
   or                ( final-value  r: reg# )
   r> codec!         ( )
;

[ifdef] cl2-a1
fload ${BP}/cpu/arm/olpc/1.75/alc5624.fth  \ Realtek ALC5624 CODEC
[else]
d# 97 constant headphone-jack
d# 96 constant external-mic
: pin-sense?  ( gpio# -- flag )  gpio-pin@  ;
: headphones-inserted?  ( -- flag )  headphone-jack pin-sense?  ;
: microphone-inserted?  ( -- flag )  external-mic pin-sense?  ;

fload ${BP}/cpu/arm/olpc/1.75/alc5631.fth  \ Realtek ALC5631Q CODEC
[then]
   
d# 48000 value sample-rate

\ Longest time to wait for a buffer event - a little more
\ than the time it takes to output /audio-buf samples
\ at the current sample rate.
0 value buf-timeout

: set-ctlr-sample-rate  ( rate -- )
   case
      d#  8000 of  d# 48  d# 129  endof
      d# 16000 of  d# 24  d#  65  endof
      d# 32000 of  d# 12  d#  33  endof
      d# 48000 of  d#  8  d#  23  endof
      ( default )  true abort" Unsupported audio sample rate"
   endcase   ( sspareg34val timeout )
   to buf-timeout
   9 lshift h# 183 or  h# 34 sspa!
;

\ I think we don't need to use the audio PLL, because we are using the PMUM M/N divider
\ DIV_MCL 0  DIV_FBCLK 01 FRACT 00da1
\ POSTDIV 1  DIV_OCLK_MODULO 000 (NA)  DIV_OCLK_PATTERN 00 (NA)  
\ : setup-audio-pll  ( -- )
\    h# 000d.a189 h# 38 sspa!
\    h# 0000.0000 h# 3c sspa!
\ ;

: dma-alloc  ( len -- adr )  " dma-alloc" $call-parent  ;
: dma-free  ( adr len -- )  " dma-free" $call-parent  ;

: open-in   ( -- )  ;
: close-in  ( -- )  ;
: open-out  ( -- )  ;
: close-out ( -- )  ;

: wait-out  ( -- )
   buf-timeout  0  do   
      1 ms  h# a0 adma@ 1 and  ?leave
   loop
   0 h# a0 adma!
;

defer playback-alarm
0 value alarmed?

: install-playback-alarm     ( -- )
   true to alarmed?  ['] playback-alarm d# 3 alarm
;
: uninstall-playback-alarm   ( -- )
   alarmed?  if
      ['] playback-alarm d#  0 alarm
      false to alarmed?
   then
;

false value playing?

: stop-out  ( -- )
   disable-sspa-tx
   reset-tx
   stop-out-ring
   uninstall-playback-alarm
   false to playing?
;

: out-ready?  ( -- flag )
   h# a0 adma@ 1 and  0<>
   dup  if  0 h# a0 adma!  then
;
: out-dma-done?  ( -- flag )  h# 40 adma@  h# 4000 and  0=  ;

: ?end-playing  ( -- )
   out-ready?  if
      out-len  if  copy-out  then
      out-dma-done?  if  stop-out  then
   then
;

: set-out-in-mic  ( -- )
   h# 80 h# 12 codec!   \ Mute right channel
   h# 00 h# 16 codec!   \ Full digital gain
   h# 6688 h# 22 codec!   \ No mic boost, low bias
;

: playback-continue-alarm  ( -- )
   playing?  if
      ?end-playing
   else
      \ If playback has already stopped as a result of
      \ someone else having waited for completion, we
      \ just uninstall ourself.
      uninstall-playback-alarm
   then
;
' playback-continue-alarm to playback-alarm

: start-audio-out  ( adr len -- )
   to out-len            ( adr )
   to out-adr            ( )
   setup-sspa-tx         ( )
   make-out-ring
   copy-out
   out-len  if  copy-out  then  \ Prefill the second buffer
   start-out-ring
   master-tx
   dac-on
   install-playback-alarm
   true to playing?
;

: audio-out  ( adr len -- actual )  tuck start-audio-out  ;

: stop-sound  ( -- )
   lock[
   playing?  if  stop-out  then
   ]unlock
;

0 value time-limit
: set-time-limit  ( ms -- )   get-msecs  +  to time-limit  ;
: 1sec-time-limit  ( -- )  d# 1000 set-time-limit  ;
: ?timeout  ( -- )
   get-msecs  time-limit -  0>  if
      ." Audio device timeout!" cr
      abort
   then
;
: wait-out-done  ( -- )
   d# 20,000 set-time-limit  begin  ?timeout  playing? 0=  until
;
: write-done  ( -- )  wait-out-done  stop-out  ;

: write  ( adr len -- actual )  open-out audio-out  ;

: in-ready?  ( -- flag )
   h# a4 adma@ 1 and  0<>
   dup  if  0 h# a4 adma!  then
;
: wait-in  ( -- )
   buf-timeout  0  do
      1 ms  in-ready?  ?leave
   loop
;

: audio-in  ( adr len -- actual )
   tuck  to in-len  to in-adr  ( actual )
   setup-sspa-rx               ( actual )
   make-in-ring                ( actual )
   start-in-ring               ( actual )
   master-rx                   ( actual )
   adc-on                      ( actual )
   begin  in-len  while        ( actual )
      wait-in                  ( actual )
      copy-in                  ( actual )
   repeat                      ( actual )
   disable-sspa-rx             ( actual )
   reset-rx                    ( actual )
;
: read  ( adr len -- actual )  open-in audio-in  ;

0 value mono?
0 value in-adr0
0 value in-len0
: collapse-in  ( -- )
   in-len0  0  ?do
      in-adr0 i la+ w@   in-adr0 i wa+ w!
   loop
;
: out-in  ( out-adr out-len in-adr in-len -- )
   to in-len0  to in-adr0      ( out-adr out-len )
   to out-len  to out-adr      ( )

   in-adr0 to in-adr           ( )
   in-len0  mono?  if  2*  then  to in-len     

   audio-clock-on              ( ) \ This will mess up any frequency settings

   setup-sspa-tx               ( )
   setup-sspa-rx               ( )
   active-high-rx-fs           ( )

   make-in-ring                ( )
   make-out-ring               ( )
   copy-out                    ( )  \ Prefill the first Tx buffer
   out-len  if  copy-out  then ( )  \ Prefill the second Tx buffer

   start-in-ring               ( )
   start-out-ring              ( )

   master-rx                   ( )  \ Now the clock is on
   slave-tx                    ( )

   adc-on                      ( )
   dac-on                      ( )

   true to playing?

   begin  in-len playing? or  while  ( )
      in-ready?  if  copy-in  then   ( )
      playing?  if  ?end-playing  then   ( )
   repeat                      ( )
   disable-sspa-rx             ( )
   disable-sspa-tx             ( )

   reset-rx
   reset-tx

   dac-off  adc-off            ( )

   mono?  if  collapse-in  then  ( )
;

0 [if]  \ Interactive test words for out-in
h# 20000 constant tlen
: xb  load-base 1meg +  ;
: ob  load-base   ;
: sb  load-base 1meg 2* +  ;
: px  xb tlen write drop ;
: po  ob tlen write drop ;
: ps  sb tlen write drop ;
: shiftit  xb 1+  sb  tlen move  ;
: oi  ob tlen xb tlen out-in  ;
[then]

: wait-sound  ( -- )
   lock[
   begin  playing?  while   d# 10 ms  ?end-playing  repeat
   ]unlock
;

0 [if]
\ Notes:
\ Page 1504 - what does "RTC (and WTC) for sync fifo" mean?
\ Page 1508 - SSPA_AUD_PLL_CTRL1 bit 17 refers to "zsp_clk_gen" <- undefined term appears nowhere else in either document
\ Page 1501 - do the Frame-Sync Width and Frame-Sync Active fields matter in slave mode, or are they only relevant in master mode???  If they matter in slave mode, what do they control, considering that the external code is driving FSYNC and thus controls its width.
\ Page 1506 - For I2S_RXDATA, the connection from the pin driver to RX_DATA_IN(18) is shown going to the (disabled) output driver.  I think it should come from the input (left-pointing triangle) instead.
\ Page 1506 - The "18" and "19" notation is unexplained and unclear.  I sort of think that 18 means the Rx direction and 19 the Tx direction.  If so, and the diagram is correct, then you cannot drive FSYNC from the Tx direction.  If that is the case, it ought to be explained elsewhere too.  In particular, if you can't drive FSYNC from Tx, what are the FWID and FPER fields in SSPA_TX_SP_CTRL for?
\ Page 1506 - The diagram shows the ENB for the I2S_BITCLK driver coming from M/S_19 in SSPA.  But the Master/Slave bits in both SSPA_TX_SP_CTRL and SSPA_RX_SP_CTRL have no effect on whether BITCLK is driven.  It seems to be controlled by bit 8 in SSPA_AUD_CTRL0 (which is misnamed as enabling the SYSCLK Divider, not the BITCLK output.  Which makes me wonder what enables the I2S_FSYNC signal, which is shown as being enabled along with I2S_BITCLK.  But I can't seem to get FSYNC to come out.
\ What is the relationship between Rx master mode and Tx master mode with regards to whether FSYNC is driven?  Empirically, if I turn on and enable the Rx portion, FSYNC comes on, but if I then turn on the Tx portion, FSYNC turns off until I enable the Tx portion.  After that, Tx seems to control FSYNC and nothing I do seems to let Rx control it.
\ Page 1502 - S_RST is listed as W, but empirically it is readable.  When you write 1 to it, the 1 sticks and you have to write 0 again.  It's unclear which of the registers it really resets.  It doesn't reset the register it is in.
\ Page 1498 - The data transmit register is listed as RO.  How can a transmit register be RO????
[then]

: set-sample-rate  ( rate -- )
   dup to sample-rate
   dup set-ctlr-sample-rate
   set-codec-sample-rate
;
: set-get-sample-rate  ( rate -- actual-rate )
   drop d# 48000             ( actual-rate )
   dup set-sample-rate       ( actual-rate )
;

\ This is called from "record" in "mic-test" in "selftest"
: set-record-gain  ( db -- )
   \ translate value from ac97 selftest code into our default value
   dup h# 808  =  if          ( db )
      drop default-adc-gain   ( db' )
      d# 40 set-mic-gain      ( db )
   then                       ( db )
   set-adc-gain
;

: stereo  false to mono?  ;
: mono  true to mono?  ;

: init-codec  ( -- )
   codec-on
   set-default-gains
   d# 48000 set-sample-rate
;
0 value open-count
: open  ( -- flag )
   open-count 0=  if
      my-space h# 800 " map-in" $call-parent to adma-base
      adma-base h# 400 + to sspa-base
      audio-clock-on  init-codec
   then
   open-count 1+ to open-count
   true
;
: close  ( -- )
   open-count 1 =  if
      uninstall-playback-alarm  codec-off  ( audio-clock-off )
      adma-base h# 800 " map-out" $call-parent
      0 to adma-base  0 to sspa-base
   then
   open-count 1- 0 max to open-count
;

fload ${BP}/forth/lib/isin.fth
fload ${BP}/forth/lib/tones.fth
fload ${BP}/dev/geode/ac97/selftest.fth

false value force-internal-mic?  \ Can't be implemented on XO-1.75
2 value #channels

\ Unless you do the audio-clock-on, the L/R phase is often wrong
: input-test-settings  ( -- )  audio-clock-on  ;
: output-test-settings  ( -- )  ;

d#  -1 constant case-test-volume
d# -13 constant fixture-test-volume
d# -22 constant loopback-test-volume

create analysis-parameters
d# -23 ,   \  0 Sample delay
d#  40 ,   \  1 #fixture
d#  50 ,   \  2 fixture-threshold
d#  60 ,   \  3 case-start-left
d#  83 ,   \  4 case-start-right
d# 400 ,   \  5 case-start-quiet
d#  60 ,   \  6 #case-left
d#  30 ,   \  7 #case-right
d#  25 ,   \  8 case-threshold-left
d#  25 ,   \  9 case-threshold-right
d#  20 ,   \ 10 #loopback
d#  70 ,   \ 11 loopback-threshold

fload ${BP}/dev/hdaudio/test.fth


end-package

\ LICENSE_BEGIN
\ Copyright (c) 2011 FirmWorks
\ 
\ Permission is hereby granted, free of charge, to any person obtaining
\ a copy of this software and associated documentation files (the
\ "Software"), to deal in the Software without restriction, including
\ without limitation the rights to use, copy, modify, merge, publish,
\ distribute, sublicense, and/or sell copies of the Software, and to
\ permit persons to whom the Software is furnished to do so, subject to
\ the following conditions:
\ 
\ The above copyright notice and this permission notice shall be
\ included in all copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
\ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
\ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
\ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
\ LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
\ OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
\ WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
\
\ LICENSE_END
