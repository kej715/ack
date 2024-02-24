         entry     %fef
text:    section   code

**
*  FEF - split floating number into exponent and fraction part
*
*  Entry
*    (SP) : floating point value
*
*  Exit
*    (SP)   : exponent
*    (SP+1) : fraction
*

%fef:    bss       0
         s1        ,a7            ; get floating point value from top of stack
         s0        s1
         jsz       1f             ; if value is 0
         s3        <15            ; mask for exponent
         s3        s3<48
         s2        s3&s1          ; extract exponent
         s2        s2>48
         s4        o'40000        ; unbias it
         s2        s2-s4
         s1        #s3&s1         ; clear exponent in original value
         s4        s4<48          ; shift 2^0 exponent into position
         s1        s4!s1          ; and merge into result value
         ,a7       s1             ; push fraction
         a7        a7-1
         ,a7       s2             ; push exponent
         j         b00            ; return
1:
         ,a7       s0             ; push 0 fraction
         a7        a7-1
         ,a7       s0             ; push 0 exponent
         j         b00            ; return

         end
