\ See license at end of file
purpose: MMP2 clock management

\ From include/dt-bindings/clock/marvell,mmp2.h
d#  60 constant mmp2-twsi0-clk#
d#  61 constant mmp2-twsi1-clk#
d#  63 constant mmp2-twsi3-clk#
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
d#  81 constant mmp2-timer-clk#
d# 106 constant mmp2-disp0-clk#
d# 101 constant mmp2-sdh0-clk#
d# 102 constant mmp2-sdh1-clk#
d# 103 constant mmp2-sdh2-clk#
d# 104 constant mmp2-sdh3-clk#
d# 105 constant mmp2-usb-clk#
d# 112 constant mmp2-ccic0-clk#
d# 120 constant mmp2-disp0-lcdc-clk#

0 0  " "  " /" begin-package
" clocks" name
" marvell,mmp2-clock" +compatible

h# d405.0000 encode-int          h# 1000 encode-int encode+
h# d428.2800 encode-int encode+  h#  400 encode-int encode+
h# d401.5000 encode-int encode+  h# 1000 encode-int encode+
" reg" property

" mpmu" encode-string
" apmu" encode-string encode+
" apbc" encode-string encode+
" reg-names" property

1 " #clock-cells" integer-property
1 " #reset-cells" integer-property

\            value   clr-mask  reg
: twsi0-clk  h#   3  h#  77    h#  04 +apbc ;
: twsi1-clk  h#   3  h#  77    h#  08 +apbc ;
: twsi3-clk  h#   3  h#  77    h#  10 +apbc ;
: twsi5-clk  h#   3  h#  77    h#  80 +apbc ;
: sdh0-clk   h# 41b  h#  1b    h# 054 +pmua ;
: sdh1-clk   h#  1b  h#  1b    h# 058 +pmua ;
: sdh2-clk   h#  1b  h#  1b    h# 0e8 +pmua ;
: sdh3-clk   h#  1b  h#  1b    h# 0ec +pmua ;

: generic-on/off         ( on? value clr-mask reg )
   dup io@               ( on? value clr-mask reg reg-val )
   rot not and           ( on? value reg masked-val )
   2swap swap            ( reg masked-val value on? )
   if or else drop then  ( reg final-val )
   swap io!
;

: on/off  ( on? clock# -- )
   dup mmp2-twsi0-clk#  =  if drop  twsi0-clk generic-on/off  exit then
   dup mmp2-twsi1-clk#  =  if drop  twsi1-clk generic-on/off  exit then
   dup mmp2-twsi3-clk#  =  if drop  twsi3-clk generic-on/off  exit then
   dup mmp2-twsi5-clk#  =  if drop  twsi5-clk generic-on/off  exit then
   dup mmp2-sdh0-clk#   =  if drop  sdh0-clk  generic-on/off  exit then
   dup mmp2-sdh1-clk#   =  if drop  sdh1-clk  generic-on/off  exit then
   dup mmp2-sdh2-clk#   =  if drop  sdh2-clk  generic-on/off  exit then
   dup mmp2-sdh3-clk#   =  if drop  sdh3-clk  generic-on/off  exit then

   " clock=" type .d " on=" type .d cr
   abort " Unimplemented clock"
;

end-package

\ LICENSE_BEGIN
\ Copyright (c) 2019 Lubomir Rintel <lkundrak@v3.sk>
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
