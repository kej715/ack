#include "cos.h"
#include "ftentry.h"

         ext       $REWD

text:    section   code

**
*  @%cosrew - rewind dataset
*
*  Entry
*    (SP)   : byte pointer to file table entry
*
*  Exit
*    S7 : 0 if success, or -1 if rewind failed
*
         entry     @%cosrew
@%cosrew:ENTER
         s1        1,a7           ; get byte address of FtEntry
         s1        s1>3           ; convert to word address
         a1        s1             ; calculate address of DSP
         a2        fte$dsp
         a1        a1+a2
         r         $REWD          ; perform the rewind operation
         s0        s1
         jsn       1f             ; if rewind operation failed
         s7        0
         RETURN
1:
         s7        -1
         RETURN

         end
