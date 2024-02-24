         entry     %fif

text:    section   code

**
*  FIF - floating multiply and separate into whole and fraction parts
*
*  Entry
*    (SP)   : multiplicand
*    (SP+1) : multiplier
*
*  Exit
*    (SP)   : whole part
*    (SP+1) : fraction part
*
%fif:    bss       0
         s1        ,a7            ; retrieve multiplicand and multiplier
         a7        a7+1
         s2        ,a7
         s1        s1*Fs2         ; compute product
         s0        s1
         jsz       2f             ; if product is 0
         s2        <15            ; exponent mask
         s3        s1
         s3        s3>48
         s3        s3&s2          ; isolate exponent of product
         s2        o'40060        ; calculate shift count for mantissa
         s4        s2-s3
         a1        s4
         s3        <48            ; isolate mantissa
         s3        s3&s1
         s3        s3>a1          ; de-normalize it to produce whole integer
         s2        s2<48          ; re-normalize to produce whole float
         s2        s2!s3
         s2        +Fs2
         s0        s1
         jsp       1f             ; if original product was positive
         s3        >1             ; make the whole negative
         s2        s3!s2
1:
         s1        s1-Fs2         ; obtain the fraction
         ,a7       s1             ; push the fraction
         a7        a7-1
         ,a7       s2             ;push the whole
         j         b00
2:
         ,a7       s0             ; push 0 fraction
         a7        a7-1
         ,a7       s0             ; push 0 whole
         j         b00

         end
