         entry     %cai

text:    section   code

**
*  CAI - call procedure indirect
*
*  Entry
*    (SP) : byte address of procedure
*    b00  : return address
*
%cai:    bss       0
         s1        ,a7            ; pop byte address of procedure
         a7        a7+1
         s1        s1>1           ; convert byte address to parcel address
         a0        s1
         b01       a0
         j         b01            ; execute procedure

         end
