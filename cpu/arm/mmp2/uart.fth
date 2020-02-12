purpose: Device tree nodes for UARTs

0 0  " d4018000"  " /" begin-package  \ UART3
   fload ${BP}/cpu/arm/mmp2/uart-node.fth
   " /clocks" encode-phandle mmp2-uart2-clk# encode-int encode+ " clocks" property
   d# 24 " interrupts" integer-property
end-package

0 0  " d4017000"  " /" begin-package  \ UART2
   fload ${BP}/cpu/arm/mmp2/uart-node.fth
   " /clocks" encode-phandle mmp2-uart1-clk# encode-int encode+ " clocks" property
   d# 28 " interrupts" integer-property
end-package

0 0  " d4030000"  " /" begin-package  \ UART1
   fload ${BP}/cpu/arm/mmp2/uart-node.fth
   d# 27 " interrupts" integer-property
   " /clocks" encode-phandle mmp2-uart0-clk# encode-int encode+ " clocks" property
end-package

0 0  " d4016000"  " /" begin-package  \ UART4
   fload ${BP}/cpu/arm/mmp2/uart-node.fth
   " /clocks" encode-phandle mmp2-uart3-clk# encode-int encode+ " clocks" property
   d# 46 " interrupts" integer-property
end-package
