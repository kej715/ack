         entry     %cif

text:    section   code

**
*  CIF - convert integer to floating point
*
*  Entry
*    (SP) : integer to convert
*
*  Exit
*    s7 : result
*
%cif:    bss       0
         s1        ,a7            ; pop integer to convert
         a7        a7+1
         s6        >1             ; isolate sign bit
         s6        s6&s1
         s0        s1
         jsm       2f             ; if integer is negative
         jsn       1f             ; if integer is not zero
         s7        s1
         j         b00
1:
         s2        o'40060        ; insert exponent
         s3        >16
         s0        s3&s1
         jsn       3f             ; if value >= 2^48
         s2        s2<48
         s7        s2!s1
         s7        +Fs7           ; normalize it
         s7        s6!s7          ; insert the sign bit
         j         b00
2:
         s1        -s1            ; make the value positive
         j         1b
3:
         s4        1
         s7        s1
4:
         s7        s7>1           ; shift mantissa right until exponent field empty
         s2        s2+s4          ; adjust exponent accordingly
         s0        s3&s7
         jsn       4b             ; if more shifting needed
         s2        s2<48          ; insert exponent
         s7        s2!s7
         s7        s6!s7          ; insert the sign bit
         j         b00

         end
