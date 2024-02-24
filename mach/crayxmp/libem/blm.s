         entry     @%bcopy
         entry     %blm
text:    section   code

**
*  @%bcopy - copy a specified number of bytes
*
*  Entry
*    (SP)   : byte address of destination
*    (SP+1) : byte address of source
*    (SP+2) : number of bytes to copy
*
@%bcopy: bss       0
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         s1        1,a7           ; get byte address of destination
         s2        2,a7           ; get byte address of source
         a1        3,a7           ; get byte count
         r         %blm           ; perform the copy
         a0        ,a7            ; pop return address
         a7        a7+1
         b00       a0
         j         b00            ; return

**
*  BLM - block move a specified number of bytes
*
*  Entry
*    A1 : number of bytes to move
*    S1 : destination byte address
*    S2 : source byte address
*
%blm:    bss       0
         a0        a1
         jaz       1f             ; if done
         s3        s2             ; calculate word address of next source byte
         s3        s3>3
         a2        s3
         s4        <3             ; byte index mask
         s3        s4&s2          ; isolate index of source byte
         s5        7              ; calculate source byte shift count
         s3        s5-s3
         s3        s3<3
         a3        s3
         s4        ,a2            ; fetch word containing byte
         s4        s4>a3          ; right-justify byte
         s5        <8             ; isolate it
         s7        s5&s4
         s3        s1             ; calculate word address of next destination byte
         s3        s3>3
         a2        s3
         s4        <3             ; byte index mask
         s3        s4&s1          ; isolate index of destination byte
         s5        7              ; calculate destination byte shift count
         s3        s5-s3
         s3        s3<3
         a3        s3
         s4        ,a2            ; fetch word containing byte
         s5        <8             ; byte mask
         s5        s5<a3          ; position mask
         s7        s7<a3          ; position source byte
         s4        #s5&s4         ; merge source byte into destination word
         s4        s7!s4
         ,a2       s4             ; store the updated word
         s3        1              ; increment the byte addresses
         s1        s1+s3
         s2        s2+s3
         a1        a1-1           ; decrement the byte count
         j         %blm
1:
         j         b00

         end
