         entry     %mli

         ext       %cfi
         ext       %cif

text:    section   code

**
*  MLI - integer multiply
*
*  Entry
*    (SP)   : multiplier
*    (SP+1) : multiplicand
*
*  Exit
*    s7 : result
*
%mli:    bss       0
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         s1        1,a7           ; retrieve multiplier and push it
         a7        a7-1
         ,a7       s1
         r         %cif           ; convert multiplier to float
         1,a7      s7             ; replace integer multiplier with float
         s1        2,a7           ; retrieve multiplicand and push it
         a7        a7-1
         ,a7       s1
         r         %cif           ; convert multiplicand to float
         s1        1,a7           ; retrieve previously converted multiplier
         s7        s1*Fs7         ; perform the multiplication
         a7        a7-1           ; result to top of stack
         ,a7       s7
         r         %cfi           ; convert result to integer
         a0        ,a7            ; restore return address, empty stack, and return
         b00       a0
         a1        3
         a7        a7+a1
         j         b00

         end
