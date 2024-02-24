         entry     %dup
text:    section   code

**
*  DUP - duplicate specified number of bytes at top of stack
*
*  Entry
*    S1 : number of bytes to duplicate
*
%dup:    bss       0
         s2        7              ; compute number of words to duplicate
         s1        s1+s2
         s1        s1>3
         a1        s1
         a2        a7-a1          ; address of first destination word
         a3        a2             ; copy address; it will become new SP
1:
         a0        a1
         jaz       2f             ; if done
         s2        ,a7            ; duplicate next word
         ,a2       s2
         a7        a7+1           ; advance word addresses
         a2        a2+1
         a1        a1-1           ; decrement word count
         j         1b
2:
         a7        a3             ; set new SP
         j         b00

         end
