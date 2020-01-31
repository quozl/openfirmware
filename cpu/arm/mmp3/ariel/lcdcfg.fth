h# 20001101 value clkdiv
h# 00000C00 value pmua-disp-clk-sel

d#  136 value hsync  \ Sync width
d# 1024 value hdisp  \ Display width
d# 1344 value htotal \ Display + FP + Sync + BP
d#  160 value hbp    \ Back porch

d#    6 value vsync  \ Sync width
d#  768 value vdisp  \ Display width
d#  806 value vtotal \ Display + FP + Sync + BP
d#   29 value vbp    \ Back porch

4 value #lanes
4 value bytes/pixel
d# 32 value bpp
