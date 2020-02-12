" uart" name
[ifdef] olpc
" mrvl,mmp-uart" +compatible
[then]
" intel,xscale-uart" +compatible
my-space  h# 20  reg

2 " reg-shift" integer-property

: write  ( adr len -- actual )
   0 max  tuck                    ( actual adr actual )
   bounds  ?do  i c@ uemit  loop  ( actual )
;
: read   ( adr len -- actual )
   0=  if  drop 0  exit  then
   ukey?  if           ( adr )
      ukey swap c!  1  ( actual )
   else                ( adr )
      drop  -2         ( -2 )
   then
;
: open  ( -- okay? )  true  ;
: close  ( -- )   ;
: install-abort  ;
: remove-abort  ;
