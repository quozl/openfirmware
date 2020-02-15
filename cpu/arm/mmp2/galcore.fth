purpose: Device node for GALCORE graphics accelerator

h# d420.d000 constant gpu-pa  \ Base of GPU
h#      1000 constant /gpu

dev /
new-device
   " gpu" device-name
   " vivante,gc" +compatible
   gpu-pa /gpu reg
   8 encode-int " interrupts" property
   " /interrupt-controller" encode-phandle " interrupt-parent" property

   " /clocks" encode-phandle mmp2-gpu-3d-clk# encode-int encode+
   " /clocks" encode-phandle encode+ mmp2-gpu-bus-clk# encode-int encode+
   " clocks" property

   " core" encode-string
   " bus" encode-string encode+
   " clock-names" property

   " /clocks" encode-phandle mmp2-gpu-power-domain# encode-int encode+
   " power-domains" property
finish-device
device-end
