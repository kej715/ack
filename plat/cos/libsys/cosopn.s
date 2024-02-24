#include "cos.h"

text:    section   code

**
*  @%cosopn - open a local dataset
*
*  Entry
*    (SP)   : byte pointer of Open Dataset Name table
*    (SP+1) : processing direction
*              1 = output
*              2 = input
*              3 = input/output
*
*  Exit
*    S7 : 0 if success
*
         entry     @%cosopn
@%cosopn: bss      0
         s0        F$OPN
         s1        ,a7            ; get byte address of ODN
         s1        s1>3           ; convert to word address
         s2        1,a7           ; get processing direction
         s2        s2<62          ; merge with ODN address
         s1        s1!s2
         ex                       ; execute system request
         -1,a7     s0
         s7        -1,a7
         j         b00

         end
