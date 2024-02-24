#include "cos.h"

         ext       %blm

text:    section   code

**
*  @%costim - get current time
*
*  Entry
*    (SP)   : byte pointer to buffer for time
*
*  Date format:
*    "mm/dd/yy"
*
         entry     @%costim
@%costim:ENTER
         a7        a7-1           ; store time from system on stack
         s0        0              ; delimited by '\0'
         ,a7       s0
         a7        a7-1
         s1        a7
         s0        F$TIM
         ex
         s1        3,a7           ; get byte address of buffer
         s2        a7             ; source address
         s2        s2<3           ; convert source address to byte address
         a1        9              ; number of bytes to move
         r         %blm           ; copy time to caller's buffer
         a7        a7+1           ; clear stack
         a7        a7+1
         RETURN

         end
