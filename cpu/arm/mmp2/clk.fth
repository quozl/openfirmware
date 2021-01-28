\ See license at end of file
purpose: MMP2 clock management

\ From include/dt-bindings/clock/marvell,mmp2.h
d#  27 constant mmp2-usb-pll-clk#
d#  60 constant mmp2-twsi0-clk#
d#  61 constant mmp2-twsi1-clk#
d#  62 constant mmp2-twsi2-clk#
d#  63 constant mmp2-twsi3-clk#
d#  64 constant mmp2-twsi4-clk#
d#  65 constant mmp2-twsi5-clk#
d#  66 constant mmp2-gpio-clk#
d#  68 constant mmp2-rtc-clk#
d#  73 constant mmp2-uart0-clk#
d#  74 constant mmp2-uart1-clk#
d#  75 constant mmp2-uart2-clk#
d#  76 constant mmp2-uart3-clk#
d#  77 constant mmp2-ssp0-clk#
d#  78 constant mmp2-ssp1-clk#
d#  79 constant mmp2-ssp2-clk#
d#  80 constant mmp2-ssp3-clk#
d#  81 constant mmp2-timer-clk#
d#  82 constant mmp2-thermal0-clk#
d#  83 constant mmp3-thermal1-clk#
d#  84 constant mmp3-thermal2-clk#
d#  85 constant mmp3-thermal3-clk#
d# 106 constant mmp2-disp0-clk#
d# 101 constant mmp2-sdh0-clk#
d# 102 constant mmp2-sdh1-clk#
d# 103 constant mmp2-sdh2-clk#
d# 104 constant mmp2-sdh3-clk#
d# 105 constant mmp2-usb-clk#
d# 112 constant mmp2-ccic0-clk#
d# 120 constant mmp2-disp0-lcdc-clk#
d# 121 constant mmp2-usbhsic0-clk#
d# 122 constant mmp2-usbhsic1-clk#
d# 123 constant mmp2-gpu-bus-clk#
d# 124 constant mmp2-gpu-3d-clk#
d# 125 constant mmp3-gpu-2d-clk#
d# 126 constant mmp3-sdh4-clk#

\ From include/dt-bindings/power/marvell,mmp2.h
d# 0 constant mmp2-gpu-pd#
d# 2 constant mmp3-camera-pd#

\ FIXME: Not official clock numbers!
d# 10000 constant mmp2-audio-clk#
d# 10001 constant mmp2-vmeta-clk#

0 0  " "  " /" begin-package
" clocks" name
" marvell,mmp2-clock" +compatible
[ifdef] mmp3
" marvell,mmp3-clock" +compatible
[then]

h# d405.0000 encode-int          h# 2000 encode-int encode+
h# d428.2800 encode-int encode+  h#  400 encode-int encode+
h# d401.5000 encode-int encode+  h# 1000 encode-int encode+
" reg" property

" mpmu" encode-string
" apmu" encode-string encode+
" apbc" encode-string encode+
" reg-names" property

1 " #clock-cells" integer-property
1 " #reset-cells" integer-property
1 " #power-domain-cells" integer-property

\            value  clr-mask  reg
: twsi0-clk  h#  3  h# 77     h# 04 +apbc ;
: twsi1-clk  h#  3  h# 77     h# 08 +apbc ;
: twsi2-clk  h#  3  h# 77     h# 0c +apbc ;
: twsi3-clk  h#  3  h# 77     h# 10 +apbc ;
: twsi4-clk  h#  3  h# 77     h# 7c +apbc ;
: twsi5-clk  h#  3  h# 77     h# 80 +apbc ;
: sdh0-clk   h# 1b  h# 1b     h# 54 +pmua ;
: sdh1-clk   h# 1b  h# 1b     h# 58 +pmua ;
: sdh2-clk   h# 1b  h# 1b     h# e8 +pmua ;
: sdh3-clk   h# 1b  h# 1b     h# ec +pmua ;

: generic-on/off         ( on? value clr-mask reg )
   dup io@               ( on? value clr-mask reg reg-val )
   rot not and           ( on? value reg masked-val )
   2swap swap            ( reg masked-val value on? )
   if or else drop then  ( reg final-val )
   swap io!
;

h# 10c constant audio-clk

[ifdef] mmp3
h# 164 constant audio-dsa
h# 1e4 constant isld-dspa-ctrl
h# 240 constant audio-sram-pwr
[then]

\ Discrepancies - ms vs us, double-enabling of AXI
: dly  d# 10 us  ;

: audio-island-on  ( -- )
[ifdef] mmp3
   h# 200  audio-clk  pmua-set  dly  \ Power switch on
   h# 400  audio-clk  pmua-set  dly  \ Power switch more on
   1  audio-sram-pwr  pmua-set  dly  \ Audio SRAM on
   2  audio-sram-pwr  pmua-set  dly  \ Audio SRAM more on
   4  audio-sram-pwr  pmua-set  dly  \ Audio core on
   8  audio-sram-pwr  pmua-set  dly  \ Audio core more on
   h# 100  audio-clk  pmua-set  dly  \ Disable isolation

   4  audio-clk pmua-set           \ Start audio SRAM redundancy repair
   begin  audio-clk pmua@  4 and 0=  until  \ And wait until done

   \ Bring audio island out of reset
   1 audio-dsa pmua-set		\ Unreset AXI
   4 audio-dsa pmua-set		\ Unreset APB
   1 audio-dsa pmua-set		\ Unreset AXI (redundant?)

   \ Enable dummy clocks to the SRAMs
   h# 10 isld-dspa-ctrl pmua-set  d# 250 us  h# 10 isld-dspa-ctrl pmua-clr

   \ Enable the AXI/APB clocks to the Audio island prior to programming island registers
   2 audio-dsa pmua-set
   8 audio-dsa pmua-set
[else]
   h# 600  audio-clk  pmua!  dly  \ Turn on power
   h# 610  audio-clk  pmua!  dly  \ Enable clock
   h# 710  audio-clk  pmua!  dly  \ Disable isolation
   h# 712  audio-clk  pmua!  dly  \ Release reset
[then]
;

: audio-island-off  ( -- )
[ifdef] true
[ifdef] mmp3
   h#   a  audio-dsa       pmua-clr  \ Disable AXI and APB clocks
   h#   5  audio-dsa       pmua-clr  \ Put AXI and APB clocks in reset
   h# 100  audio-clk       pmua-clr  \ Enable isolation
   h#   c  audio-sram-pwr  pmua-clr  \ Audio core off
   h#   3  audio-sram-pwr  pmua-clr  \ Audio SRAM off
   h# 600  audio-clk       pmua-clr  \ Power switch off
[else]
   h# 710  audio-clk  pmua!  \ Set peripheral reset
   h# 610  audio-clk  pmua!  \ Enable isolation
   h# 600  audio-clk  pmua!  \ Disable clock
   h# 000  audio-clk  pmua!  \ Turn off power
[then]
[then]
   0 audio-clk pmua!
;
: audio-on/off  ( on? -- )
   if  audio-island-on  else  audio-island-off  then
;

[ifdef] mmp3
: ccic0-isp-island-off  ( -- )
   h# 600 h# 1fc pmua!  \ Isolation enabled
   \ Fiddle with ISP_CLK_RES_CTRL here to turn off ISP engine
   h# 000 h# 1fc pmua!  \ Power off
;

: ccic0-isp-island-on   ( -- )
   \ set ISP regs to the default value
   0 h#  50 pmua!
   0 h# 1fc pmua!

   \ Turn on the CCIC/ISP power switch
   h# 200 h# 1fc pmua!  \ Partially powered
   d# 10 ms
   h# 600 h# 1fc pmua!  \ Fully powered
   d# 10 ms
   h# 700 h# 1fc pmua!  \ Isolation disabled

[ifdef] notdef
   \ Empirically, the memory redundancy and SRAMs are unnecessary
   \ for camera-only (no ISP) operation.

   \ Start memory redundacy repair
   4 h# 224 pmua-set   \ PMUA_ISP_CLK_RES_CTRL
   begin  d# 10 ms h# 224 pmua@  4 and  0=  until

   \ Enable dummy clocks to the SRAMS
   h# 10 h# 1e0 pmua-set   \ PMUA_ISLD_CI_PDWN_CTRL
   d# 200 ms
   h# 10 h# 1e0 pmua-clr
[then]

   \ Enable ISP clocks here if you want to use the ISP
   \ 8 h# 224 pmua-set  \ Enable AXI clock in PMUA_ISP_CLK_RES_CTRL
   \ h# f00 h# 200 h# 224 pmua-fld \ Clock divider
   \ h#  c0 h#  40 h# 224 pmua-fld \ CLock source
   \ h# 10 h# 224 pmua-set

   \ enable CCIC clocks
   h# 8238 h# 50 pmua-set

   \ Deassert ISP clocks here if you want to use the ISP
   \ XXX should these be pmua-clr ?
   \ 1 h# 224 pmua-set  \ AXI reset
   \ 2 h# 224 pmua-set  \ ISP SW reset
   \ h# 10000 h# 50 pmua-set  \ CCIC1 AXI Arbiter reset

   \ De-assert CCIC Resets
   h# 10107 h# 50 pmua-set \ XXX change to 107
;
[then]

: ccic0-on/off  ( on? -- )
   if
      [ifdef] mmp3  ccic0-isp-island-on  [then]

      \ Enable clocks
      h#        3f h# 28 pmua!  \ Clock gating - AHB, Internal PIXCLK, AXI clock always on
      h# 0003.805b h# 50 pmua!  \ PMUA clock config for CCIC - /1, PLL1/16, AXI arb, AXI, perip on
   else
      h# 3f h# 50 pmua-clr
      [ifdef] mmp3  ccic0-isp-island-off  [then]
   then
;

: on/off  ( on? clock# -- )
   dup mmp2-twsi0-clk#  =  if drop  twsi0-clk generic-on/off  exit then
   dup mmp2-twsi1-clk#  =  if drop  twsi1-clk generic-on/off  exit then
   dup mmp2-twsi2-clk#  =  if drop  twsi2-clk generic-on/off  exit then
   dup mmp2-twsi3-clk#  =  if drop  twsi3-clk generic-on/off  exit then
   dup mmp2-twsi4-clk#  =  if drop  twsi4-clk generic-on/off  exit then
   dup mmp2-twsi5-clk#  =  if drop  twsi5-clk generic-on/off  exit then
   dup mmp2-sdh0-clk#   =  if drop  sdh0-clk  generic-on/off  exit then
   dup mmp2-sdh1-clk#   =  if drop  sdh1-clk  generic-on/off  exit then
   dup mmp2-sdh2-clk#   =  if drop  sdh2-clk  generic-on/off  exit then
   dup mmp2-sdh3-clk#   =  if drop  sdh3-clk  generic-on/off  exit then
   dup mmp2-ccic0-clk#  =  if drop  ccic0-on/off              exit then
   dup mmp2-audio-clk#  =  if drop  audio-on/off              exit then

   " clock=" type .d " on=" type .d cr
   abort " Unimplemented clock"
;

end-package

\ This is a general-purpose mechanism for enabling/disabling a clock
\ that is described by a "clocks" property in the device node.  The
\ property value is a phandle and an index, as used in Linux.

: my-clock-on/off  ( on? -- )
   " clocks" get-my-property  abort" No clocks property"  ( on? propval$ )
   decode-int  >r                  ( on? propval$  r: phandle )
   get-encoded-int                 ( on? clock#  r: phandle )
   r> push-package                 ( on? clock#  )
   " on/off" package-execute       ( )
   pop-package                     ( )
;
: my-clock-off  ( -- )  false  my-clock-on/off  ;
: my-clock-on  ( -- )  true  my-clock-on/off  ;

\ LICENSE_BEGIN
\ Copyright (c) 2019 Lubomir Rintel <lkundrak@v3.sk>
\ Parts based on cpu/arm/mmp2/pmua.fth file
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
