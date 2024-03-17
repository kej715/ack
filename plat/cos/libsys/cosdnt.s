#include "cos.h"

text:    section   code

**
*  @%cosdnt - create/modify/sense/query a local dataset
*
*  Entry
*    (SP)   : byte pointer of Data Definition List (DDL)
*
*  Exit
*    S7 : result of operation
*
         entry     @%cosdnt
@%cosdnt: bss      0
         s0        F$DNT
         s1        ,a7            ; get byte address of DDL
         s1        s1>3           ; convert to word address
         ex                       ; execute system request
         -1,a7     s0
         s7        -1,a7
         j         b00

         end
