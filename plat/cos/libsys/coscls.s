#include "cos.h"

text:    section   code

**
*  @%coscls - close a local dataset
*
*  Entry
*    (SP)   : byte pointer of Open Dataset Name table
*
*  Exit
*    S7 : 0 if success
*
         entry     @%coscls
@%coscls: bss      0
         s0        F$CLS
         s1        ,a7            ; get byte address of ODN
         s1        s1>3           ; convert to word address
         ex                       ; execute system request
         -1,a7     s0
         s7        -1,a7
         j         b00

         end
