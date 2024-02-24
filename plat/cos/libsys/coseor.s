#include "cos.h"
#include "ftentry.h"

text:    section   code

**
*  @%coseor - return EOR indication from DSP
*
*  Entry
*    (SP)   : byte pointer to file table entry
*
*  Exit
*    S7 : 1 if EOR detected, 0 otherwise
*
         entry     @%coseor
@%coseor:ENTER
         s1        1,a7           ; get byte address of FtEntry
         s1        s1>3           ; convert to word address
         a1        s1             ; calculate address of DSP
         a2        fte$dsp
         a1        a1+a2
         s0        DPCWF,a1       ; retrieve control word detection flags
         jsm       1f             ; if EOR
         s7        0
         RETURN
1:
         s7        1
         RETURN

         end
