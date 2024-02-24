         entry     %dvi

         ext       %cfi
         ext       %cif
         ext       %dvf
         ext       @eidivz

text:    section   code

**
*  DVI - integer divide
*
*  Entry
*    (SP)   : divisor
*    (SP+1) : dividend
*
*  Exit
*    s7 : result
*
%dvi:    bss       0
         s0        ,a7            ; retrieve divisor from stack
         jsz       1f             ; if divisor is 0
         a7        a7-1           ; save return address on stack
         a0        b00
         ,a7       a0
         s0        2,a7           ; retrieve dividend and push it
         a7        a7-1
         ,a7       s0
         r         %cif           ; convert dividend to float
         2,a7      s7             ; replace integer dividend with float
         s0        1,a7           ; retrieve divisor and push it
         a7        a7-1
         ,a7       s0
         r         %cif           ; convert divisor to float
         s0        2,a7           ; retrieve converted dividend and push it
         a7        a7-1
         ,a7       s0
         a7        a7-1           ; push converted divisor
         ,a7       s7
         r         %dvf           ; perform the division
         a7        a7-1           ; push quotient
         ,a7       s7
         r         %cfi           ; convert result to integer
         a0        ,a7            ; restore return address
         b00       a0
         a1        3              ; empty the stack and return
         a7        a7+a1
         j         b00
1:
         a7        a7+1           ; empty the stack
         a7        a7+1
         j         @eidivz

         end
