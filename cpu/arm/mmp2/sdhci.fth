purpose: Load file for SDHCI (Secure Digital Host Controller Interface)

0 0  " "  " /"  begin-package
   fload ${BP}/cpu/arm/olpc/sdregs.fth
   fload ${BP}/dev/mmc/sdhci/sdhci.fth

   " simple-bus" +compatible
   h# d4280000 encode-int  h# d4280000 encode-int encode+  h# 2000 encode-int encode+
   h# d4217000 encode-int encode+  h# d4217000 encode-int encode+  h# 800 encode-int encode+
" ranges" property
   1 " #address-cells" integer-property
   1 " #size-cells" integer-property

   d# 30 to power-off-time   \ Time for the voltage to decay
\   true to avoid-high-speed?

   new-device
      h# d428.0000 h# 800 reg
      " sdhci-pxav3" +compatible
      " mrvl,pxav3-mmc" +compatible
      d# 39 " interrupts" integer-property
      " /clocks" encode-phandle mmp2-sdh0-clk# encode-int encode+ " clocks" property
      " io" " clock-names" string-property
      fload ${BP}/dev/mmc/sdhci/slot.fth
   finish-device

   new-device
      h# d428.0800 h# 800 reg
      " sdhci-pxav3" +compatible
      " mrvl,pxav3-mmc" +compatible
      d# 52 " interrupts" integer-property
      " /clocks" encode-phandle mmp2-sdh1-clk# encode-int encode+ " clocks" property
      " io" " clock-names" string-property
      fload ${BP}/dev/mmc/sdhci/slot.fth
   finish-device

   new-device
      h# d428.1000 h# 800 reg
      " sdhci-pxav3" +compatible
      " mrvl,pxav3-mmc" +compatible
      d# 53 " interrupts" integer-property
      " /clocks" encode-phandle mmp2-sdh2-clk# encode-int encode+ " clocks" property
      " io" " clock-names" string-property
      fload ${BP}/dev/mmc/sdhci/slot.fth
   finish-device

   new-device
      h# d428.1800 h# 800 reg
      " sdhci-pxav3" +compatible
      " mrvl,pxav3-mmc" +compatible
      d# 54 " interrupts" integer-property
      " /clocks" encode-phandle mmp2-sdh3-clk# encode-int encode+ " clocks" property
      " io" " clock-names" string-property
      fload ${BP}/dev/mmc/sdhci/slot.fth
   finish-device

[ifdef] mmp3
   new-device
      h# d421.7000 h# 800 reg
      " sdhci-pxav3" +compatible
      " mrvl,pxav3-mmc" +compatible
      " /interrupt-controller@184" encode-phandle " interrupt-parent" property
      d# 0 " interrupts" integer-property
      " /clocks" encode-phandle mmp3-sdh4-clk# encode-int encode+ " clocks" property
      " io" " clock-names" string-property
      fload ${BP}/dev/mmc/sdhci/slot.fth
   finish-device
[then]
end-package

stand-init: SDHC clocks
   h# 400 h# 54 pmua!    \ Master SDH clock divisor
;
