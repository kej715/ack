         entry     %cuf

text:    section   code

**
*  CUF - convert unsigned integer to floating point
*
*  Entry
*    (SP) : integer to convert
*
*  Exit
*    s7 : result
*
%cuf:    bss       0
         s1        ,a7            ; pop integer to convert
         a7        a7+1
         s0        s1
         jsn       1f             ; if integer is not zero
         s7        s1
         j         b00
1:
         s2        o'40060        ; initial exponent
         s3        >16
         s0        s3&s1
         jsn       2f             ; if value >= 2^48
         s2        s2<48
         s7        s2!s1
         s7        +Fs7           ; normalize it
         j         b00
2:
         s4        1
         s7        s1
3:
         s7        s7>1           ; shift mantissa right until exponent field empty
         s2        s2+s4          ; adjust exponent accordingly
         s0        s3&s7
         jsn       3b             ; if more shifting needed
         s2        s2<48          ; insert exponent
         s7        s2!s7
         j         b00

         end
