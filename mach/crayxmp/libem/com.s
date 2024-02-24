         entry     %com
text:    section   code

**
*  COM - complement the bits in a group of bytes
*
*  Entry
*    S1    : number of bytes to process
*    Stack : the group of bytes
*
*  Exit
*    Result on stack
*
%com:    bss       0
         s2        7              ; calculate number of words in the group of bytes
         s1        s2+s1
         s1        s1>3
         a2        s1
         a1        a7             ; address of first word of first group
1:
         a0        a2
         jaz       2f             ; if done
         s1        ,a1            ; process next operand word
         s1        #s1
         ,a1       s1             ; store next result word
         a1        a1+1           ; advance operand pointer
         a2        a2-1           ; decrement word count
         j         1b
2:
         j         b00

         end
