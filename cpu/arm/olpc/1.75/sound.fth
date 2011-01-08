0 0  " d42a0c00"  " /" begin-package
" audio" name
my-space h# 40 reg

h# d42a.0c00 constant sspa-base
h# d42a.0800 constant adma-base
: sspa!  ( n offset -- )  sspa-base + l!  ;  \ Write a register in SSPA1
: sspa@  ( offset -- n )  sspa-base + l@  ;  \ Read a register in SSPA1
: adma!  ( n offset -- )  adma-base + l!  ;
: adma@  ( offset -- n )  adma-base + l@  ;

: audio-clock-on  ( -- )
   h# 600 h# d428.290c l!  d# 10 us  \ Enable
   h# 610 h# d428.290c l!  d# 10 us  \ Release reset
   h# 710 h# d428.290c l!  d# 10 us  \ Enable
   h# 712 h# d428.290c l!  d# 10 us  \ Release reset


[ifdef] 24mhz
   \  * 10 / 27 gives about 147.456
   \ The M/N divisor gets 199.33 MHz (Figure 283 - clock tree - in Datasheet)
   \ But the M/N divisors always have an implicit /2 (section 7.3.7 in datasheet),
   \ so the input frequency is 99.67 with respect to NOM (sic) and DENOM.
   \ we want 24.576 MHz SYSCLK.  99.67 * 18 / 73 = 24.575 so 50 ppm error.
   d# 18 d# 15 lshift d# 73 or h# d000.0000 or  h# d4050040 l!
[else]
   \  * 10 / 27 gives about 147.456
   \ The M/N divisor gets 199.33 MHz (Figure 283 - clock tree - in Datasheet)
   \ But the M/N divisors always have an implicit /2 (section 7.3.7 in datasheet),
   \ so the input frequency is 99.67 with respect to NOM (sic) and DENOM.
   \ we want 12.288 MHz SYSCLK.  99.67 * 9 / 73 = 12.2876 so 50 ppm error.
   d# 9 d# 15 lshift d# 73 or h# d000.0000 or  h# d4050040 l!
[then]

   h# d405.0024 l@  h# 20 or  h# d405.0024 l!  \ Enable 12S clock out to SSPA1

   h# 10800 38 sspa!
  
[ifdef] 24mhz
   \ Bits 14:9 set the divisor from SYSCLK to BITCLK.  The setting below
   \ is d# 16, which gives BITCLK = 3.072 MHz.  That's 32x 48000, just enough
   \ for two (stereo) 16-bit samples.
   h#  2183 h# 34 sspa!  \ Divisor 16 - BITCLK = 3.072 Mhz
[else]
   h#  1183 h# 34 sspa!  \ Divisor  8 - BITCLK = 3.072 Mhz
[then]
;

: setup-sspa-rx  ( -- )
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
   1     d# 18 lshift or \ Internal clock - master configuration
   0     d# 17 lshift or \ Sample on rising edge of clock
   0     d# 16 lshift or \ Active high frame sync
   d# 31 d#  4 lshift or \ Frame sync period
   1     d#  2 lshift or \ Flush the FIFO
   h# 0c sspa!

   h# 10 h# 10 sspa!   \ Rx FIFO limit
;
: enable-sspa-rx  ( -- )  h# 0c sspa@  h# 8004.0001 or  h# 0c sspa!  ;
: disable-sspa-rx  ( -- )  h# 0c sspa@  h# 8000.0040 or  h# 4.0001 invert and    h# 0c sspa!  ;


: setup-sspa-tx  ( -- )
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
   1     d# 18 lshift or \ Internal clock - master configuration
\  0     d# 18 lshift or \ External clock - slave configuration (Rx is master)
   0     d# 17 lshift or \ Sample on rising edge of clock
   0     d# 16 lshift or \ Active high frame sync
   d# 31 d#  4 lshift or \ Frame sync period
   1     d#  2 lshift or \ Flush the FIFO
   h# 8c sspa!

   h# 10 h# 90 sspa!  \ Tx FIFO limit
;
: enable-sspa-tx  ( -- )  h# 8c sspa@  h# 8004.0001 or  h# 8c sspa!  ;
: disable-sspa-tx  ( -- )  h# 8c sspa@  h# 8000.0040 or  h# 4.0001 invert and  h# 8c sspa!  ;

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
   my-in-desc 2 la+ l@  in-adr  third  move       ( this-len )
   in-adr  over +  to in-adr                   ( this-len )
   in-len  over -  to in-len                   ( this-len )
   drop                                        ( )
   my-in-desc 3 la+ l@ to my-in-desc
;

\ Reset is unconnected on current boards
\ : audio-reset  ( -- )  8 gpio-clr  ;
\ : audio-unreset  ( -- )  8 gpio-set  ;
: codec@  ( reg# -- w )  1 2 twsi-get  swap bwjoin  ;
: codec!  ( w reg# -- )  >r wbsplit r> 3 twsi-write  ;
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

: open-in   ( -- )  setup-sspa-rx  ;
: close-in  ( -- )  ;
: open-out  ( -- )  setup-sspa-tx  ;
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
   stop-out-ring
   uninstall-playback-alarm
   false to playing?
;

: ?end-playing  ( -- )
   h# a0 adma@ 1 and  0=  if  exit  then
   0 h# a0 adma!
   out-len  if  copy-out  then
   h# 40 adma@  h# 4000 and  0=  if
      stop-out
   then
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
   make-out-ring
   copy-out
   start-out-ring
   enable-sspa-tx
   out-len  if  copy-out  then  \ Prefill the second buffer
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

: wait-in  ( -- )
   buf-timeout  0  do
      1 ms  h# a4 adma@ 1 and  ?leave
   loop
   0 h# a4 adma!
;
: audio-in  ( adr len -- actual )
   tuck  to in-len  to in-adr  ( actual )
   make-in-ring                ( actual )
   enable-sspa-rx              ( actual )
   start-in-ring               ( actual )
   begin  in-len  while        ( actual )
      wait-in                  ( actual )
      copy-in                  ( actual )
   repeat                      ( actual )
   disable-sspa-rx             ( actual )
;
: read  ( adr len -- actual )  open-in audio-in  ;

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

[ifdef] cl2-a1
: init-smbus  ( -- )  h# 30 1 set-twsi-target  ;

fload ${BP}/cpu/arm/olpc/1.75/alc5624.fth  \ Realtek ALC5624 CODEC
[else]
: init-smbus  ( -- )  h# 34 1 set-twsi-target  ;

: headphones-inserted?  ( -- flag )  d# 97 gpio-pin@  ;
: microphone-inserted?  ( -- flag )  d# 96 gpio-pin@  ;

fload ${BP}/cpu/arm/olpc/1.75/alc5631.fth  \ Realtek ALC5631Q CODEC
[then]
   
: set-sample-rate  ( rate -- )
   dup to sample-rate
   dup set-ctlr-sample-rate
   set-codec-sample-rate
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

: stereo  ;
: mono  ;

: init-codec  ( -- )
   init-smbus
   codec-on
   set-default-gains
   d# 48000 set-sample-rate
;
0 value open-count
: open  ( -- flag )
   open-count 0=  if  audio-clock-on  init-codec  then
   open-count 1+ to open-count
   true
;
: close  ( -- )
   open-count 1 =  if
      uninstall-playback-alarm  codec-off  ( audio-clock-off )
   then
   open-count 1- 0 max to open-count
;

fload ${BP}/forth/lib/isin.fth
fload ${BP}/forth/lib/tones.fth
fload ${BP}/dev/geode/ac97/selftest.fth

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