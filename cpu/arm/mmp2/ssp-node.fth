purpose: Create a device node for a SSP device

: decode-unit  ( adr len -- n )  parse-int  ;
: encode-unit  ( n -- adr len )  push-hex (u.) pop-base  ;

my-address my-space h# 1000 reg
1 encode-int " #address-cells"  property
0 encode-int " #size-cells"  property
" marvell,mmp2-ssp" +compatible

: open  ( -- okay? ) true ;
: close  ( -- ) ;
