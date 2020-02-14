purpose: Generic Interrupt Controller node for Marvell MMP3

0 0  " e0001000"  " /" begin-package
  " interrupt-controller" device-name
  " arm,arm11mp-gic" +compatible
  0 0 " interrupt-controller" property
  1 " #address-cells" integer-property
  1 " #size-cells" integer-property
  3 " #interrupt-cells" integer-property
  h# e0001000 encode-int  h# 1000 encode-int encode+
  h# e0000100 encode-int encode+  h# 100 encode-int encode+  " reg" property

  : encode-unit  ( phys -- adr len )  push-hex (u.) pop-base  ;
  : decode-unit  ( adr len -- phys )  push-hex $number if 0  then pop-base  ;
end-package

0 0  " e0000600" " /" begin-package
   " local-timer" device-name
   " arm,arm11mp-twd-timer" +compatible
   my-address my-space  h# 20 reg

   1 encode-int \ Per-processor interrupt
      d# 13 encode-int encode+
      h# 301 encode-int encode+ \ GIC_CPU_MASK_SIMPLE(2) | IRQ_TYPE_EDGE_RISING
      " interrupts" property
end-package

0 0  " e0000620" " /" begin-package
   " watchdog" device-name
   " arm,arm11mp-twd-wdt" +compatible
   my-address my-space  h# 20 reg

   1 encode-int \ Per-processor interrupt
      d# 14 encode-int encode+
      h# 301 encode-int encode+ \ GIC_CPU_MASK_SIMPLE(2) | IRQ_TYPE_EDGE_RISING
      " interrupts" property
end-package

: gicparent ( -- )
   " interrupt-parent" delete-property
   " /interrupt-controller@e0001000" encode-phandle " interrupt-parent" property
;

dev /                           gicparent  dend
dev /interrupt-controller@128   gicparent  dend
dev /interrupt-controller@150   gicparent  dend
dev /interrupt-controller@154   gicparent  dend
dev /interrupt-controller@158   gicparent  dend
dev /interrupt-controller@15c   gicparent  dend
dev /interrupt-controller@160   gicparent  dend
dev /interrupt-controller@184   gicparent  dend
dev /interrupt-controller@188   gicparent  dend
dev /interrupt-controller@1bc   gicparent  dend
dev /interrupt-controller@1c0   gicparent  dend
dev /interrupt-controller@1c4   gicparent  dend
dev /interrupt-controller@1c8   gicparent  dend
dev /interrupt-controller@1cc   gicparent  dend
dev /interrupt-controller@1d0   gicparent  dend

: irqdef ( irq# -- )
   " interrupts" delete-property
   0 encode-int
   rot encode-int encode+
   4 encode-int encode+
   " interrupts" property
;

\ modify irqs to use 3 cells instead of 1
dev /timer                      h# 0d irqdef  dend
dev /usb@d4208000               h# 2c irqdef  dend
[ifdef] olpc
   dev /sspa                    h# 03 irqdef  dend
   dev /ap-sp                   h# 28 irqdef  dend
   dev /flash                   h# 00 irqdef  dend
   dev /ec-spi                  h# 14 irqdef  dend
[else]
   dev /spi@d4035000            h# 00 irqdef  dend
   dev /spi@d4036000            h# 01 irqdef  dend
   dev /spi@d4037000            h# 14 irqdef  dend
   dev /spi@d4039000            h# 15 irqdef  dend
   dev /usb@f0001000            h# 16 irqdef  dend
[then]
dev /sd/sdhci@d4280000          h# 27 irqdef  dend
dev /sd/sdhci@d4280800          h# 34 irqdef  dend
dev /sd/sdhci@d4281000          h# 35 irqdef  dend
dev /sd/sdhci@d4281800          h# 36 irqdef  dend
dev /display                    h# 29 irqdef  dend
dev /vmeta                      h# 1a irqdef  dend
dev /uart@d4016000              h# 2e irqdef  dend
dev /uart@d4030000              h# 1b irqdef  dend
dev /uart@d4017000              h# 1c irqdef  dend
dev /uart@d4018000              h# 18 irqdef  dend
dev /i2c@d4011000               h# 07 irqdef  dend
dev /dma                        h# 30 irqdef  dend
dev /gpio                       h# 31 irqdef  dend
dev /interrupt-controller@128   d# 48 irqdef  dend
dev /interrupt-controller@150   d#  4 irqdef  dend
dev /interrupt-controller@154   d#  5 irqdef  dend
dev /interrupt-controller@158   d# 17 irqdef  dend
dev /interrupt-controller@15c   d# 35 irqdef  dend
dev /interrupt-controller@160   d# 51 irqdef  dend
dev /interrupt-controller@184   d# 55 irqdef  dend
dev /interrupt-controller@188   d# 57 irqdef  dend
dev /interrupt-controller@1bc   d#  6 irqdef  dend
dev /interrupt-controller@1c0   d#  8 irqdef  dend
dev /interrupt-controller@1c4   d# 18 irqdef  dend
dev /interrupt-controller@1c8   d# 30 irqdef  dend
dev /interrupt-controller@1cc   d# 42 irqdef  dend
dev /interrupt-controller@1d0   d# 58 irqdef  dend

\ Enable the TWD timer
\ PMUA_CC3_PJ |= PJ4_MP_TIMER_RST | PJ4_MP_TIMER_CLK_EN
standalone? if  h# 18 h# 188 pmua-set  then

: mmp3-gic  ;  \ 92ms
