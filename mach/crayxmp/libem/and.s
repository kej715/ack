         entry     %and
text:    section   code

**
*  AND - calculate logical product of two groups of bytes
*
*  Entry
*    S1    : number of bytes to process
*    Stack : the two groups of bytes
*
*  Exit
*    Result on stack
*
%and:    bss       0
         s2        7              ; calculate number of words per group of bytes
         s1        s2+s1
         s1        s1>3
         a3        s1
         a1        a7             ; address of first word of first group
         a2        a1+a3          ; calculate address of first word of second group
         a7        a2             ; result will occupy same words as second group
1:
         a0        a3
         jaz       2f             ; if done
         s1        ,a1            ; process next pair of operand words
         s2        ,a2
         s2        s1&s2
         ,a2       s2             ; store next result word
         a1        a1+1           ; advance pointers to operands
         a2        a2+1
         a3        a3-1           ; decrement word count
         j         1b
2:
         j         b00

         end
