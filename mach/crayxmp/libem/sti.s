         entry     %sti
         entry     %sti@1
         entry     %sti@2
         entry     %sti@8
text:    section   code

**
*  STI - store indirect one byte
*
*  Entry
*    (SP)   : byte address of storage location
*    (SP+1) : data to be stored
*
*  Exit
*    Nothing
*
%sti@1:  bss       0
         s1        ,a7            ; pop byte address
         a7        a7+1
         s2        ,a7            ; pop byte to be stored, right-justified
         a7        a7+1
         s3        s1             ; calculate word address of storage location
         s3        s3>3
         a1        s3
         s3        <3             ; isolate byte index
         s3        s3&s1
         s4        7              ; calculate shift count
         s3        s4-s3
         s3        s3<3
         s4        <8             ; byte mask
         a2        s3
         s2        s4&s2          ; isolate the byte
         s7        ,a1            ; fetch target word
         s4        s4<a2          ; position mask and byte to be inserted
         s2        s2<a2
         s7        #s4&s7         ; insert the byte
         s7        s2!s7
         ,a1       s7             ; store updated word
         j         b00

**
*  STI - store indirect two bytes
*
*  Entry
*    (SP)   : byte address of first storage location
*    (SP+1) : data to be stored
*
*  Exit
*    Nothing
*
%sti@2:  bss       0
         s1        ,a7            ; pop byte address of first byte
         a7        a7+1
         s2        ,a7            ; pop bytes to be stored, right-justified
         a7        a7+1
         s3        s1             ; calculate word address of storage location
         s3        s3>3
         a1        s3
         s3        <3             ; isolate byte index
         s3        s3&s1
         s4        6              ; calculate shift count
         s3        s4-s3
         s0        s3
         jsm       1f             ; if bytes straddle two words
         s3        s3<3
         s4        <16            ; byte mask
         a2        s3
         s2        s4&s2          ; isolate the bytes
         s7        ,a1            ; fetch target word
         s4        s4<a2          ; position mask and bytes to be inserted
         s2        s2<a2
         s7        #s4&s7         ; insert the bytes
         s7        s2!s7
         ,a1       s7             ; store updated word
         j         b00
1:
         s3        s2             ; position first byte to be inserted into first word
         s3        s3>8
         s7        ,a1            ; fetch first word
         s4        <8             ; insert first byte
         s3        s4&s3
         s7        #s4&s7
         s7        s3!s7
         ,a1       s7             ; store first updated word
         a1        a1+1           ; fetch second word
         s7        ,a1
         s4        >8             ; byte mask
         s2        s2<56          ; shift second byte into place
         s7        #s4&s7         ; and insert it into second word
         s7        s2!s7
         ,a1       s7             ; store second updated word
         j         b00

**
*  STI - store indirect eight bytes
*
*  Entry
*    (SP)   : byte address of first storage location
*    (SP+1) : data to be stored
*
*  Exit
*    Nothing
*
%sti@8:  bss       0
         s1        ,a7            ; pop byte address of first byte to store
         a7        a7+1
         s2        ,a7            ; pop bytes
         a7        a7+1
         s3        <3             ; extract byte index of first byte
         s3        s3&s1
         s1        s1>3           ; word address of first byte
         s0        s3
         jsn       1f             ; if first byte is not word-aligned
         a1        s1
         ,a1       s2
         j         b00
1:
         a7        a7-1           ; restore SP
         a7        a7-1
         s1        8
         j         %sti

**
*  STI - store indirect a specified number of bytes
*
*  Entry
*    S1   : number of bytes to store
*    (SP) : byte address of first storage location
*    (SP+1 .. SP+n) : data to be stored
*
*  Exit
*    Nothing
*
%sti:    bss       0
         a1        s1             ; byte count to a1
         s2        ,a7            ; pop storage address of first byte 
         a7        a7+1
         a0        a1
         jaz       3f             ; if no bytes to store
         s3        8
         s0        s1-s3
         jsp       1f             ; if 8 or more bytes to be stored
         s3        s3-s1          ; calculate shift to left-justify first word
         s3        s3<3
         a3        s3
         s7        ,a7
         s7        s7<a3
         ,a7       s7
1:
         s1        ,a7            ; pop next source word
         a7        a7+1
         a2        56             ; initial shift for full source word
2:
         s3        s1
         s3        s3>a2          ; right-justify and isolate next source byte
         s6        <8
         s3        s6&s3
         a3        8              ; decrement source shift count
         a2        a2-a3
         s4        s2             ; calculate word address of target storage word
         s4        s4>3
         a3        s4
         s4        <3             ; isolate byte index
         s4        s4&s2
         s5        7              ; calculate mask shift
         s4        s5-s4
         s4        s4<3
         a4        s4
         s6        s6<a4          ; position mask and byte to insert
         s3        s3<a4
         s7        ,a3            ; insert byte into target word
         s7        #s6&s7
         s7        s3!s7
         ,a3       s7
         a1        a1-1           ; decrement byte count
         a0        a1
         jaz       3f             ; if all bytes stored
         s6        1              ; advance storage address
         s2        s2+s6
         a0        a2
         jap       2b             ; if source word not exhausted
         j         1b
3:
         j         b00

         end
