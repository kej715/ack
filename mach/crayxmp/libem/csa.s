         entry     %csa
         ext       @ecase
text:    section   code

**
*  CSA - process a case descriptor, variant A
*
*  Entry
*    (SP)   : byte address of case descriptor table
*    (SP+1) : case index
*
%csa:    bss       0
         s1        ,a7            ; pop byte address of table
         a7        a7+1
         s1        s1>3           ; convert to word address
         a1        s1
         s1        ,a7            ; pop case index
         a7        a7+1
         s2        1,a1           ; get lower bound of indices
         s1        s1-s2          ; subtract it from case index
         s0        s1
         jsm       1f             ; if index not in table
         s2        2,a1           ; get table limit
         s0        s2-s1
         jsm       1f             ; if index not in table
         a2        s1             ; compute address of table entry
         a1        a1+a2
         a2        3,a1           ; fetch branch target and jump there
         a0        a2
         jaz       2f             ; if invalid address
         b00       a2
         j         b00
1:
         a2        ,a1            ; fetch default branch target and jump there
         a0        a2
         jaz       2f             ; if invalid address
         b00       a2
         j         b00
2:
         j         @ecase

         end
