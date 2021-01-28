purpose: SMSC LAN7500 USB Ethernet Driver
\ See license at end of file

headers

\ Register I/O

variable usb-val

: error?  ( flag -- )  ?dup if  ." usb error: " . cr  abort  then  ;

h# a0 constant SET_REG
h# a1 constant GET_REG

: lan7500@  ( index -- u )
   usb-val  4  rot  0  DR_IN DR_VENDOR DR_DEVICE or or  GET_REG  control-get
   error? drop
   usb-val l@
;

: lan7500!  ( u index -- )
   swap usb-val l! ( index )
   usb-val  4  rot  0  DR_OUT DR_VENDOR DR_DEVICE or or  SET_REG  control-set
   error?
;

\ Interface to the configuration EEPROM

h# 040 constant e2p-cmd
: epc-busy+        h# 8000.0000 or  ;
: epc-timeout+     h# 0000.0400 or  ;
: epc-read+        h# 0000.0000 or  ;
h# 044 constant e2p-data

: lan7500-eeprom-ready  ( -- )
   begin
      e2p-cmd lan7500@
      0 epc-busy+ epc-timeout+
   and 0= until
;

: lan7500-eeprom@ ( index -- u )
   lan7500-eeprom-ready
   epc-busy+ epc-read+ e2p-cmd lan7500!
   lan7500-eeprom-ready
   e2p-data lan7500@
;

: lan7500-get-mac-address ( -- adr len )
   h# a5  0 lan7500-eeprom@ = if
      6 0 do
         i 1+ lan7500-eeprom@
         mac-adr i + !
      loop
   else
      ." Serial EEPROM with MAC address is not present." cr
   then
   mac-adr /mac-adr
;

\ MII interface to the PHY

1 value phyid

h# 120 constant mii-acc
: mii-busy+        h# 0000.0001 or  ;
: mii-read+        h# 0000.0000 or  ;
: mii-write+       h# 0000.0002 or  ;
h# 124 constant mii-data

: lan7500-phy-ready  ( -- )
   begin
      mii-acc lan7500@
   0 mii-busy+ and 0= until
;

: lan7500-mii@ ( index -- u )
   lan7500-phy-ready
   d# 6 <<  phyid d# 11 << or
      mii-busy+ mii-read+ mii-acc lan7500!
   lan7500-phy-ready
   mii-data lan7500@
;

: lan7500-mii! ( u index -- )
   lan7500-phy-ready      ( index u )
   swap                   ( index u )
   mii-data lan7500! ( index )
   lan7500-phy-ready
   d# 6 <<  phyid d# 11 << or
      mii-busy+ mii-write+ mii-acc lan7500!
;

: lan7500-link-up?  ( -- flag )
   1 lan7500-mii@  4 and 0<>
;

: lan7500-sync-link-status  ( -- )
    \ Delayed loop until link-up is detected.
    d# 500 0 do  lan7500-link-up? if  unloop exit  then  d# 10 ms  loop
;

: lan7500-start-phy ( -- )
    lan7500-sync-link-status
;

\ MAC interface

h# 090 constant rx-fifo
: rx-fifo-enable+  h# 8000.0000 or  ;

h# 094 constant tx-fifo
: tx-fifo-enable+  h# 8000.0000 or  ;

h# 104 constant mac-rx
: mac-rx-enable+   h# 0000.0001 or  ;
: strip-fcs+       h# 0000.0010 or  ;

h# 108 constant mac-tx
: mac-tx-enable+   h# 0000.0001 or  ;

: lan7500-start-mac  ( -- )
   0 mac-tx-enable+ mac-tx lan7500!
   0 tx-fifo-enable+ tx-fifo lan7500!

   max-frame-size 16 <<
      strip-fcs+ mac-rx-enable+ mac-rx lan7500!
   0 rx-fifo-enable+ rx-fifo lan7500!
;

\ Packet data wrapping and unwrapping

: tx-fcs+  h# 0040.0000 or  ;

: lan7500-length-header  ( adr len -- hdrlen )
   tx-fcs+ over l!       ( adr )
   4 + 0 swap l!         ( )
   8                     ( hdrlen )
;

: lan7500-unwrap-msg     ( adr len -- adr' len'  )
   d# 10 <  if  ." Short read" 0 0 exit  then  ( adr )
   dup @ h# 3fff and 2-  ( adr len' )
   swap d# 10 + swap     ( adr' len' )
;

\ Initialization

h# 0010 constant hw-cfg
: nak-empty-in+    h# 0000.0080 or  ;
h# 0060 constant rfe-ctl
: accept-bcast+    h# 0000.0400 or  ;
: accept-mcast+    h# 0000.0200 or  ;
: accept-ucast+    h# 0000.0100 or  ;

: lan7500-init-nic ( -- )
    0 nak-empty-in+ hw-cfg lan7500!
    0 accept-bcast+ accept-mcast+ accept-ucast+ rfe-ctl lan7500!

    lan7500-get-mac-address  2drop
    lan7500-sync-link-status
;

: init-lan7500  ( -- )
    ['] lan7500-get-mac-address to get-mac-address
    ['] lan7500-mii@ to mii@
    ['] lan7500-mii! to mii!
    ['] lan7500-link-up?  to link-up?
    ['] lan7500-start-phy to start-phy
    ['] lan7500-start-mac to start-mac
    ['] lan7500-length-header to length-header
    ['] lan7500-unwrap-msg to unwrap-msg
    ['] lan7500-init-nic  to init-nic
;

: init  ( -- )
   init
   vid pid net-lan7500?  if
      init-lan7500
   then
;

\ LICENSE_BEGIN
\ Copyright (c) 2020 Lubomir Rintel <lkundrak@v3.sk>
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
