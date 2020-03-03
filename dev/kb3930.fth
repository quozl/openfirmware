purpose: ENE KB3930 Embedded Controller Driver
\ See license at end of file

" embedded-controller" name
" ene,kb3930" +compatible
" dell,wyse-ariel-ec" +compatible
h# 58 1 reg
0 0 " system-power-controller" property

" /gpio" encode-phandle         ec-off-pulse-gpio# encode-int encode+ d# 0 encode-int encode+
" /gpio" encode-phandle encode+ ec-off-type-gpio#  encode-int encode+ d# 0 encode-int encode+
" off-gpios" property

\ EC IO
: ec@  ( reg# -- byte )  " reg-w@" $call-parent  ;
: ec!  ( byte reg# -- )  " reg-w!" $call-parent  ;

\ EC RAM Access
h# 00 constant data-in
h# 81 constant ram-in
h# 80 constant ram-out

: ram@ ( adr -- val )  8 << ram-in ec!  data-in ec@  h# ff and ;
: ram! ( val adr -- )  8 << or             ram-out ec!            ;

\ EC RAM Addresses

\ Power button LED:
h# 01 constant blue-led
\ Two-color combinded status LED:
h# 02 constant amber-led
h# 03 constant green-led
\ Front side USB ports:
\ h# 11 (unidentified, probably internal WLAN USB connector?)
h# 12 constant usb1  \     .----.  .----.  .----.
h# 13 constant usb2  \ (o) |USB3|  |USB2|  |USB1|    = (') WYSE
h# 14 constant usb3  \     `----'  `----'  `----'
\ Back side USB port:
h# 15 constant usb4
\ Power management
h# 16 constant on-after-power-resume
h# 20 constant wake-on-lan
h# 21 constant wake-on-usb
\ h# 22 (unidentified)
\ EC firmware identification:
h# 30 constant model-id	    \ [char] 0
h# 31 constant version-maj  \ h# 03
h# 32 constant version-min  \ h# 02

\ LED Modes
h# 00 constant off
h# 01 constant still
h# 02 constant fade
h# 03 constant blink

: leds-start ( -- )
   my-unit " set-address" $call-parent
   off amber-led ram!
   still green-led ram!
;

: leds-boot ( -- )
   my-unit " set-address" $call-parent
   blink green-led ram!
;

: usb-ports-power-on ( -- )
   my-unit " set-address" $call-parent
   1 usb1 ram!
   1 usb2 ram!
   1 usb3 ram!
   1 usb4 ram!
;

: open   ( -- okay ) true ;
: close  ( -- )           ;

: off-pulse  ( -- )
   \ We're supposed to signal readiness to power off to the EC with a
   \ 10 MHz pulse. Delays of 48ms - 68ms seem to create a wave that's
   \ good enough for the EC. Choose the middle value
   ec-off-pulse-gpio# gpio-dir-out
   begin  ec-off-pulse-gpio#  dup gpio-clr  d# 58 ms  gpio-set  d# 58  ms  again
;

: power-off  ( -- )
   ec-off-type-gpio#  dup gpio-dir-out  gpio-set
   off-pulse
;

: reboot  ( -- )
   ec-off-type-gpio#  dup gpio-dir-out  gpio-clr
   off-pulse
;

\ LICENSE_BEGIN
\ Copyright (c) 2020 Lubomir Rintel <lkundrak@v3.sk>
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
