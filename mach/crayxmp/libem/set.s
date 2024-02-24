         entry     %set
         ext       @eset
text:    section   code

**
*  SET - create set of bytes with specified bit set
*
*  Entry
*    (SP)   : number of bytes in set
*    (SP+1) : bit number to set
*
*  Exit
*    (SP) : the created set
*
%set:    bss       0
         s1        ,a7            ; pop number of bytes in set
         a7        a7+1
         s2        ,a7            ; pop bit number
         a7        a7+1
         s3        s1             ; calculate number of bits in set
         s3        s3<3
         s0        s3-s2
         jsm       2f             ; if invalid bit number
         jsz       2f
         s3        7              ; calculate number of words in set
         s3        s1+s3
         s3        s3>3
         a1        s3             ; allocate space for set on stack
         a7        a7-a1
         s3        0              ; clear all bits in set
         a2        a7
1:
         ,a2       s3
         a2        a2+1
         a1        a1-1
         a0        a1
         jan       1b             ; if more bits to clear
         s3        s2             ; calculate index of word containing bit to set
         s3        s3>6
         a2        s3
         a2        a2+a7          ; calculate address of word containing bit
         s3        <6             ; isolate index of bit within word
         s2        s3&s2
         a2        s2
         s1        >1             ; position the bit
         s1        s1>a2
         ,a2       s1             ; store the word with bit set
         j         b00
2:
         j         @eset

         end
