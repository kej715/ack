#include "cos.h"
#include "ftentry.h"

text:    section   code

**
*  %getdsp - return DSP address associated with ODN
*
*  Entry
*    s1 : byte pointer of Open Dataset Name table
*
*  Exit
*    a1 : DSP address
*
         entry     %getdsp
%getdsp: bss      0
         s1        s1>3           ; convert byte address to word address
         a2        s1
         a1        1,a2           ; get DSP address from ODN
         a0        a1
         jam       1f             ; if negative DSP offset
         j         b00
1:
         a2        JCDSP,         ; calculate DSP address from offset
         a1        a2-a1
         j         b00

**
*  @%getdsp - return DSP address associated with FtEntry
*
*  Entry
*    (SP) - byte address of FtEntry
*
*  Exit
*    s7 : byte address of DSP
*
         entry     @%getdsp
@%getdsp:ENTER
         s1        1,a7           ; get byte address of FtEntry
         r         %getdsp        ; get DSP address from FtEntry
         s7        a1
         s7        s7<3           ; convert word address to byte address
         RETURN

         end
