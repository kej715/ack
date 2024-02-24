#include "cos.h"
#include "ftentry.h"

text:    section   code

**
*  @%coseod - return EOD indication from DSP
*
*  Entry
*    (SP)   : byte pointer to file table entry
*
*  Exit
*    S7 : 1 if EOD detected, 0 otherwise
*
         entry     @%coseod
@%coseod:ENTER
         s1        1,a7           ; get byte address of FtEntry
         s1        s1>3           ; convert to word address
         a1        s1             ; calculate address of DSP
         a2        fte$dsp
         a1        a1+a2
         s1        DPCWF,a1       ; retrieve control word detection flags
         s2        <2             ; isolate status bits
         s1        s1>60
         s1        s1&s2
         s0        s1-s2
         jsz       1f             ; if EOD
         s7        0
         RETURN
1:
         s7        1
         RETURN

         end
