fload ${BP}/cpu/arm/olpc/emmc.fth

dev /sdhci@d4280000  \ MMC1 - External SD
   d# 50000000 " clock-frequency" integer-property
   d# 31 " mrvl,clk-delay-cycles" integer-property
   0 0 encode-bytes " broken-cd" property
device-end

\ mmc1 is set in common code, always to the WLAN device
devalias mmc0 /sd/sdhci@d4281000  \ Primary boot device
devalias mmc2 /sd/sdhci@d4280000  \ External SD

devalias int /sd/sdhci@d4281000/disk
devalias ext /sd/sdhci@d4280000/disk
