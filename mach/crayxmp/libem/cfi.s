         entry     %cfi

         ext       @erange

text:    section   code

**
*  CFI - convert floating point to integer
*
*    The "Rounding Half to Even" method is used in rounding
*    to the nearest integer.
*
*  Entry
*    (SP) : float to convert
*
*  Exit
*    s7 : result
*
%cfi:    bss       0
         s1        ,a7            ; pop float to convert
         a7        a7+1
         s0        s1
         jsz       2f             ; if value is 0
         s2        <15            ; exponent mask
         s3        s1
         s3        s3>48
         s3        s3&s2          ; isolate exponent
         s4        45             ; round value by adding 3 "noise" bits
         s3        s3-s4
         s3        s3&s2
         s4        7
         s3        s3<48
         s4        s4<45
         s3        s3!s4
         s1        s1+Fs3
         s3        s1             ; isolate new exponent
         s3        s3>48
         s3        s3&s2
         s2        o'40060        ; calculate shift count for mantissa
         s2        s2-s3
         s0        s2
         jsm       3f             ; if value too large
         a1        s2
         s3        <48            ; isolate mantissa
         s7        s3&s1
         s7        s7>a1          ; de-normalize it
         s0        s1
         jsp       1f             ; if original float was positive
         s7        -s7
1:
         j         b00
2:
         s7        s1
         j         b00
3:
         j         @erange

         end