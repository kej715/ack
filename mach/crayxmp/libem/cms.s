         entry     %cms
text:    section   code

**
*  CMS - compare two groups of bytes for equality
*
*  Entry
*    S1    : number of bytes to process
*    Stack : the two groups of bytes
*
*  Exit
*    s7 : 0 if bit-for-bit equality, 1 if not
*
%cms:    bss       0
         s2        7              ; calculate number of words per group of bytes
         s1        s2+s1
         s1        s1>3
         a3        s1
         a1        a7             ; address of first word of first group
         a2        a1+a3          ; calculate address of first word of second group
         a7        a2+a3          ; adjust stack pointer to reflect operands popped
1:
         a0        a3
         jaz       2f             ; if done
         s1        ,a1            ; process next pair of operand words
         s2        ,a2
         s0        s1\s2
         jsn       3f             ; if groups not bit-for-bit equal
         a1        a1+1           ; advance pointers to operands
         a2        a2+1
         a3        a3-1           ; decrement word count
         j         1b
2:
         s7        0
         j         b00
3:
         s7        1
         j         b00

         end
