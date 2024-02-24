text:    section   code

**
*  $i24too - Convert 24-bit value to 8 octal digits
*
*  Entry:
*    s1 - 24-bit value
*
*  Exit:
*    s7 - 8 octal digits
*
*  Uses:
*    a2, a3, a4
*    s2, s3
*
         entry     $i24too
$i24too: bss       0
         a2        D'24           ; initial nibble shift count
         a3        3              ; shift count decrement
         s2        <3
         s7        0              ; initialize converted word
1:
         s3        s1
         a2        a2-a3
         a0        a2
         jaz       2f             ; if shift count is 0 (last 3 bits)
         s3        s3>a2          ; position bits
2:
         s3        s3&s2
         a4        s3
         s3        oct,a4         ; fetch digit
         s7        s7<8           ; merge into word
         s7        s7!s3
         a0        a2
         jan       1b             ; if not done
         j         B00

rom:     section   data

oct:     bss       0
         con       '0'R
         con       '1'R
         con       '2'R
         con       '3'R
         con       '4'R
         con       '5'R
         con       '6'R
         con       '7'R

         end
