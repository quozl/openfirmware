\ In MMP3, the SCLK_SOURCE_SELECT field moved from bit 30 to bit 29,
\ so the high nibble changed from 4 (MMP2) to 2 (MMP3) for the same
\ field value 1.
[ifdef] mmp3  h# 20001102  [else]  h# 40001102  [then]  value clkdiv  \ Display Clock 1 / 2 -> 56.93 MHz

h# 00000700 value pmua-disp-clk-sel  \ PLL1 / 7 -> 113.86 MHz

d#    8 value hsync  \ Sync width
d# 1200 value hdisp  \ Display width
d# 1256 value htotal \ Display + FP + Sync + BP
d#   24 value hbp    \ Back porch

d#    3 value vsync  \ Sync width
d#  900 value vdisp  \ Display width
d#  912 value vtotal \ Display + FP + Sync + BP
d#    5 value vbp    \ Back porch

2 value #lanes
2 value bytes/pixel
d# 16 value bpp

0 [if]  \ 24bpp parameters
3 to #lanes
3 to bytes/pixel
d# 24 to bpp
[then]
