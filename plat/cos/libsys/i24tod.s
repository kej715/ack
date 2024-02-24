text:    section   code

**
*  $dv10@24 - 24-bit integer divide by 10
*
*  Entry:
*    a1 - value to be divided by 10
*
*  Exit:
*    a1 - integer quotient
*    a2 - integer remainder
*
*  Uses:
*    A3, S1, S2, S3
*
         entry     $dv10@24
$dv10@24:bss       0
         s1        +Fa1           ; argument to normalized floating point
         s1        +Fs1
         a2        10             ; generate 1/10
         s2        +Fa2
         s2        +Fs2
         s2        /Hs2
         s1        s1*Hs2         ; rounded half-precision multiply
         s2        s1             ; extract and unbias exponent
         s3        <15
         s2        s2>48
         s2        s2&s3
         s3        o'40060
         s3        s3-s2
         a2        s3             ; shift count for coefficient
         s2        <48
         s1        s1&s2          ; extract and shift coefficient
         s1        s1>a2
         a3        a1             ; save original value
         a1        s1             ; integer quotient
         a2        10
         a2        a1*a2
         a2        a3-a2          ; integer remainder
         j         b00

**
*  $i2d@24 - 24-bit integer to decimal
*
*  The result is left-justified in a word supplied as an argument,
*  with characters originally in the word shifted right. For example,
*  the word supplied is usually one of 0, ' ', ',', or ','L.
*
*  Entry:
*    a1 - value to be converted
*    s7 - template result word
*
*  Exit:
*    s7 - result
*
         entry     $i2d@24
$i2d@24: bss       0
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         a7        a7-1           ; push original value
         ,a7       a1
         a0        a1
         jap       1f             ; if value not negative
         a1        -a1
1:
         r         $dv10@24       ; compute next digit
         a2        '0'R
         a2        a2+a1
         s7        s7>8           ; merge digit into result
         s1        a2
         s1        s1<56
         s7        s1!s7
         a0        a1
         jan       1b             ; if more digits to be converted
         a0        ,a7            ; pop original value
         a7        a7+1
         jap       2f             ; if original value not negative
         s7        s7>8           ; merge sign into result
         s1        '-'R
         s1        s1<56
         s7        s1!s7
2:
         a0        ,a7            ; pop return address and return
         a7        a7+1
         b00       a0
         j         b00

         end
