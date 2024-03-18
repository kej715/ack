#include "cos.h"
#include "ftentry.h"

         ext       $WEOD
         ext       %getdsp

text:    section   code

**
*  @%coswef - write end-of-file to a local dataset
*
*  Entry
*    (SP)   : byte pointer to file table entry
*
*  Exit
*    S7 : 0 if success, -1 if failure
*
         entry     @%coswef
@%coswef:ENTER
         s1        1,a7           ; get byte address of FtEntry
         r         %getdsp        ; get DSP address from FtEntry
         r         $WEOF          ; perform the write operation
         s0        s1
         jsn       2f             ; if failure
         s7        0              ; return status
1:
         RETURN
2:
         s7        -1
         j         1b

         end
