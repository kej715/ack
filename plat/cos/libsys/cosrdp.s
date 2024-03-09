#include "cos.h"
#include "ftentry.h"

         ext       $RWDP

text:    section   code

**
*  @%cosrdp - read partial record from a local dataset
*
*  Entry
*    (SP)   : byte pointer to file table entry
*    (SP+1) : byte pointer to user data area
*    (SP+2) : max number of words to read
*
*  Exit
*    S7 : number of words read, or -1 if read failed
*         Also, on success:
*           FtEntry.unusedBits  set to number of unused bits in last word
*           FtEntry.status set as follows:
*             0 - partial record read
*             1 - EOR encountered
*             2 - EOF encountered
*             3 - EOD encountered
*
         entry     @%cosrdp
@%cosrdp:ENTER
         s1        1,a7           ; get byte address of FtEntry
         s1        s1>3           ; convert to word address
         a1        s1             ; calculate address of DSP
         a2        fte$dsp
         a1        a1+a2
         s2        2,a7           ; get byte address of user data area
         s2        s2>3           ; convert to word address
         a2        s2
         a3        3,a7           ; get word count
         r         $RWDP          ; perform the read operation
         s2        1,a7           ; get byte address of FtEntry
         s2        s2>3           ; convert to word address
         a1        s2
         fte$bits,a1 s6           ; store returned unused bit count
         s0        s1
         jsn       1f             ; if read operation failed
         a4        a4-a2          ; calculate number of words read
         s7        a4
         RETURN
*
*        Return error status
*
1:
         s7        -1
         RETURN

         end
