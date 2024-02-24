         entry     %exg
text:    section   code

**
*  EXG - exchange specified number of bytes at top of stack
*
*  Entry
*    S1 : number of bytes to exchange
*
%exg:    bss       0
         s2        7              ; compute number of words to exchange
         s1        s1+s2
         s1        s1>3
         a1        s1
         a2        a7+a1          ; address of first word in one block
         a3        a7             ; address of first word in other block
1:
         a0        a1
         jaz       2f             ; if done
         s2        ,a2            ; exchange next two words
         s3        ,a3
         ,a2       s3
         ,a3       s2
         a2        a2+1           ; advance word addresses
         a3        a3+1
         a1        a1-1           ; decrement word count
         j         1b
2:
         j         b00

         end
