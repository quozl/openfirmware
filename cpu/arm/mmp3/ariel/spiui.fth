purpose: User interface for reflashing SPI FLASH parts
\ See license at end of file

\ This code is concerned with the user interface for getting
\ a new firmware image into memory and using it to program
\ a FLASH device from that image.  The details of how to actually
\ access the FLASH device are defined elsewhere.

h# 4000 constant /chunk   \ Convenient sized piece for progress reports

defer spi-progress  ' 2drop to spi-progress  ( offset size -- )

: write-flash-range  ( adr end-offset start-offset -- )
   ." Writing" cr
   ?do                ( adr )
      \ Save time - don't write if the data is the same
      i .x (cr                              ( adr )
      spi-us d# 20 >=  if                   ( adr )
         \ Just write if reading is slow
         true                               ( adr must-write? )
      else                                  ( adr )
         dup  /flash-block  i  flash-verify ( adr must-write? )
      then                                  ( adr must-write? )

      if
         i flash-erase-block
         dup  /flash-block  i  flash-write  ( adr )
      then
      i /flash  spi-progress                ( adr )
      /flash-block +                        ( adr' )
   /flash-block +loop                       ( adr )
   cr  drop           ( )
;

: verify-flash-range  ( adr end-offset start-offset -- )
   ." Verifying" cr
   ?do                ( adr )
      i .x (cr
      dup   /flash-block  i  flash-verify   abort" Verify failed"
      /flash-block +  ( adr' )
   /flash-block +loop ( adr )
   cr  drop           ( )
;


\ Perform a series of sanity checks on the new firmware image.

0 value file-loaded?

: crc  ( adr len -- crc )  0 crctab  2swap ($crc)  ;

: ?crc  ( -- )
   ." Checking integrity ..." cr

   flash-buf crc-offset +            ( crc-adr )
   dup l@  >r                        ( crc-adr r: crc )
   -1 over l!                        ( crc-adr r: crc )

   flash-buf /flash crc              ( crc-adr calc-crc r: crc )
   r@ rot l!                         ( calc-crc r: crc )
   r> <>  abort" Firmware image has bad internal CRC"
;

: ?image-valid   ( len -- )
   /flash <> abort" Image file is the wrong length"

   flash-buf signature-offset +
   signature$ comp  abort" Wrong machine signature"

   ?crc
;

: $get-file  ( "filename" -- )
   $read-open
   flash-buf  h# 40.0000  ifd @ fgets   ( len )
   ifd @ fclose

   ?image-valid

   true to file-loaded?
;

: ?file  ( -- )
   file-loaded?  0=  if
      ." You must first load a valid FLASH image file with" cr
      ."    get-file filename" cr
      abort
   then
;

: read-flash  ( "filename" -- )
   writing
   /flash  0  do
      i .x (cr
      flash-buf  i +  /chunk i  flash-read
   /chunk +loop
   flash-buf  /flash  ofd @ fputs
   ofd @ fclose
;

: verify  ( -- )  ?file  flash-buf  /flash  0  verify-flash-range  ;

: write-firmware   ( -- )
   flash-buf  /flash     0  write-flash-range      \ Write first part
;
: verify-firmware  ( -- )
   flash-buf  /flash  0  verify-flash-range     \ Verify first part
;

: .verify-msg  ( -- )
   ." Type verify if you want to verify the data just written."  cr
   ." Verification will take about 17 minutes if the host is running Linux" cr
   ." or about 5 minutes if the host is running OFW." cr
;

: reflash   ( -- )   \ Flash from data already in memory
   ?file
   flash-write-enable

   write-firmware

   spi-us d# 20 <  if
      ['] verify-firmware catch  if
         ." Verify failed.  Retrying once"  cr
         spi-identify
         write-firmware
         verify-firmware
      then
      /flash dup  spi-progress
      flash-write-disable
   else
      .verify-msg
   then
;

defer fw-filename$  ' null$ to fw-filename$

: get-file  ( ["filename"] -- )
   parse-word   ( adr len )
   dup 0=  if  2drop fw-filename$  then  ( adr len )
   ." Reading " 2dup type cr                     ( adr len )
   $get-file
;

: flash  ( ["filename"] -- )  get-file reflash  ;

: safe-flash-read  ( -- )
   flash-buf  /flash  0 flash-read
;

\ LICENSE_BEGIN
\ Copyright (c) 2006 FirmWorks
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
