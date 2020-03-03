purpose: Marvell 88PM867 regulator device node
\ See license at end of file

" regulator" name
" marvell,88pg867" +compatible
h# 19 1 reg

: 88pm867@  ( reg# -- byte )  " reg-b@" $call-parent  ;
: 88pm867!  ( byte reg# -- )  " reg-b!" $call-parent  ;

: open  ( -- okay )
   \ my-unit " set-address" $call-parent
   true
;

: close  ( -- )
;

new-device
   " buck1" device-name
   " vdd_1v8" " regulator-name" string-property
   d# 1800000 " regulator-min-microvolt" integer-property
   d# 1800000 " regulator-max-microvolt" integer-property
   0 0 " regulator-boot-on" property
   0 0 " regulator-always-on" property
finish-device

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
