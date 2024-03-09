         entry     %rmi

         ext       %dvi
         ext       %mli
         ext       @eidivz

text:    section   code

**
*  RMI - integer remainder
*
*  Entry
*    (SP)   : divisor
*    (SP+1) : dividend
*
*  Exit
*    s7 : result
*
%rmi:    bss       0
         s0        0,a7           ; retrieve divisor
         jsz       4f             ; if divisor is 0
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         s0        2,a7           ; retrieve dividend and push it
         a7        a7-1
         ,a7       s0
         s0        2,a7           ; retrieve divisor and push it
         a7        a7-1
         ,a7       s0
         r         %dvi           ; perform integer divide
         s0        1,a7           ; retrieve original divisor and push it
         a7        a7-1
         ,a7       s0
         a7        a7-1           ; push quotient
         ,a7       s7
         r         %mli           ; perform integer multiply
         s1        2,a7           ; retrieve original dividend
         s7        s1-s7          ; calculate remainder
         s2        1,a7           ; retrieve original divisor
         s0        s1
         jsm       3f             ; if original divisor is negative
         s0        s7-s2
         jsm       2f             ; if remainder less than original divisor
1:
         s7        0
2:
         a0        ,a7            ; restore return address
         b00       a0
         a1        3              ; empty the stack and return
         a7        a7+a1
         j         b00
3:
         s0        s7-s2
         jsm       2b             ; if remainder greater than original divisor
         j         1b
4:
         a7        a7+1           ; empty the stack
         a7        a7+1
         j         @eidivz

         end
