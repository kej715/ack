#include "cos.h"
#include "ftentry.h"

         ext       $REWD
         ext       %getdsp

text:    section   code

**
*  @%cosrew - rewind dataset
*
*  Entry
*    (SP)   : byte pointer of Open Dataset Name table
*
*  Exit
*    S7 : 0 if success, or -1 if rewind failed
*
         entry     @%cosrew
@%cosrew:ENTER
         s1        1,a7           ; get byte address of ODN
         r         %getdsp        ; get DSP address from ODN
         r         $REWD          ; perform the rewind operation
         s0        s1
         jsn       1f             ; if rewind operation failed
         s7        0
         RETURN
1:
         s7        -1
         RETURN

         end
