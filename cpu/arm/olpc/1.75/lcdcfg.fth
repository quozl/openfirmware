h# d102.0000 constant video-sram-pa  \ Base of Video SRAM
h#    1.0000 constant /video-sram

dev /
new-device
   " vsram" device-name
   video-sram-pa /video-sram reg

   " marvell,mmp-vsram" +compatible
   d# 64 " granularity" integer-property
finish-device
device-end

fload ${BP}/dev/olpc/panel.fth

[ifdef] has-dcon
fload ${BP}/dev/olpc/dcon/mmp2dcon.fth        \ DCON control

dev /panel
   " /dcon" encode-phandle  " control-node" property
device-end
[then]
