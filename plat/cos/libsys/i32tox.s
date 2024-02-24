text:    section   code

**
*  $i32tox - Convert 32-bit value to 8 hexadecimal digits
*
*  Entry:
*    s1 - 32-bit value
*
*  Exit:
*    s7 - 8 hexadecimal digits
*
*  Uses:
*    a2, a3, a4
*    s2, s3
*
         entry     $i32tox
$i32tox: bss       0
         a2        D'32           ; initial nibble shift count
         a3        4              ; shift count decrement
         s2        <4
         s7        0              ; initialize converted word
1:
         s3        s1
         a2        a2-a3
         a0        a2
         jaz       2f             ; if shift count is 0 (last nibble)
         s3        s3>a2          ; position nibble
2:
         s3        s3&s2
         a4        s3
         s3        hex,a4         ; fetch digit
         s7        s7<8           ; merge into word
         s7        s7!s3
         a0        a2
         jan       1b             ; if not done
         j         B00

rom:     section   data

hex:     bss       0
         con       '0'R
         con       '1'R
         con       '2'R
         con       '3'R
         con       '4'R
         con       '5'R
         con       '6'R
         con       '7'R
         con       '8'R
         con       '9'R
         con       'A'R
         con       'B'R
         con       'C'R
         con       'D'R
         con       'E'R
         con       'F'R

         end
