create use-null-nvram
create use-elf

fload ${BP}/cpu/arm/mmp3/soc-config.fth
fload ${BP}/cpu/arm/mmp2/hwaddrs.fth
fload ${BP}/cpu/arm/olpc/addrs.fth
fload ${BP}/cpu/arm/mmp3/ariel/gpiopins.fth

h# 40.0000 constant /rom  \ Total size of SPI FLASH

: crc-offset        /rom h# 30 -        ;  \ e.g. 3f.ffd0
: signature-offset  crc-offset  h# 10 - ;  \ e.g. 3e.ffc0
: signature$        " Ariel"            ;

d# 4154 constant machine-type  \ MACH_QSEVEN
