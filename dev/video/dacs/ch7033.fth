purpose: Driver for external CH7033 VGA DVI Encoder
\ See license at end of file

" vga-dvi-encoder" name
" chrontel,ch7033" +compatible
h# 76 1 reg

: ch7033@  ( reg# -- byte )  " reg-b@" $call-parent  ;
: ch7033!  ( byte reg# -- )  " reg-b!" $call-parent  ;

: disable ( -- )
   my-unit " set-address" $call-parent
   h# 04 h# 03 ch7033!
   h# 00 h# 52 ch7033! \ Power off all blocks
;

: enable ( -- )
   my-unit " set-address" $call-parent

   \ Reset
   h# 04 h# 03 ch7033!
   h# 00 h# 52 ch7033! \ Turn everything off to set all the registers to their defaults
   h# 02 h# 52 ch7033! \ Bring I/O block up

   \ Page 0
   h# 00 h# 03 ch7033!

   \ Bring up parts we need from the power down
   h# d7 h# 07 ch7033!
   h# 00 h# 08 ch7033!
   h# 1a h# 09 ch7033!
   h# 9a h# 0a ch7033!

   \ Horizontal input timing
   h# 2c h# 0b ch7033!
   h# 00 h# 0c ch7033!
   h# 40 h# 0d ch7033!
   h# 00 h# 0e ch7033!
   h# 18 h# 0f ch7033!
   h# 88 h# 10 ch7033!

   \ Vertical input timing
   h# 1b h# 11 ch7033!
   h# 00 h# 12 ch7033!
   h# 26 h# 13 ch7033!
   h# 00 h# 14 ch7033!
   h# 03 h# 15 ch7033!
   h# 06 h# 16 ch7033!

   \ Input color swap
   \ h# 00 h# 18 ch7033!
   h# 05 h# 18 ch7033!

   \ Input clock and sync polarity
   h# f8 h# 19 ch7033!
   h# c8 h# 19 ch7033!
   h# fd h# 1a ch7033!
   h# e8 h# 1b ch7033!

   \ Horizontal output timing
   h# 2c h# 1f ch7033!
   h# 00 h# 20 ch7033!
   h# 40 h# 21 ch7033!

   \ Vertical output timing
   h# 1b h# 25 ch7033!
   h# 00 h# 26 ch7033!
   h# 26 h# 27 ch7033!

   \ VGA channel bypass
   h# 09 h# 2b ch7033!

   \ Output sync polarity
   h# 27 h# 2e ch7033!

   \ HDMI horizontal output timing
   h# 80 h# 54 ch7033!
   h# 18 h# 55 ch7033!
   h# 88 h# 56 ch7033!

   \ HDMI vertical output timing
   h# 00 h# 57 ch7033!
   h# 03 h# 58 ch7033!
   h# 06 h# 59 ch7033!

   \ Pick HDMI, not LVDS
   h# 8f h# 7e ch7033!

   \ Page 1
   h# 01 h# 03 ch7033!

   \ No idea what these do, but VGA is wobbly
   \ and blinky without them
   h# 66 h# 07 ch7033!
   h# 05 h# 08 ch7033!

   \ DRI PLL
   h# 6a h# 0c ch7033!
   h# 6a h# 0c ch7033!
   h# 12 h# 6b ch7033!
   h# 00 h# 6c ch7033!

   \ This seems to be color calibration for VGA
   h# 29 h# 64 ch7033! \ LSB Blue
   h# 29 h# 65 ch7033! \ LSB Green
   h# 29 h# 66 ch7033! \ LSB Red
   h# 00 h# 67 ch7033! \ MSB Blue
   h# 00 h# 68 ch7033! \ MSB Green
   h# 00 h# 69 ch7033! \ MSB Red

   \ Page 3
   h# 03 h# 03 ch7033!

   \ More bypasses and apparently another HDMI/LVDS selector
   h# 0c h# 28 ch7033!
   h# 28 h# 2a ch7033!

   \ Page 4
   h# 04 h# 03 ch7033!

   \ Output clock
   h# 00 h# 10 ch7033!
   h# fd h# 11 ch7033!
   h# e8 h# 12 ch7033!

   \ Bring the display block up from reset
   h# 03 h# 52 ch7033!
;

: open  ( -- okay )
   enable
   true
;

: close  ( -- )
;

new-device
   " ports" device-name
   1 " #address-cells" integer-property
   0 " #size-cells" integer-property

   : decode-unit  ( adr len -- phys )  $number  if  0  then  ;
   : encode-unit  ( phys -- adr len )  (u.)  ;
   : open  ( -- true )  true  ;
   : close  ( -- )  ;

   new-device
      " port" device-name
      0 " reg" integer-property
      new-device
         " endpoint" device-name
      finish-device
   finish-device

   new-device
      " port" device-name
      1 " reg" integer-property
      new-device
         " endpoint" device-name
      finish-device
   finish-device
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
