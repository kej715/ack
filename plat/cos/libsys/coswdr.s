#include "cos.h"
#include "ftentry.h"

         ext       $WWDR

text:    section   code

**
*  @%coswdr - write record to a local dataset
*
*  Entry
*    (SP)   : byte pointer to file table entry
*    (SP+1) : byte pointer to user data area
*    (SP+2) : number of words to write
*    (SP+3) : number of unused bits in last word
*
*  Exit
*    S7 : number of words written, or -1 if write failed
*
         entry     @%coswdr
@%coswdr:ENTER
         s1        1,a7           ; get byte address of FtEntry
         s1        s1>3           ; convert to word address
         a1        s1             ; calculate address of DSP
         a2        fte$dsp
         a1        a1+a2
         s2        2,a7           ; get byte address of user data area
         s2        s2>3           ; convert to word address
         a2        s2
         a3        3,a7           ; get word count
         s2        4,a7           ; get unused bit count
         r         $WWDR          ; perform the write operation
         s0        s1
         jsn       2f             ; if write operation failed
         s7        a3             ; return count of words written
1:
         RETURN
2:
         s7        -1
         j         1b

         end
