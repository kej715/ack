#include "cos.h"
#include "ftentry.h"

         ext       $WEOD

text:    section   code

**
*  @%coswed - write end-of-data to a local dataset
*
*  Entry
*    (SP)   : byte pointer to file table entry
*
*  Exit
*    S7 : number of words written, or -1 if write failed
*
         entry     @%coswed
@%coswed:ENTER
         s1        1,a7           ; get byte address of FtEntry
         s1        s1>3           ; convert to word address
         a1        s1             ; calculate address of DSP
         a2        fte$dsp
         a1        a1+a2
         r         $WEOD          ; perform the write operation
         s7        s1             ; return status
         RETURN

         end
