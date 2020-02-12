purpose: Device tree nodes for SPI buses implemented by SSP hardware

0 0  " d4035000"  " /" begin-package
   " spi" name
   " /clocks" encode-phandle mmp2-ssp0-clk# encode-int encode+ " clocks" property
   d# 0 " interrupts" integer-property
   fload ${BP}/cpu/arm/mmp2/ssp-node.fth
end-package

0 0  " d4036000"  " /" begin-package
   " spi" name
   " /clocks" encode-phandle mmp2-ssp1-clk# encode-int encode+ " clocks" property
   d# 1 " interrupts" integer-property
   fload ${BP}/cpu/arm/mmp2/ssp-node.fth
end-package

0 0  " d4037000"  " /" begin-package
   " spi" name
   " /clocks" encode-phandle mmp2-ssp2-clk# encode-int encode+ " clocks" property
   d# 20 " interrupts" integer-property
   fload ${BP}/cpu/arm/mmp2/ssp-node.fth
end-package

0 0  " d4039000"  " /" begin-package
   " spi" name
   " /clocks" encode-phandle mmp2-ssp3-clk# encode-int encode+ " clocks" property
   d# 21 " interrupts" integer-property
   fload ${BP}/cpu/arm/mmp2/ssp-node.fth
end-package
