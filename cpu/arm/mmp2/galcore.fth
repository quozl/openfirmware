purpose: Device node for GALCORE graphics accelerator

h# d420.d000 constant gpu-pa  \ Base of GPU
h#      1000 constant /gpu

dev /
new-device
   " gpu" device-name
   " mrvl,galcore" +compatible
   gpu-pa /gpu reg
   8 encode-int " interrupts" property
   " /interrupt-controller" encode-phandle " interrupt-parent" property
   " galcore 2D" encode-string " interrupt-names" property

   " /clocks" encode-phandle mmp2-gc-clk# encode-int encode+ " clocks" property
   " GCCLK" " clock-names" string-property
finish-device
device-end
