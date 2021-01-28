purpose: CPU node
\ See license at end of file

decimal

headers
' cpu-node  " cpu" chosen-variable

0 0  " "  " /"  begin-package
" cpus" device-name
1 " #address-cells" integer-property
0 " #size-cells" integer-property
" marvell,mmp3-smp" " enable-method" string-property

: decode-unit  ( adr len -- phys )  $number  if  0  then  ;
: encode-unit  ( phys -- adr len )  (u.)  ;

: open  ( -- true )  true  ;
: close  ( -- )  ;

new-device
   " cpu" device-name
   " cpu" device-type
   " marvell,pj4b" +compatible
   0 " reg" integer-property
   " /l2-cache-controller" encode-phandle " next-level-cache" property

   : open true ;
   : close ;

finish-device

new-device
   " cpu" device-name
   " cpu" device-type
   " marvell,pj4b" +compatible
   1 " reg" integer-property
   " /l2-cache-controller" encode-phandle " next-level-cache" property

   : open true ;
   : close ;
finish-device

end-package

stand-init: CPU nodes
   " /cpus/cpu@0" open-dev cpu-node !
;
\ LICENSE_BEGIN
\ Copyright (c) 2006 FirmWorks
\ Copyright (c) 2019 Lubomir Rintel <lkundrak@v3.sk>
\
\ Permission is hereby granted, free of charge, to any person obtaining
\ a copy of this software and associated documentation files (the
\ "Software"), to deal in the Software without restriction, including
\ without limitation the rights to use, copy, modify, merge, publish,
\ distribute, sublicense, and/or sell copies of the Software, and to
\ permit persons to whom the Software is furnished to do so, subject to
\ the following conditions:
\
\ The above copyright notice and this permission notice shall be
\ included in all copies or substantial portions of the Software.
\
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
\ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
\ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
\ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
\ LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
\ OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
\ WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
\
\ LICENSE_END
