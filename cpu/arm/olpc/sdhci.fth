purpose: OLPC SDHCI (Secure Digital Host Controller Interface) configuration

fload ${BP}/cpu/arm/mmp2/sdhci.fth

dev /sd
   : olpc-card-inserted?  ( -- flag )
      base-addr h# d428.0000 =  if  d# 31 gpio-pin@ 0=  else  true  then
   ;
   ' olpc-card-inserted? to card-inserted?

[ifdef] olpc-cl4
also forth definitions
: isolate-mmc3-pins  ( gpio# #gpios -- )
   bounds  do
      i af@ 7 invert and 1 or  i af!
      i gpio-dir-out  i gpio-clr
   loop
;
: connect-mmc3-pins  ( gpio# #gpios -- )
   bounds  do
      i af@ 7 invert and 2 or  i af!
   loop
;
: isolate-emmc  ( -- )
   d# 108 4 isolate-mmc3-pins
   d# 161 4 isolate-mmc3-pins
   d# 145 2 isolate-mmc3-pins
;
: connect-emmc  ( -- )
   d# 108 4 connect-mmc3-pins
   d# 161 4 connect-mmc3-pins
   d# 145 2 connect-mmc3-pins
;
previous definitions
[then]

   \ Base-addr:power_GPIO - 1:35, 2:34, 3:33
   : gpio-power-on  ( -- )
      sdhci-card-power-on
[ifdef] en-emmc-pwr-gpio#
      base-addr h# d428.1000 =  if
         [ifdef] connect-emmc  connect-emmc  [then]
         en-emmc-pwr-gpio# gpio-clr
      then
[then]
[ifdef] en-wlan-pwr-gpio#
      base-addr h# d428.0800 =  if  en-wlan-pwr-gpio# gpio-set  then
[then]
[ifdef] sd-pwroff-gpio#
      base-addr h# d428.0000 =  if  sd-pwroff-gpio# gpio-clr  then
[then]
   ;
   ' gpio-power-on to card-power-on

   : gpio-power-off  ( -- )
[ifdef] en-emmc-pwr-gpio#
      base-addr h# d428.1000 =  if
         en-emmc-pwr-gpio# gpio-set
         [ifdef] isolate-emmc isolate-emmc  [then]
      then
[then]
[ifdef] en-wlan-pwr-gpio#
      base-addr h# d428.0800 =  if  en-wlan-pwr-gpio# gpio-clr  then
[then]
[ifdef] sd-pwroff-gpio#
      base-addr h# d428.0000 =  if  sd-pwroff-gpio# gpio-set  then
[then]
      sdhci-card-power-off
   ;
   ' gpio-power-off to card-power-off
device-end

dev /sdhci@d4280000  \ MMC1 - External SD
   8 encode-int " bus-width" property
   d# 31 encode-int " clk-delay-cycles" property
   0 0 encode-bytes  " no-1-8-v" property
   d# 40 encode-int  1 encode-int encode+  " power-delay-ms" property

   new-device
      fload ${BP}/dev/mmc/sdhci/sdmmc.fth
      fload ${BP}/dev/mmc/sdhci/selftest.fth
      " external" " slot-name" string-property
   finish-device
device-end

dev /sdhci@d4280800  \ MMC2 - WLAN
   8 encode-int " bus-width" property
   d# 31 encode-int " clk-delay-cycles" property
   0 0  " non-removable" property

   d# 50 encode-int  d# 500 encode-int encode+  " power-delay-ms" property
   0 0 " broken-cd" property
   d# 50000000 " clock-frequency" integer-property
   0 0 encode-bytes " no-1-8-v" property
   0 0 encode-bytes " wakeup-source" property
   0 0 encode-bytes " keep-power-in-suspend" property

[ifdef] en-wlan-pwr-gpio#
   " /fixedregulator0" encode-phandle " vmmc-supply" property
   \ Active high
   " /gpio" encode-phandle  en-wlan-pwr-gpio# encode-int encode+  0 encode-int encode+  " power-gpios" property
[then]
[ifdef] wlan-reset-gpio#
   " /pwrseq0" encode-phandle " mmc-pwrseq" property
   \ Active low
   " /gpio" encode-phandle  wlan-reset-gpio# encode-int encode+  1 encode-int encode+  " reset-gpios" property
[then]

   new-device
      fload ${BP}/dev/mmc/sdhci/mv8686/loadpkg.fth
      fload ${BP}/dev/mmc/sdhci/mv8686/bluetooth-pkg.fth
   finish-device
device-end

dev /sdhci@d4281000  \ MMC3 - Internal eMMC
   0 0  " non-removable" property
   8 encode-int " bus-width" property
   d# 15 encode-int " clk-delay-cycles" property

   d# 40 encode-int  1 encode-int encode+  " power-delay-ms" property
   0 0 " broken-cd" property
   d# 50000000 " clock-frequency" integer-property
   d# 31 " mrvl,clk-delay-cycles" integer-property
   0 0 encode-bytes " no-1-8-v" property
[ifdef] en-emmc-pwr-gpio#
   " /fixedregulator1" encode-phandle " vmmc-supply" property
   \ Active low
   " /gpio" encode-phandle  en-emmc-pwr-gpio# encode-int encode+  1 encode-int encode+  " power-gpios"  property
[then]

   : write-protected?  false  ;
   new-device
      fload ${BP}/dev/mmc/sdhci/sdmmc.fth
      fload ${BP}/dev/mmc/sdhci/selftest.fth
      " internal" " slot-name" string-property
   finish-device
device-end

dev /sdhci@d4281800
   " disabled" " status" string-property
device-end

\ mmc0 is the internal storage device, which may depend on BOOT_DEV_SEL, so its
\ devalias is set in platform-dependent code

\ The WLAN device is always mmc1
devalias mmc1 /sd/sdhci@d4280800

stand-init: SDHC clocks
   h# 400 h# 54 pmua!    \ Master SDH clock divisor
;
