\ See license at end of file
purpose: GPIO driven switches description for Linux

\ include/dt-bindings/gpio/gpio.h
\ 0 constant GPIO_ACTIVE_HIGH
\ 1 constant GPIO_ACTIVE_LOW
\ 6 constant GPIO_OPEN_DRAIN

\ include/dt-bindings/input/linux-event-codes.h
\ 5 constant EV_SW
\ 0 constant SW_LID
\ 1 constant SW_TABLET_MODE
\ 2 constant SW_HEADPHONE_INSERT
\ 4 constant SW_MICROPHONE_INSERT

0 0  " "  " /" begin-package
" gpio-keys" device-name
" gpio-keys" +compatible

new-device
   " lid" device-name
   " Lid" " label" string-property
   5 " linux,input-type" integer-property  \ EV_SW
   0 " linux,code" integer-property  \ SW_LID
   0 0 encode-bytes " wakeup-source" property

   " /gpio" encode-phandle
   lid-switch-gpio# encode-int encode+
   1 encode-int encode+  \ GPIO_ACTIVE_LOW
   " gpios" property
finish-device

new-device
   " tablet_mode" device-name
   " E-Book Mode" " label" string-property
   5 " linux,input-type" integer-property  \ EV_SW
   1 " linux,code" integer-property  \ SW_TABLET_MODE
   0 0 encode-bytes " wakeup-source" property

   " /gpio" encode-phandle
   ebook-mode-gpio# encode-int encode+
   1 encode-int encode+  \ GPIO_ACTIVE_LOW
   " gpios" property
finish-device

new-device
   " microphone_insert" device-name
   " Microphone Plug" " label" string-property
   5 " linux,input-type" integer-property  \ EV_SW
   4 " linux,code" integer-property  \ SW_MICROPHONE_INSERT
   d# 100 " debounce-interval" integer-property
   0 0 encode-bytes " wakeup-source" property

   " /gpio" encode-phandle
   mic-plug-gpio# encode-int encode+
   0 encode-int encode+  \ GPIO_ACTIVE_HIGH
   " gpios" property
finish-device

new-device
   " headphone_insert" device-name
   " Headphone Plug" " label" string-property
   5 " linux,input-type" integer-property  \ EV_SW
   2 " linux,code" integer-property  \ SW_HEADPHONE_INSERT
   d# 100 " debounce-interval" integer-property
   0 0 encode-bytes " wakeup-source" property

   " /gpio" encode-phandle
   hp-plug-gpio# encode-int encode+
   0 encode-int encode+  \ GPIO_ACTIVE_HIGH
   " gpios" property
finish-device

end-package

\ LICENSE_BEGIN
\ Copyright (c) 2018 Lubomir Rintel <lkundrak@v3.sk>
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
