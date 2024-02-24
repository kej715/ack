         entry     %mlu
         ext       %cfi
         ext       %cuf

text:    section   code

**
*  MLU - unsigned integer multiply
*
*  Entry
*    (SP)   : multiplicand
*    (SP+1) : multiplier
*
*  Exit
*    s7 : result
*
%mlu:    bss       0
         s1        1,a7           ; retrieve multiplier
         a1        b00            ; save return address where multiplier was
         1,a7      a1
         a7        a7-1           ; push multiplier
         ,a7       s1
         r         %cuf           ; convert multiplier to float
         s1        ,a7            ; swap result with multiplicand
         ,a7       s7
         a7        a7-1
         ,a7       s1
         r         %cuf           ; convert multiplicand to float
         s1        ,a7            ; retrieve previously converted multiplier
         s7        s1*Fs7         ; perform the multiplication
         ,a7       s7             ; result to top of stack
         r         %cfi           ; convert result to integer
         a1        ,a7            ; pop return address and return
         a7        a7+1
         b00       a1
         j         b00

         end
