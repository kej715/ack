#include "cos.h"

text:    SECTION   code

**
*  $pack - pack a character string
*
*  Entry:
*    (A1) address of unpacked source characters
*    (A2) address of buffer for packed characters
*    (A3) number of characters to pack
*
*  Exit:
*    (A2) address of last packed word stored
*
*  Uses:
*    A4, B05
*    S1, S7
*
         ENTRY     $pack
$pack:   B05       A5             ; save heap pointer
         A0        A3
         JAZ       4f             ; if no characters to pack
         A5        8              ; decrement for shift count
1:
         S7        0              ; initialize next packed word
         A4        56             ; initial shift count for empty word
2:
         S1        ,A1            ; pack next character
         S1        S1<A4
         S7        S7!S1
         A3        A3-1           ; decrement character count
         A0        A3
         JAZ       3f             ; if done
         A1        A1+1           ; advance source address
         A4        A4-A5          ; update shift count for next character
         A0        A4
         JAP       2b             ; if destination word not full
         ,A2       S7             ; store packed word
         A2        A2+1           ; advance destination address
         J         1b
3:
         ,A2       S7             ; store final word
4:
         A5        B05            ; restore heap pointer
         J         B00

         END
