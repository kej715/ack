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
         s3        <3
         s0        s1&s3
         jsn       1f             ; if destination not word-aligned
         s0        s2&s3
         jsz       3f             ; if both source and destination are word-aligned
1:
         a0        a1
         jaz       2f             ; if done
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
2:
         j         b00
*
*        Move whole words until fewer than 8 bytes remain
*
3:
         s1        s1>3           ; calculate word address of first destination byte
         a2        s1
         s2        s2>3           ; calculate word address of first source byte
         a3        s2
         a4        8              ; bytes per word
4:
         a0        a1
         jaz       2b             ; if done
         a0        a1-a4
         jam       5f             ; if fewer than 8 bytes remaining
         
         s3        ,a3            ; move next word
         ,a2       s3
         a3        a3+1           ; advance source address
         a2        a2+1           ; advance destination address
         a1        a1-a4          ; decrement byte count
         j         4b
5:
         s3        ,a3            ; fetch last source word
         s2        ,a2            ; fetch last destination word
         s4        bmasks,a1      ; fetch mask for remaining bytes
         s3        s4&s3          ; isolate remaining source bytes
         s2        #s4&s2         ; clear bytes to be replaced in destination word
         s2        s3!s2          ; merge source and destination bytes
         ,a2       s2             ; store final word
         j         b00

rom:     section   data
bmasks:  bss       0
         con       0
         con       X'ff00000000000000
         con       X'ffff000000000000
         con       X'ffffff0000000000
         con       X'ffffffff00000000
         con       X'ffffffffff000000
         con       X'ffffffffffff0000
         con       X'ffffffffffffff00

         end
