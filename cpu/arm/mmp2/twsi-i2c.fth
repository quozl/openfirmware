purpose: Device tree nodes for I2C buses implemented by TWSI hardware

\   baseadr  clk             irq mux?
h# d4011000  mmp2-twsi0-clk#   7 false fload ${BP}/cpu/arm/mmp2/twsi-node.fth  \ TWSI1
h# d4031000  mmp2-twsi1-clk#   0 true  fload ${BP}/cpu/arm/mmp2/twsi-node.fth  \ TWSI2
h# d4032000  mmp2-twsi2-clk#   1 true  fload ${BP}/cpu/arm/mmp2/twsi-node.fth  \ TWSI3
h# d4033000  mmp2-twsi3-clk#   2 true  fload ${BP}/cpu/arm/mmp2/twsi-node.fth  \ TWSI4
h# d4033800  mmp2-twsi4-clk#   3 true  fload ${BP}/cpu/arm/mmp2/twsi-node.fth  \ TWSI5
h# d4034000  mmp2-twsi5-clk#   4 true  fload ${BP}/cpu/arm/mmp2/twsi-node.fth  \ TWSI6
