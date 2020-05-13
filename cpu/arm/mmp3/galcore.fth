purpose: Device nodes for GALCORE graphics accelerator

h# d420.d000 constant gpu-3d-pa  \ Base of 3D GPU
h# d420.f000 constant gpu-2d-pa  \ Base of 2D GPU
h#      1000 constant /gpu

dev /
new-device
   " gpu" device-name
   " mrvl,galcore" +compatible
   " vivante,gc" +compatible
   gpu-3d-pa /gpu reg
   0 encode-int " interrupts" property
   " /interrupt-controller/interrupt-controller@1c0" encode-phandle " interrupt-parent" property

   " /clocks" encode-phandle mmp2-gpu-3d-clk# encode-int encode+
      " /clocks" encode-phandle encode+ mmp2-gpu-3d-clk# encode-int encode+
      " /clocks" encode-phandle encode+ mmp2-gpu-bus-clk# encode-int encode+
      " clocks" property
   " GCCLK" encode-string
      " core" encode-string encode+
      " bus" encode-string encode+
      " clock-names" property

   " /clocks" encode-phandle mmp2-gpu-pd# encode-int encode+
      " power-domains" property
finish-device

new-device
   " gpu" device-name
   " vivante,gc" +compatible
   gpu-2d-pa /gpu reg
   2 encode-int " interrupts" property
   " /interrupt-controller/interrupt-controller@1c0" encode-phandle " interrupt-parent" property

   " /clocks" encode-phandle mmp3-gpu-2d-clk# encode-int encode+
      " /clocks" encode-phandle encode+ mmp2-gpu-bus-clk# encode-int encode+
      " clocks" property
   " core" encode-string
      " bus" encode-string encode+
      " clock-names" property

   " /clocks" encode-phandle mmp2-gpu-pd# encode-int encode+
      " power-domains" property
finish-device
device-end
