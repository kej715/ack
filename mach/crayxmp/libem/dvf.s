         entry     %dvf
         ext       @efdivz

text:    section   code

**
*  DVF - floating point division
*
*  Entry
*    (SP)   : divisor
*    (SP+1) : dividend
*
*  Exit
*    s7 : result
*
%dvf:    bss       0
         s2        ,a7            ; pop divisor
         a7        a7+1
         s1        ,a7            ; pop dividend
         a7        a7+1
         s0        s2
         jsz       1f             ; if divisor is 0
         s3        /Hs2           ; approximate reciprocal
         s1        s1*Fs3         ; approximate quotient
         s2        s2*Is3         ; correction factor
         s7        s1*Fs2
         j         b00
1:
         j         @efdivz

         end
