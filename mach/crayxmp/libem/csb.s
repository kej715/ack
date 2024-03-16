         entry     %csb
         ext       @ecase

text:    section   code

**
*  CSB - process a case descriptor, variant B
*
*  Entry
*    (SP)   : byte address of case descriptor table
*    (SP+1) : case index
*
%csb:    bss       0
         s1        ,a7            ; pop byte address of table
         a7        a7+1
         s1        s1>3           ; convert to word address
         a1        s1
         s1        ,a7            ; pop case index
         a7        a7+1
         a2        1,a1           ; number of entries in table
         a3        2              ; number of words per table entry
         a4        a1             ; initialize table search address
1:
         a4        a4+a3
         a0        a2
         jaz       3f             ; if case index not found in table
         s2        ,a4            ; compare next table index
         s0        s2\s1
         jsz       2f             ; if index found
         a2        a2-1
         j         1b
2:
         s2        1,a4           ; fetch branch target and jump there
         s0        s2
         jsz       4f             ; if invalid address
         s2        s2>1           ; convert byte address to parcel address
         a0        s2
         b00       a0
         j         b00
3:
         s2        ,a1            ; fetch default branch target and jump there
         s0        s2
         jsz       4f             ; if invalid address
         s2        s2>1           ; convert byte address to parcel address
         a0        s2
         b00       a0
         j         b00
4:
         j         @ecase

         end
