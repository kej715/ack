         entry     %gto
         ext       @ebadgto
text:    section   code

**
*  GTO - non-local goto
*
*  Entry
*    S1 : byte address of goto descriptor
*
%gto:    bss       0
         s2        <3
         s2        s2&s1
         jsn       1f             ; if descriptor not word-aligned
         s1        s1>3           ; convert descriptor address to word address
         s0        s1
         jsz       1f             ; if invalid descriptor address
         a1        s1
         a2        ,a1            ; load new PC value
         a0        a2
         jaz       1f             ; if invalid address
         a3        1,a2           ; load new SP value
         a0        a3
         jaz       1f             ; if invalid address
         a4        2,a2           ; load new LB value
         a0        a4
         jaz       1f             ; if invalid address
         a7        a3             ; set new SP
         a6        a4             ; set new LB
         b00       a2             ; set new PC (i.e., execute goto)
         j         b00
1:
         j         @ebadgto

         end
