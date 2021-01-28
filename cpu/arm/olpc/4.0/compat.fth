purpose: Adjust the device tree for compatiblity with OLPC 3.5 kernel

\ Based in part by what used to be in cpu/arm/mmp2/apbc.fth,
\ cpu/arm/mmp2/pmua.fth and cpu/arm/olpc/1.75/lcdcfg.fth.

: +string       encode-string encode+  ;
: +i            encode-int encode+ ;
: encode-/apbc  " /apbc" encode-phandle ;
: encode-/pmua  " /pmua" encode-phandle ;
: clkdef        " clocks" delete-property " clocks" property ;

root-device
   [ifndef] olpc  " olpc,xo-cl4" +compatible  [then]

   new-device
      " apbc" name
      " mrvl,pxa-apbc" +compatible
      " marvell,mmp3-apbc" +compatible

      h# d4015000 h# 1000 reg
      1 " #clock-cells" integer-property

      0 0 encode-bytes
      " RTC"       +string  \ 00
      " TWSI1"     +string  \ 01
      " TWSI2"     +string  \ 02
      " TWSI3"     +string  \ 03
      " TWSI4"     +string  \ 04
      " ONEWIRE"   +string  \ 05
      " KPC"       +string  \ 06
      " TB_ROTARY" +string  \ 07
      " SW_JTAG"   +string  \ 08
      " TIMERS1"   +string  \ 09
      " UART1"     +string  \ 10
      " UART2"     +string  \ 11
      " UART3"     +string  \ 12
      " GPIO"      +string  \ 13
      " PWM0"      +string  \ 14
      " PWM1"      +string  \ 15
      " PWM2"      +string  \ 16
      " PWM3"      +string  \ 17
      " SSP0"      +string  \ 18
      " SSP1"      +string  \ 19
      " SSP2"      +string  \ 20
      " SSP3"      +string  \ 21
      " SSP4"      +string  \ 22
      " SSP5"      +string  \ 23
      " AIB"       +string  \ 24
      " ASFAR"     +string  \ 25
      " ASSAR"     +string  \ 26
      " USIM"      +string  \ 27
      " MPMU"      +string  \ 28
      " IPC"       +string  \ 29
      " TWSI5"     +string  \ 30
      " TWSI6"     +string  \ 31
      " UART4"     +string  \ 32
      " RIPC"      +string  \ 33
      " THSENS1"   +string  \ 34
      " CORESIGHT" +string  \ 35
      " THSENS2"   +string  \ 36
      " THSENS3"   +string  \ 37
      " THSENS4"   +string  \ 38
      " clock-output-names" property

      0 0 encode-bytes
      \ offset  clr-mask  value     rate
      h# 00 +i  h# f7 +i  h# 83 +i  d#     32,768 +i  \ 00 RTC
      h# 04 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 01 TWSI1
      h# 08 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 02 TWSI2
      h# 0c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 03 TWSI3
      h# 10 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 04 TWSI4
      h# 14 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 05 ONEWIRE
      h# 18 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 06 KPC
      h# 1c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 07 TB_ROTARY
      h# 20 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 08 SW_JTAG
      h# 24 +i  h# 77 +i  h# 13 +i  d#  6,500,000 +i  \ 09 TIMERS1
      h# 2c +i  h# 77 +i  h# 13 +i  d# 26,000,000 +i  \ 10 UART1
      h# 30 +i  h# 77 +i  h# 13 +i  d# 26,000,000 +i  \ 11 UART2
      h# 34 +i  h# 77 +i  h# 13 +i  d# 26,000,000 +i  \ 12 UART3
      h# 38 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 13 GPIO
      h# 3c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 14 PWM0
      h# 40 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 15 PWM1
      h# 44 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 16 PWM2
      h# 48 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 17 PWM3
      h# 4c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 18 SSP0
      h# 50 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 19 SSP1
      h# 54 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 20 SSP2
      h# 58 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 21 SSP3
      h# 5c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 22 SSP4
      h# 60 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 23 SSP5
      h# 64 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 24 AIB
      h# 68 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 25 ASFAR
      h# 6c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 26 ASSAR
      h# 70 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 27 USIM
      h# 74 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 28 MPMU
      h# 78 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 29 IPC
      h# 7c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 30 TWSI5
      h# 80 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 31 TWSI6
      h# 88 +i  h# 77 +i  h# 13 +i  d# 26,000,000 +i  \ 32 UART4
      h# 8c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 33 RIPC
      h# 90 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 34 THSENS1
      h# 94 +i  h#  7 +i  h#  3 +i  d# 26,000,000 +i  \ 35 CORESIGHT
      h# 98 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 36 THSENS2
      h# 9c +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 37 THSENS3
      h# a0 +i  h# 77 +i  h#  3 +i  d# 26,000,000 +i  \ 38 THSENS4
      " clock-enable-registers" property
   finish-device

   new-device
      " pmua" name
      " mrvl,pxa-apmu" +compatible
      " marvell,mmp3-apmu" +compatible

      h# d4282800 h# 1000 reg
      1 " #clock-cells" integer-property

      0 0 encode-bytes
      " IRE"      +string \ 0
      " DISPLAY1" +string \ 1
      " CCIC"     +string \ 2
      " SDH1"     +string \ 3
      " SDH2"     +string \ 4
      " USB"      +string \ 5
      " NF"       +string \ 6
      " DMA"      +string \ 7
      " WTM"      +string \ 8
      " BUS"      +string \ 9
      " VMETA"    +string \ 10
      " GC"       +string \ 11
      " SMC"      +string \ 12
      " MSPRO"    +string \ 13
      " SDH3"     +string \ 14
      " SDH4"     +string \ 15
      " CCIC2"    +string \ 16
      " HSIC1"    +string \ 17
      " FSIC3"    +string \ 18
      " HSI"      +string \ 19
      " AUDIO"    +string \ 20
      " DISPLAY2" +string \ 21
      " ISP"      +string \ 22
      " EPD"      +string \ 23
      " APB2"     +string \ 24
      " SPMI"     +string \ 25
      " USB3SS"   +string \ 26
      " SDH5"     +string \ 27
      " DSA"      +string \ 28
      " TPIU"     +string \ 29
      " HSIC2"    +string \ 30
      " SLIM"     +string \ 31
      " FASTENET" +string \ 32
      " clock-output-names" property

      0 0 encode-bytes
      \ offset   clr-mask     value       rate
      h# 048 +i  h#    19 +i  h#   19 +i  d#           0 +i  \ 0 IRE
      h# 04c +i  h# fffff +i  h#  71b +i  d# 400,000,000 +i  \ 1 DISPLAY1
      h# 050 +i  h#    3f +i  h#   3f +i  d#           0 +i  \ 2 CCIC
      h# 054 +i  h#    1b +i  h#  41b +i  d# 200,000,000 +i  \ 3 SDH1
      h# 058 +i  h#    1b +i  h#   1b +i  d# 200,000,000 +i  \ 4 SDH2
      h# 05c +i  h#    09 +i  h#   09 +i  d# 480,000,000 +i  \ 5 USB
      h# 060 +i  h#   1ff +i  h#   bf +i  d# 100,000,000 +i  \ 6 NF
      h# 064 +i  h#    09 +i  h#   09 +i  d#           0 +i  \ 7 DMA
      h# 068 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 8 WTM
      h# 06c +i  h#    01 +i  h#   01 +i  d#           0 +i  \ 9 BUS
      h# 0a4 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 10 VMETA
      h# 0cc +i  h#    0f +i  h#   0f +i  d#           0 +i  \ 11 GC
      h# 0d4 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 12 SMC
      h# 0d8 +i  h#    3f +i  h#   3f +i  d#           0 +i  \ 13 MSPRO - MMP2 only, but left in table to preserve numbering
      h# 0e8 +i  h#    1b +i  h#   1b +i  d# 200,000,000 +i  \ 14 SDH3
      h# 0ec +i  h#    1b +i  h#   1b +i  d# 200,000,000 +i  \ 15 SDH4
      h# 0f4 +i  h#    3f +i  h#   3f +i  d#           0 +i  \ 16 CCIC2
      h# 0f8 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 17 HSIC1
      h# 100 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 18 FSIC3
      h# 108 +i  h#    09 +i  h#   09 +i  d#           0 +i  \ 19 HSI
      h# 10c +i  h#    13 +i  h#   13 +i  d#           0 +i  \ 20 AUDIO
      h# 110 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 21 DISPLAY2
      h# 120 +i  h#    3f +i  h#   3f +i  d#           0 +i  \ 22 ISP
      h# 124 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 23 EPD
      h# 134 +i  h#    12 +i  h#   12 +i  d#           0 +i  \ 24 APB2
      h# 140 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 25 SPMI - XXX may need to set clock divisor bits
      h# 148 +i  h#     9 +i  h#    9 +i  d#           0 +i  \ 26 USB3SS
      h# 15c +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 27 SDH5
      h# 164 +i  h#     f +i  h#    f +i  d#           0 +i  \ 28 DSA xx
      h# 18c +i  h#    12 +i  h#   12 +i  d#           0 +i  \ 29 TPIU
      h# 0f8 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 30 HSIC2
      h# 104 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 31 SLIM - XXX check bits
      h# 210 +i  h#    1b +i  h#   1b +i  d#           0 +i  \ 32 FASTENET
      " clock-enable-registers" property
   finish-device
dend

dev /uart@d4018000  " mrvl,mmp-uart" +compatible  dend
dev /uart@d4017000  " mrvl,mmp-uart" +compatible  dend
dev /uart@d4030000  " mrvl,mmp-uart" +compatible  dend
dev /uart@d4016000  " mrvl,mmp-uart" +compatible  dend

dev /timer@d4014000       encode-/apbc  d#  9 +i clkdef  dend
dev /gpio@d4019000        encode-/apbc  d# 13 +i clkdef  dend
dev /i2c@d4011000         encode-/apbc  d#  1 +i clkdef  dend
dev /i2c@d4031000         encode-/apbc  d#  2 +i clkdef  dend
dev /i2c@d4032000         encode-/apbc  d#  3 +i clkdef  dend
dev /i2c@d4033000         encode-/apbc  d#  4 +i clkdef  dend
dev /i2c@d4033800         encode-/apbc  d# 30 +i clkdef  dend
dev /i2c@d4034000         encode-/apbc  d# 31 +i clkdef  dend
dev /uart@d4018000        encode-/apbc  d# 12 +i clkdef  dend
dev /uart@d4017000        encode-/apbc  d# 11 +i clkdef  dend
dev /uart@d4030000        encode-/apbc  d# 10 +i clkdef  dend
dev /uart@d4016000        encode-/apbc  d# 32 +i clkdef  dend
dev /vmeta@f0400000       encode-/pmua  d# 10 +i clkdef  dend
dev /gpu@d420d000         encode-/pmua  d# 11 +i clkdef  dend
dev /sd/sdhci@d4280000    encode-/pmua  d#  3 +i clkdef  dend
dev /sd/sdhci@d4280800    encode-/pmua  d#  4 +i clkdef  dend
dev /sd/sdhci@d4281000    encode-/pmua  d# 14 +i clkdef  dend
dev /sd/sdhci@d4281800    encode-/pmua  d# 15 +i clkdef  dend
dev /sd/sdhci@d4217000    encode-/pmua  d# 27 +i clkdef  dend
dev /usb@d4208000         encode-/pmua  d#  5 +i clkdef  dend
dev /thermal@d403b000     encode-/apbc  d# 34 +i
                          encode-/apbc encode+  d# 36 +i
                          encode-/apbc encode+  d# 37 +i
                          encode-/apbc encode+  d# 38 +i
                                                 clkdef  dend
dev /wakeup-rtc@d4010000  encode-/apbc  d#  0 +i clkdef  dend
[ifdef] olpc
   dev /flash             encode-/apbc  d# 18 +i clkdef  dend
   dev /ec-spi            encode-/apbc  d# 20 +i clkdef  dend
   dev /camera@d420a000   encode-/pmua  d#  2 +i clkdef  dend
   dev /sspa@c0ffdd00     encode-/pmua  d# 20 +i clkdef  dend
   dev /audio@c0ffdc00    encode-/pmua  d# 20 +i clkdef  dend
[else]
   dev /spi@d4035000      encode-/apbc  d# 18 +i clkdef  dend
   dev /spi@d4036000      encode-/apbc  d# 19 +i clkdef  dend
   dev /spi@d4037000      encode-/apbc  d# 20 +i clkdef  dend
   dev /spi@d4039000      encode-/apbc  d# 21 +i clkdef  dend
   dev /usb@f0001000      encode-/pmua  d# 17 +i clkdef  dend
[then]

: hfp  htotal hdisp - hsync - hbp - ;
: vfp  vtotal vdisp - vsync - vbp - ;

dev /display@d420b000
   encode-/pmua  d#  1 +i clkdef
   " clock-names" delete-property
   " LCDCLK" " clock-names" string-property
dend

dev /display@d420b000/port
   \ " panel" name
   " mrvl,dumb-panel" +compatible
   " OLPC DCON panel" model

   0 0 encode-bytes
   hdisp +i  vdisp +i  d# 50 +i  d# 56,930,000 +i
      hbp +i  hfp +i  vbp +i  vfp +i  hsync +i  vsync +i
      0 +i  d# 152 +i  d# 115 +i
      " linux,timing-modes" property

   " 1200x900@50" " linux,mode-names" string-property

   bpp d# 24 >=  if  h# 6000000d  else  h# 2000000d  then
      " lcd-dumb-ctrl-regval" integer-property

   bpp d# 32 =  if  h# 00040000  then
   bpp d# 24 =  if  h# 00020000  then
      h# 08001100 or  " lcd-pn-ctrl0-regval"  integer-property

   h# 20001102 " clock-divider-regval" integer-property
dend

: olpc-compat  ;
