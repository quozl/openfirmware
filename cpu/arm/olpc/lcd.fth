purpose: Display driver for OLPC ARM/MMP platforms
\ See license at end of file

0 0  " d420b000"  " /" begin-package
   " display" name
   my-address my-space h# 1000 reg

   " mrvl,pxa168fb" +compatible
   " marvell,armada-lcdc" +compatible
[ifdef] mmp3
   " marvell,mmp3-lcd" +compatible
[else]
   " marvell,mmp2-lcd" +compatible
[then]

   " periph" encode-string
   " ext_ref_clk0" encode-string encode+
   " clock-names" property

   " /clocks" encode-phandle mmp2-disp0-lcdc-clk# encode-int encode+
   " /clocks" encode-phandle encode+ mmp2-disp0-clk# encode-int encode+
   " clocks" property

   d# 41 " interrupts" integer-property

   new-device
      " port" device-name
      new-device
         " endpoint" device-name
         bpp d# 24 <  if  d# 18 " bus-width" integer-property  then
      finish-device
   finish-device

: hfp  ( -- n )  htotal hdisp -  hsync -  hbp -  ;  \ 24
: vfp  ( -- n )  vtotal vdisp -  vsync -  vbp -  ;  \ 4

: >bytes   ( pixels -- chunks )  bytes/pixel *  ;
: >chunks  ( pixels -- chunks )  >bytes #lanes /  ;

alias width  hdisp
alias height vdisp
alias depth  bpp
width >bytes constant /scanline  

: lcd@  ( offset -- l )  lcd-pa + io@  ;
: lcd!  ( l offset -- )  lcd-pa + io!  ;

: lcd-clock!  ( n -- )  pmua-disp-clk-sel + h# 4c pmua!  ;
: lcd-clocks-on  ( -- )
   \ Turn on clocks
   h# 08 lcd-clock!
   h# 09 lcd-clock!
   h# 19 lcd-clock!
   h# 1b lcd-clock!
;
: lcd-clocks-off  ( -- )  0 lcd-clock!  ;

: init-lcd  ( -- )
   lcd-clocks-on

   0                  h# 190 lcd!  \ Disable LCD DMA controller
   fb-mem-va >physical h# f4 lcd!  \ Frame buffer area 0
   0                   h# f8 lcd!  \ Frame buffer area 1
   hdisp bytes/pixel * h# fc lcd!  \ Pitch in bytes

   hdisp vdisp wljoin  dup h# 104 lcd!  dup h# 108 lcd!  h# 118 lcd!  \ size, size after zoom, disp

   htotal >chunks  vtotal wljoin  h# 114 lcd!  \ SPUT_V_H_TOTAL

   hfp >chunks  hbp >chunks  wljoin  h# 11c lcd!

   vfp vbp wljoin  h# 120 lcd!
   h# 2000FF00 h# 194 lcd!  \ DMA CTRL 1

   \ Dumb panel controller - 24 bit RGB888 on LDD[23:0] or 18 bit RGB666 on LDD[17:0]
   bpp d# 24 >=  if  h# 6000000d  else  h# 2000000d  then h# 1b8 lcd!

   h# 01330133 h# 13c lcd!  \ Panel VSYNC Pulse Pixel Edge Control
   clkdiv      h# 1a8 lcd!  \ Clock divider

   \ DMA CTRL 0 - enable DMA
   h# 08001100
   bpp d# 32 =  if  h# 00040000 or  then
   bpp d# 24 =  if  h# 00020000 or  then
   h# 190 lcd!
;

: normal-hsv  ( -- )
   \ The brightness range is from ffff (-255) to 00ff (255) - 8 bits sign-extended
   \ 0 is the median value
   h# 0000.4000 h# 1ac lcd!  \ Brightness.contrast  0 is normal brightness, 4000 is 1.0 contrast
   h# 2000.4000 h# 1b0 lcd!  \ Multiplier(1).Saturation(1)
   h# 0000.4000 h# 1b4 lcd!  \ HueSine(0).HueCosine(1)
;
: clear-unused-regs  ( -- )
   0 h# 0c4 lcd!   \ Frame 0 U
   0 h# 0c8 lcd!   \ Frame 0 V
   0 h# 0cc lcd!   \ Frame 0 Command
   0 h# 0d0 lcd!   \ Frame 1 Y
   0 h# 0d4 lcd!   \ Frame 1 U
   0 h# 0d8 lcd!   \ Frame 1 V
   0 h# 0dc lcd!   \ Frame 1 Command
   0 h# 0e4 lcd!   \ U and V pitch
   0 h# 130 lcd!   \ Color key Y
   0 h# 134 lcd!   \ Color key U
   0 h# 138 lcd!   \ Color key V
;

: centered  ( w h -- )
   hdisp third - 2/               ( w h x )    \ X centering offset
   vdisp third - 2/               ( w h x y )  \ Y centering offset
   wljoin h# 0e8 lcd!             ( w h )
   wljoin dup h# 0ec lcd!         ( h.w )  \ Source size
   h# 0f0 lcd!                    ( )      \ Zoomed size
;
: zoomed  ( w h -- )
   0 h# 0e8 lcd!                   ( w h )  \ No offset when zooming
   wljoin h# 0ec lcd!              ( )      \ Source size
   hdisp vdisp wljoin h# 0f0 lcd!  ( )      \ Zoom to fill screen
;

defer placement ' zoomed is placement

: set-video-alpha  ( 0..ff -- )
   8 lshift                ( xx00 )
   h# 194 lcd@             ( xx00 regval )
   h# ff00 invert and      ( xx00 regval' )
   or                      ( regval' )
   h# 194 lcd!             ( )
;

\ 0:RBG565 1:RGB1555 2:RGB888packed 3:RGB888unpacked 4:RGBA888
\ 5:YUV422packed 6:YUV422planar 7:YUV420planar 8:SmartPanelCmd
\ 9:Palette4bpp  A:Palette8bpp  B:RGB888A
: set-video-mode  ( mode -- )
   h# 190 lcd@             ( x00000 regval )
   h# f0.000e invert and   ( x00000 regval' )
   or                      ( regval' )
   h# 190 lcd!             ( )
;
: video-on  ( -- )  h# 190 lcd@ 1 or h# 190 lcd!  ;
: video-off  ( -- )  h# 190 lcd@ 1 invert and h# 190 lcd!  ;
: set-video-dma-adr  ( adr -- )  h# 0c0 lcd!  ;

defer foo ' noop to foo

: start-video  ( adr w h ycrcb? -- )
   >r                                    ( adr w h r: ycrcb? )
   clear-unused-regs  normal-hsv         ( adr w h r: ycrcb? )
   over bytes/pixel * h# 0e0 lcd!        ( adr w h r: ycrcb? )  \ Pitch - width * 2 bytes/pixel for RGB565, width for YCrCr4:2:2
   placement                             ( adr r: ycrcb? )
   set-video-dma-adr                     ( r: ycrcb? )  \ Video buffer
   r> if  h# 50.000e  else  0  then  set-video-mode  ( )
   d# 255 set-video-alpha                ( )  \ Opaque video
   foo
   video-on
;
: stop-video  ( -- )  video-off  ;

: bg!  ( r g b -- )  h# 124 lcd!  ;
: lcd-set  ( mask offset -- )  tuck lcd@ or swap lcd!  ;
: lcd-clr  ( mask offset -- )  tuck lcd@ swap invert and swap lcd!  ;

: cursor-on  ( -- )  h# 100.0000 h# 190 lcd-set  ;
: cursor-off  ( -- )  h# 100.0000 h# 190 lcd-clr  ;

: cursor-xy@  ( -- x y )  h# 10c lcd@ lwsplit  ;
: cursor-xy!  ( x y -- )  cursor-off  wljoin h# 10c lcd!  cursor-on  ;

: cursor-wh@  ( -- w h )  h# 110 lcd@ lwsplit  ;
: cursor-wh!  ( w h -- )  wljoin h# 110 lcd!  ;

: rgb<>bgr  ( rgb -- bgr )  lbsplit drop  swap rot  0 bljoin  ;
: cursor-fgbg!  ( fg-rgb bg-rgb -- )  rgb<>bgr h# 12c lcd!  rgb<>bgr h# 128 lcd!  ;
: cursor-fgbg@  ( -- fg-rgb bg-rgb )  h# 128 lcd@ rgb<>bgr  h# 12c lcd@ rgb<>bgr  ;

: cursor-1bpp-mode  ( -- )  h# 200.0000 h# 190 lcd-set  ;
: cursor-2bpp-mode  ( -- )  h# 200.0000 h# 190 lcd-clr  ;
: cursor-opaque  ( -- )  cursor-1bpp-mode  h# 400.0000 h# 190 lcd-set  ;
: cursor-transparent  ( -- )  cursor-1bpp-mode  h# 400.0000 h# 190 lcd-clr  ;

: sram-write-mode  ( -- )  h# 198 lcd@ h# c000 invert and  h# 8000 or  h# 198 lcd!  ;
: sram-read-mode  ( -- )  h# 198 lcd@ h# c000 invert and  h# 198 lcd!  ;
: cursor-sram@  ( offset -- value )  h# 0c bwjoin h# 198 lcd!  h# 158 lcd@  ;
: cursor-sram!  ( value offset -- )  swap h# 19c lcd!  h# 8c bwjoin h# 198 lcd!  ;
: sram-read  ( adr len start path -- )
   bwjoin  -rot  bounds ?do                 ( index )
      dup h# 198 lcd!  h# 158 lcd@  i l!    ( index )
      1+                                    ( index' )
   /l +loop                                 ( index )
   drop                                     ( )
;
: sram-write  ( adr len start path -- )
   h# 80 or                                ( adr len start mode )
   bwjoin  -rot  bounds ?do                ( index )
      i l@ h# 19c lcd!  dup h# 198 lcd!    ( index )
      1+                                   ( index' )
   /l +loop                                ( index )
   drop                                    ( )
;
: cursor-sram-read   ( adr len start -- )  h# c sram-read   ;
: cursor-sram-write  ( adr len start -- )  h# c sram-write  ;

0 value cursor-w
0 value cursor-h

\ allow writes to cursor SRAM
: enable-cursor-writes  ( -- )  h# 8000 h# 1a4 lcd-set  ;

0 value #cursor-bits
0 value cursor-bits
0 value cursor-index
: flush-cursor-bits  ( -- )
   cursor-bits cursor-index cursor-sram!
   0 to #cursor-bits
   0 to cursor-bits
   cursor-index 1+ to cursor-index
;
: +2bits  ( 0..3 -- )
   #cursor-bits lshift cursor-bits or to cursor-bits
   #cursor-bits 2+ to #cursor-bits
   #cursor-bits d# 32 =  if
      flush-cursor-bits
   then
;
: init-cursor-bits  ( -- )
   0 to #cursor-bits
   0 to cursor-bits
   0 to cursor-index
;
0 value cursor-pitch
: set-cursor-line  ( fg-l bg-l -- )
   cursor-w  0  do                 ( fg-l bg-l )
      over  h# 8000.0000 and  if   ( fg-l bg-l )
	 1     \ Color 1           ( fg-l bg-l value )
      else                         ( fg-l bg-l )
         dup h# 8000.0000 and  if  ( fg-l bg-l )
            2  \ Color 2           ( fg-l bg-l value )
	 else                      ( fg-l bg-l )
	    0  \ Transparent       ( fg-l bg-l value )
	 then                      ( fg-l bg-l value )
      then                         ( fg-l bg-l value )
      +2bits                       ( fg-l bg-l )
      swap 2* swap 2*              ( fg-l' bg-l' )
   loop                            ( fg-l bg-l )
   2drop                           ( )
;
: set-cursor-image  ( 'fg 'bg w h fg-color bg-color -- )
   init-cursor-bits                ( 'fg 'bg w h fg-color bg-color )
   enable-cursor-writes            ( 'fg 'bg w h fg-color bg-color )
   cursor-off                      ( 'fg 'bg w h fg-color bg-color )
   cursor-2bpp-mode                ( 'fg 'bg w h fg-color bg-color )
   cursor-fgbg!                    ( 'fg 'bg w h )
   to cursor-h  to cursor-w        ( 'fg 'bg )
   cursor-w cursor-h cursor-wh!    ( 'fg 'bg )
   cursor-h  0  do                 ( 'fg 'bg )
      over l@  over l@             ( 'fg 'bg fg-l bg-l )
      set-cursor-line              ( 'fg 'bg )
      swap la1+  swap la1+         ( 'fg' 'bg' )
   loop                            ( 'fg 'bg )
   2drop                           ( )
   flush-cursor-bits               ( )
;
d# 256 constant /cursor
/cursor buffer: cursor
0 0 2value saved-cursor-wh
0 0 2value saved-cursor-fgbg

: sleep  ( -- )
   cursor /cursor 0  cursor-sram-read
   cursor-wh@ to saved-cursor-wh
   cursor-fgbg@ to saved-cursor-fgbg
   0 h# 190 lcd!
   lcd-clocks-off
;
: wake  ( -- )
   init-lcd
   enable-cursor-writes
   cursor-2bpp-mode
   saved-cursor-fgbg cursor-fgbg!
   saved-cursor-wh cursor-wh!
   cursor /cursor 0  cursor-sram-write
;

   defer convert-color ' noop to convert-color
   defer pixel*
   defer pixel+
   defer pixel!

   : color!  ( r g b index -- )  4drop  ;
   : color@  ( index -- r g b )  drop 0 0 0  ;

   fload ${BP}/dev/video/common/rectangle16.fth     \ Rectangular graphics

   depth d# 24 =  [if]
      code 3a+  ( adr n -- n' )
         pop  r0,sp
         inc  tos,#3
         add  tos,tos,r0
      c;
      code rgb888!  ( n adr -- )
         pop   r0,sp
         strb  r0,[tos]
         mov   r0,r0,lsr #8
         strb  r0,[tos,#1]
         mov   r0,r0,lsr #8
         strb  r0,[tos,#2]
         pop   tos,sp
      c;
      ' 3* to pixel*
      ' 3a+ to pixel+
      ' rgb888! to pixel!
      ' noop to convert-color
   [else]
      ' /w* to pixel*
      ' wa+ to pixel+
      ' w!  to pixel!
      ' argb>565-pixel to convert-color
   [then]

   defer init-panel    ' noop to init-panel

   [ifdef] olpc
   \ XXX we really should bounce these through the panel node(s)
   : bright!  " bright!" $call-dcon  ;
   : backlight-off  " backlight-off" $call-dcon  ;
   : backlight-on   " backlight-on" $call-dcon  ;
   [then]

   : display-on
      init-panel  \ Turns on DCON etc
      frame-buffer-adr  hdisp vdisp * >bytes  h# ffffffff lfill
      init-lcd
   ;
   : map-frame-buffer  ( -- )
      \ We use fb-mem-va directly instead of calling map-in on the physical address
      \ because the physical address changes with the total memory size.  The early
      \ assembly language startup code establishes the mapping.
      fb-mem-va to frame-buffer-adr
   ;
   " display"                      device-type
   " ISO8859-1" encode-string    " character-set" property
   0 0  encode-bytes  " iso6429-1983-colors"  property

   \ Used as temporary storage for images by $get-image
   : graphmem  ( -- adr )  dimensions * pixel*  fb-mem-va +  ;

   : add-simple-framebuffer ( -- )
      " /chosen" find-device
         new-device
            " framebuffer" device-name
            " simple-framebuffer" +compatible

            fb-mem-va >physical  encode-int
            vdisp hdisp * bytes/pixel *  encode-int encode+
            " reg" property

            hdisp " width" integer-property
            vdisp " height" integer-property
            hdisp bytes/pixel * " stride" integer-property
            bpp d# 32 =  if  " a8r8g8b8"  then
            bpp d# 24 =  if  " r8g8b8"    then
            bpp d# 16 =  if  " r5g6b5"    then
            " format" string-property
            " /display" encode-phandle " display" property

            " /clocks" encode-phandle mmp2-disp0-clk# encode-int encode+
            " /clocks" encode-phandle encode+ mmp2-disp0-lcdc-clk# encode-int encode+
            " clocks" property
         finish-device
      device-end
   ;

   : remove-simple-framebuffer ( -- )
       " /chosen/framebuffer"  find-package  if  delete-package  then
   ;

[ifdef] mmp3
fload ${BP}/cpu/arm/mmp3/hdmi.fth
[then]

   : display-install  ( -- )
      map-frame-buffer
      display-on
      default-font set-font
      width  height                           ( width height )
      over char-width / over char-height /    ( width height rows cols )
      /scanline depth fb-install              ( )
      [ifdef] mmp3  hdisp vdisp ['] start-hdmi catch drop  [then]
      add-simple-framebuffer
   ;

   : display-remove  ( -- )
      remove-simple-framebuffer
   ;
   : display-selftest  ( -- failed? )  false  ;

   ' display-install  is-install
   ' display-remove   is-remove
   ' display-selftest is-selftest

end-package

devalias screen /display
   
\ LICENSE_BEGIN
\ Copyright (c) 2010 FirmWorks
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
