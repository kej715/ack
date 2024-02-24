         entry     %cfi

text:    section   code

**
*  CFI - convert floating point to integer
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
         s2        o'40060        ; calculate shift count for mantissa
         s2        s2-s3
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

         end
