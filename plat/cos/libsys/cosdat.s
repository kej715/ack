#include "cos.h"

         ext       %blm

text:    section   code

**
*  @%cosdat - get current date
*
*  Entry
*    (SP)   : byte pointer to buffer for date
*
*  Date format:
*    "mm/dd/yy"
*
         entry     @%cosdat
@%cosdat:ENTER
         a7        a7-1           ; store date from system on stack
         s0        0              ; delimited by '\0'
         ,a7       s0
         a7        a7-1
         s1        a7
         s0        F$DAT
         ex
         s1        3,a7           ; get byte address of buffer
         s2        a7             ; source address
         s2        s2<3           ; convert source address to byte address
         a1        9              ; number of bytes to move
         r         %blm           ; copy date to caller's buffer
         a7        a7+1           ; clear stack
         a7        a7+1
         RETURN

         end
