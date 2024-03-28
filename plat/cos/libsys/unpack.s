#include "cos.h"

text:   SECTION    code

**
*  $unpack - unpack a character string
*
*  Entry:
*    (A1) address of packed source characters
*    (A2) address of buffer for unpacked characters
*    (A3) number of characters to unpack
*
*  Uses:
*    A4, B05
*    S1, S2, S7
*
         ENTRY     $unpack
$unpack: B05       A5             ; save heap pointer
         A5        8              ; decrement for shift count
         S2        <8             ; character mask
1:
         S1        ,A1            ; fetch next word of packed characters
         A4        56             ; initial shift count for full word
2:
         A0        A3
         JAZ       3f             ; if done
         S7        S1
         S7        S7>A4          ; unpack next character
         S7        S7&S2
         ,A2       S7
         A2        A2+1           ; advance destination address
         A3        A3-1           ; decrement character count
         A4        A4-A5          ; update shift count for next character
         A0        A4
         JAP       2b             ; if more characters in current word
         A1        A1+1           ; advance source address
         J         1b
3:
         A5        B05            ; restore heap pointer
         J         B00

         END
