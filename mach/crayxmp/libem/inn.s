         entry     %inn
         ext       @eset
text:    section   code

**
*  INN - test bit in set of bytes
*
*  Entry
*    (SP)   : number of bytes in set
*    (SP+1) : bit number to test
*    (SP+2) : the set of bytes
*
*  Exit
*    S7 : result
*
%inn:    bss       0
         s1        ,a7            ; pop number of bytes in set
         a7        a7+1
         s2        ,a7            ; pop bit number
         a7        a7+1
         s3        s1             ; calculate number of bits in set
         s3        s3<3
         s0        s3-s2
         jsm       1f             ; if invalid bit number
         jsz       1f
         s3        s2             ; calculate index of word containing bit
         s3        s3>6
         a2        s3
         a2        a2+a7          ; calculate address of word containing bit
         s7        ,a2            ; get the word
         s4        <6             ; isolate index of bit within word
         s2        s4&s2
         a2        s2
         a1        63             ; calculate shift for right-justifying bit
         a2        a1-a2
         s7        s7>a2          ; right-justify the bit
         s4        <1             ; and isolate it
         s7        s4&s7
         s2        7              ; calculate number of words in set
         s1        s1+s2
         s1        s1>3
         a1        s1             ; pop set from stack
         a7        a7+a1
         j         b00
1:
         s0        s1
         jsz       2f             ; if no bytes in set
         s2        7              ; calculate number of words in set
         s1        s1+s2
         s1        s1>3
         a1        s1             ; pop set from stack
         a7        a7+a1
2:
         j         @eset

         end
