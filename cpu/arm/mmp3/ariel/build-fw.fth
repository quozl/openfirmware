purpose: Common code for build OFW Forth dictionaries for Dell Ariel (Wyse 3020)
\ See license at end of file

hex

warning @ warning off
: stand-init-io
   stand-init-io
   init-timers
;
warning !

root-device
   " Dell Ariel" model
   " marvell,mmp3" +compatible
   " dell,wyse-ariel" +compatible

   " /interrupt-controller@d4282000" encode-phandle " interrupt-parent" property
   0 0 " ranges" property
device-end

fload ${BP}/cpu/arm/olpc/fbnums.fth
fload ${BP}/cpu/arm/olpc/fbmsg.fth

fload ${BP}/dev/omap/diaguart.fth

d# 26000000 to uart-clock-frequency

\ CForth has already set up the serial port
: inituarts  ( -- )  ;

fload ${BP}/forth/lib/sysuart.fth	\ Set console I/O vectors to UART

: poll-tty  ( -- )  ubreak?  if  user-abort  then  ;  \ BREAK detection
: install-abort  ( -- )  ['] poll-tty d# 100 alarm  ;

0 value dcon-ih
0 value keyboard-ih

fload ${BP}/ofw/core/muxdev.fth          \ I/O collection/distribution device

\ Install the simple UART driver from the standalone I/O init chain
warning off
: stand-init-io  ( -- )
   stand-init-io
   inituarts  install-uart-io  install-abort
;
warning on

[ifdef] use-null-nvram
\ For not storing configuration variable changes across reboots ...
\ This is useful for "turnkey" systems where configurability would
\ increase support costs.

fload ${BP}/cpu/x86/pc/nullnv.fth
stand-init: Null-NVRAM
   " /null-nvram" open-dev  to nvram-node
   ['] init-config-vars catch drop
;
[then]

[ifdef] use-flash-nvram
\ For configuration variables stored in a sector of the boot FLASH ...

\ Create a node below the top-level FLASH node to access the portion
\ containing the configuration variables.
0 0  " d0000"  " /flash" begin-package
   " nvram" device-name

   h# 10000 constant /device
   fload ${BP}/dev/subrange.fth
end-package

stand-init: NVRAM
   " /nvram" open-dev  to nvram-node
   ['] init-config-vars catch drop
;
[then]

\ Create a pseudo-device that presents the dropin modules as a filesystem.
fload ${BP}/ofw/fs/dropinfs.fth

\ This devalias lets us say, for example, "dir rom:"
devalias rom     /dropin-fs

fload ${BP}/cpu/arm/mmp3/l2cache.fth
fload ${BP}/cpu/arm/mmp3/cpunode.fth
fload ${BP}/cpu/arm/mmp3/scu.fth

fload ${BP}/cpu/arm/mmp2/watchdog.fth	\ reset-all using watchdog timer

fload ${BP}/cpu/arm/mmp2/twsi-i2c.fth
devalias i2c2 /i2c@d4011000
dev /i2c@d4011000
   new-device
      fload ${BP}/dev/ds1338.fth
   finish-device
   new-device
      fload ${BP}/dev/88pm867.fth
   finish-device
device-end
devalias i2c3 /i2c@d4032000
dev /i2c@d4032000
   new-device
      fload ${BP}/dev/video/dacs/ch7033.fth
   finish-device
device-end
devalias i2c4 /i2c@d4033800
devalias i2c5 /i2c@d4033000
devalias i2c6 /i2c@d4034000
dev /i2c@d4033000
   new-device
      fload ${BP}/dev/kb3930.fth
   finish-device
device-end
dev /i2c@d4031000  " disabled" " status" string-property  device-end

0 0  " "  " /" begin-package
   " dvi-connector" name
   " dvi-connector" +compatible
   " /i2c@d4033800" encode-phandle " ddc-i2c-bus" property

   " /gpio" encode-phandle
      dvi1-hpd-gpio# encode-int encode+
      d# 1 encode-int encode+
      " hpd-gpios" property

   0 0 " digital" property
   0 0 " analog" property

   new-device
      " port" device-name
      new-device
         " endpoint" device-name
      finish-device
   finish-device
end-package

" /dvi-connector/port/endpoint"  " /vga-dvi-encoder/ports/port@1/endpoint" link-endpoints

fload ${BP}/cpu/arm/mmp2/uart.fth
dev /uart@d4030000  " disabled" " status" string-property  device-end
dev /uart@d4017000  " disabled" " status" string-property  device-end
dev /uart@d4016000  " disabled" " status" string-property  device-end

devalias serial2 /uart@d4018000
: com1  " /uart@d4018000"  ;
' com1 is fallback-device

\ \needs md5init  fload ${BP}/ofw/ppp/md5.fth                \ MD5 hash

fload ${BP}/dev/olpc/spiflash/flashif.fth  \ Generic FLASH interface

fload ${BP}/dev/olpc/spiflash/spiif.fth    \ Generic low-level SPI bus access

fload ${BP}/dev/olpc/spiflash/spiflash.fth \ SPI FLASH programming

fload ${BP}/cpu/arm/mmp2/sspspi.fth        \ Synchronous Serial Port SPI interface

fload ${BP}/cpu/arm/mmp2/ssp-spi.fth       \ SSP device nodes
dev /spi@d4035000
   " /gpio" encode-phandle
      spi-flash-cs-gpio# encode-int encode+
      d# 1 encode-int encode+
      " cs-gpios" property

   \ Create the top-level device node to access the entire boot FLASH device
   new-device
      " flash" device-name
      " jedec,spi-nor" +compatible
      " winbond,w25q32" +compatible
      d# 104000000 " spi-max-frequency" integer-property
      0 0 " m25p,fast-read" property
      0 " reg" integer-property
      /rom value /device
      fload ${BP}/dev/nonmmflash.fth
   finish-device
device-end
dev /spi@d4036000  " disabled" " status" string-property  device-end
dev /spi@d4037000  " disabled" " status" string-property  device-end
dev /spi@d4039000  " disabled" " status" string-property  device-end

\ Create a node below the top-level FLASH node to accessing the portion
\ containing the dropin modules
0 0  " 20000"  " /flash" begin-package
   " dropins" device-name

   /rom h# 20000 - constant /device
   fload ${BP}/dev/subrange.fth
end-package

devalias dropins /dropins

load-base constant flash-buf

fload ${BP}/cpu/arm/mmp3/ariel/spiui.fth      \ User interface for SPI FLASH programming

\ Reserve memory for the framebuffer
0 0  " "  " /" begin-package
   " reserved-memory" name
   1 " #address-cells" integer-property
   1 " #size-cells" integer-property
   0 0 encode-bytes " ranges" property

   new-device
       " framebuffer" device-name
       " marvell,armada-framebuffer" +compatible
       " marvell,mmp2-framebuffer" +compatible
       h# 02000000 " size" integer-property
       h# 02000000 " alignment" integer-property
       0 0 encode-bytes " no-map" property
   finish-device
end-package

0 0  " f0400000"  " /" begin-package
   " vmeta" name
   my-address my-space h# 400000 reg

   " mrvl,mmp2-vmeta" +compatible

   " /clocks" encode-phandle mmp2-vmeta-clk# encode-int encode+ " clocks" property
   " VMETACLK" " clock-names" string-property
   d# 26 " interrupts" integer-property
end-package

fload ${BP}/cpu/arm/mmp3/ariel/lcdcfg.fth
fload ${BP}/cpu/arm/olpc/lcd.fth

" /display/port/endpoint" " /vga-dvi-encoder/ports/port@0/endpoint" link-endpoints

fload ${BP}/cpu/arm/mmp3/galcore.fth

\ fload ${BP}/cpu/arm/mmp3/ariel/sdhci.fth

fload ${BP}/cpu/arm/mmp2/sdhci.fth
dev /sdhci@d4281000
   d# 15 encode-int " clk-delay-cycles" property
   d# 50000000 " max-frequency" integer-property
   0 0  " non-removable" property
   d# 8 " bus-width" integer-property
   0 0 " cap-mmc-highspeed" property

   : write-protected?  false  ;
   new-device
      fload ${BP}/dev/mmc/sdhci/sdmmc.fth
      fload ${BP}/dev/mmc/sdhci/selftest.fth
      " internal" " slot-name" string-property
   finish-device
device-end
dev /sdhci@d4280000  " disabled" " status" string-property  device-end
dev /sdhci@d4280800  " disabled" " status" string-property  device-end
dev /sdhci@d4281800  " disabled" " status" string-property  device-end
devalias int /sd/sdhci@d4281000/disk

0 0 " " " /" begin-package
   " spi" device-name
   " spi-gpio" +compatible
   1 " #address-cells" integer-property
   0 " #size-cells" integer-property

   : decode-unit  ( adr len -- phys )  $number  if  0  then  ;
   : encode-unit  ( phys -- adr len )  (u.)  ;
   : open  ( -- true )  true  ;
   : close  ( -- )  ;

   " /gpio" encode-phandle d# 55 encode-int encode+ d# 0 encode-int encode+ " gpio-sck" property
   " /gpio" encode-phandle d# 57 encode-int encode+ d# 0 encode-int encode+ " gpio-miso" property
   " /gpio" encode-phandle d# 58 encode-int encode+ d# 0 encode-int encode+ " gpio-mosi" property
   " /gpio" encode-phandle d# 56 encode-int encode+ d# 0 encode-int encode+ " cs-gpios" property

   new-device
      " power-button" name
      0 " reg" integer-property
      " ene,kb3930-input" +compatible
      " dell,wyse-ariel-ec-input" +compatible
      d# 33000000 " spi-max-frequency" integer-property
      " /gpio" encode-phandle " interrupt-parent" property
      d# 60 encode-int d# 1 encode-int encode+ " interrupts" property
   finish-device
end-package

fload ${BP}/ofw/core/fdt.fth

autoload: mmp3-gic-  defines: mmp3-gic
0 value no-mmp3-gic?

autoload: olpc-compat-  defines: olpc-compat
0 value olpc-compat?

fload ${BP}/cpu/arm/linux.fth

\ Create the alias unless it already exists
: $?devalias  ( alias$ value$ -- )
   2over  not-alias?  if  $devalias exit  then  ( alias$ value$ alias$ )
   2drop 4drop
;

: ?report-device  ( alias$ pathname$ -- )
   2dup  locate-device  0=  if  ( alias$ pathname$ phandle )
      drop                      ( alias$ pathname$ )
      2over 2over $?devalias    ( alias$ pathname$ )
   then                         ( alias$ pathname$ )
   4drop                        ( )
;

: report-disk  ( -- )
   " disk"  " /usb@d4208000/disk" ?report-device
;

: report-keyboard  ( -- )
   " usb-keyboard"  " /usb@d4208000/keyboard" ?report-device
;

: report-net  ( -- )
   " net"  " /usb@f0001000/hub@1,0/ethernet@2,0" ?report-device
;

: disable-unpopulated  ( -- )
   " /usb@f0001000/hub@1,0/scsi@1,0" find-device
      " disabled" " status" string-property
   device-end
;

fload ${BP}/cpu/arm/mmp3/usb2phy.fth
fload ${BP}/cpu/arm/olpc/usb.fth
fload ${BP}/cpu/arm/mmp3/hsic.fth
devalias u /usb@d4208000/disk

fload ${BP}/cpu/arm/firfilter.fth

fload ${BP}/cpu/x86/adpcm.fth            \ ADPCM decoding
d# 32 is playback-volume

stand-init: RTC
   " /i2c@d4011000/rtc@68" open-dev  clock-node !
   \ use RTC 32kHz clock as SoC external slow clock
   h# 38 mpmu@ 1 or h# 38 mpmu!
   \ check the clock stop flag and reinit if necessary
   " verify" clock-node @ $call-method
;

stand-init: More memory
   extra-mem-va /extra-mem add-memory
;

fload ${BP}/cpu/arm/mmp3/thermal.fth
fload ${BP}/cpu/arm/mmp2/fuse.fth

[ifndef] virtual-mode
warning off
: stand-init-io
   stand-init-io
   go-fast         \ From mmuon.fth
;
warning on
[then]

\ The bottom of extra-mem is the top of DMA memory.
\ We give everything up to that address to Linux.
: olpc-memory-limit  ( -- adr )  extra-mem-va >physical  ;
' olpc-memory-limit to memory-limit
: olpc-mapped-limit  ( -- adr )  dma-mem-va >physical  ;
' olpc-mapped-limit to mapped-limit

machine-type to arm-linux-machine-type

false to stand-init-debug?
\ true to stand-init-debug?

fload ${BP}/ofw/core/countdwn.fth   \ Startup countdown

hex
: i-key-wait  ( ms -- pressed? )
   cr ." Type 'i' to interrupt stand-init sequence" cr   ( ms )
   0  do
      ukey?  if
         ukey upc ascii I  =  if  true unloop exit  then
      then
      d# 1000 us  \ 1000 us is more precise than 1 ms, which is often close to 2 ms
   loop
   false
;

\ Uninstall the diag menu from the general user interface vector
\ so exiting from emacs doesn't invoke the diag menu.
' quit to user-interface

: screen-#lines  ( -- n )
   screen-ih 0=  if  default-#lines exit  then
   screen-ih  package( #lines )package
;
' screen-#lines to lines/page

true value text-on?
: text-off  ( -- )
   text-on?  if
      screen-ih remove-output
      false to text-on?
   then
;
: text-on   ( -- )
   text-on? 0=  if
      screen-ih add-output
      cursor-on
      true to text-on?
   then
;

fload ${BP}/cpu/arm/mmp2/clocks.fth

: console-start  ( -- )
   " /vga-dvi-encoder" open-dev to dcon-ih
   install-mux-io
   cursor-off
   true to text-on?

   " //null" open-dev to null-ih  \ For text-off state
;
: keyboard-off  ( -- )
   keyboard-ih  if
      keyboard-ih remove-input
      keyboard-ih close-dev
      0 to keyboard-ih
   then
;

: teardown-mux-io  ( -- )
   install-uart-io
   text-off
   keyboard-off
   fallback-out-ih remove-output
   fallback-in-ih remove-input
   stdin off
   stdout off
   in-mux-ih close-dev
   out-mux-ih close-dev
;
: quiesce  ( -- )
   usb-quiet
   teardown-mux-io
   timers-off
   unload-crypto
;

\ This must precede the loading of gui.fth, which chains from linux-hook's behavior
' quiesce to linux-hook

fload ${BP}/cpu/arm/mmp2/showirqs.fth

fload ${BP}/cpu/arm/mmp3/dramrecal.fth
: linux-hook-smp ( -- )
   [ ' linux-hook behavior compile, ]  \ Chain to old behavior
   enable-smp
;
' linux-hook-smp to linux-hook

code halt  ( -- )  wfi   c;

fload ${BP}/cpu/arm/mmp2/rtc.fth       \ Internal RTC, used for wakeups

: emacs  ( -- )
   false to already-go?
   boot-getline to boot-file   " rom:emacs" $boot
;
: tsc@  ( -- d.ticks )  timer0@ u>d  ;
d# 6500 constant ms-factor

fload ${BP}/cpu/arm/bootascall.fth

d# 999 ' screen-#rows    set-config-int-default  \ Expand the terminal emulator to fill the screen
d# 999 ' screen-#columns set-config-int-default  \ Expand the terminal emulator to fill the screen

fload ${BP}/cpu/x86/pc/olpc/gridmap.fth      \ Gridded display tools
fload ${BP}/cpu/x86/pc/olpc/life.fth
fload ${BP}/ofw/gui/ofpong.fth

" u:\boot\olpc.fth int:\boot\olpc.fth net"  ' boot-device  set-config-string-default

\needs ramdisk  " " d# 128 config-string ramdisk
" "   ' boot-file      set-config-string-default   \ Let the boot script set the cmdline

2 config-int auto-boot-countdown

\ Eliminate 4 second delay in install console for the case where
\ there is no keyboard.  The delay is unnecessary because the screen
\ does not go blank when the device is closed.
patch drop ms install-console

alias reboot bye

alias crcgen drop  ( crc byte -- crc' )

\ Dictionary growth size for the ARM Image Format header
\ 1 section   before origin  section table
h# 10.0000      h# 8000 -      h# 4000 -      dictionary-size !

fload ${BP}/cpu/arm/saverom.fth  \ Save the dictionary for standalone startup

: interpreter-init  ( -- )
   hex
   warning on
   only forth also definitions

   install-alarm

   page-mode
   #line off
;

: startup  ( -- )
   standalone?  0=  if  exit  then

   no-page

   disable-user-aborts
   console-start

   " probe-" do-drop-in

   unused-core-off

   install-alarm

   auto-banner?  if  banner  then

   ['] false to interrupt-auto-boot?
   probe-usb
   report-disk
   report-keyboard
   report-net
   disable-unpopulated

   " probe+" do-drop-in

   interpreter-init

   ['] (interrupt-auto-boot?) to interrupt-auto-boot?

   ?usb-keyboard

   auto-boot

   cursor-on

   enable-user-aborts
   quit
;

: enable-serial ;
fload ${BP}/cpu/x86/pc/olpc/terminal.fth   \ Serial terminal emulator

\ Embedded Controller interface

0 value ec-ih

: ec-power-off  ( -- )  " power-off" ec-ih $call-method ;
: ec-reboot     ( -- )  " reboot"    ec-ih $call-method ;
' ec-power-off to power-off

stand-init: Embedded Controller
   " /embedded-controller" open-dev to ec-ih
   ['] ec-reboot to bye
   \ Start turn off amber, turn on green LED
   " leds-start" ec-ih $call-method
   \ Power on the USB ports, just in case EC had them disabled
   " usb-ports-power-on" ec-ih $call-method
;

: (go-hook)  ( -- )
   [ ' go-hook behavior compile, ]
   \ Start flashing green upon booot
   " leds-boot" ec-ih $call-method
;
' (go-hook) to go-hook

\ These allow booting Fedora XO images
: show-sad ;
: visible ;
: unfreeze ;

\ LICENSE_BEGIN
\ Copyright (c) 2010 FirmWorks
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
