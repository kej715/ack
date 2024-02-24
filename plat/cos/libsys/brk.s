         ext       @errno

ENOMEM:  =         12

text:    section   code

**
*  @brk - set new heap pointer
*
*  Entry
*    (SP) : byte address new heap pointer
*
*  Exit
*    S7 : new byte address of heap pointer, or -1 if unsuccessful
*
         entry     @brk
@brk:    bss       0
         s7        ,a7            ; get new byte address
         s1        7              ; round and convert to word address
         s7        s7+s1
         s7        s7>3
         a1        s7             ; ensure SP and new HP are sufficiently wide apart
         a2        8
         a1        a1+a2
         a0        a1-a7
         jap       1f             ; if insuffient free space available
         a5        s7             ; set new heap pointer
         s7        s7<3           ; convert to byte pointer and return
         j         b00
1:
         s7        -1
         s1        ENOMEM
         @errno,   s1
         j         b00

**
*  @sbrk - increment the heap pointer
*
*  Entry
*    (SP) : increment value, in bytes
*
*  Exit
*    S7 : byte address of previous heap pointer, or -1 if unsuccessful
*
         entry     @sbrk
@sbrk:   bss       0
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         s1        1,a7           ; get increment
         s2        a5             ; convert heap pointer to byte pointer
         s2        s2<3
         s1        s2+s1          ; add the increment
         a7        a7-1           ; push current heap pointer
         ,a7       a5
         a7        a7-1           ; push requested heap pointer onto stack
         ,a7       s1
         r         @brk           ; and attempt to set it
         a1        3              ; restore stack pointer
         a7        a7+a1
         a0        -1,a7          ; retrieve return address
         b00       a0
         s0        s7             ; test return value
         jsm       1f             ; if failed to set new heap pointer
         s7        -2,a7          ; retrieve previous heap pointer
         s7        s7<3           ; and convert to byte address
1:
         j         b00

         end
