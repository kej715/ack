         entry     %loi
         entry     %loi@1
         entry     %loi@2
         entry     %loi@8
text:    section   code

**
*  LOI - load indirect one byte
*
*  Entry
*    (SP) : byte address of first byte to load
*
*  Exit
*    s7 : result
*
%loi@1:  bss       0
         s1        ,a7            ; pop byte address of byte to load
         a7        a7+1
         s2        <3             ; extract byte index of byte to load
         s2        s2&s1
         s1        s1>3           ; word address of byte
         a1        s1             ; fetch word containing byte
         s7        ,a1
         s3        7              ; calculate shift count
         s2        s3-s2
         s2        s2<3
         a1        s2
         s7        s7>a1          ; right-justify byte
         s1        <8             ; and isolate it
         s7        s1&s7
         j         b00

**
*  LOI - load indirect two bytes
*
*  Entry
*    (SP) : byte address of first byte to load
*
*  Exit
*    s7 : result
*
%loi@2:  bss       0
         s1        ,a7            ; pop byte address of first byte to load
         a7        a7+1
         s2        <3             ; extract byte index of first byte to load
         s2        s2&s1
         s1        s1>3           ; word address of byte
         a1        s1             ; fetch word containing bytes
         s7        ,a1
         s3        6              ; calculate shift count
         s2        s3-s2
         s0        s2
         jsm       1f             ; if bytes straddle two words
         s2        s2<3           ; continue calculating shift count
         a1        s2
         s7        s7>a1          ; right-justify bytes
         s1        <16            ; and isolate them
         s7        s1&s7
         j         b00
1:
         s7        s7<8           ; shift high byte into position
         a1        a1+1           ; fetch word containing low byte
         s6        ,a1
         s1        >8             ; isolate low byte
         s6        s1&s6
         s6        s6>56          ; right-justify low byte
         s7        s6!s7          ; merge the high and low bytes
         s1        <16            ; and isolate the merged result
         s7        s1&s7
         j         b00

**
*  LOI - load indirect eight bytes
*
*  Entry
*    (SP) : byte address of first byte to load
*
*  Exit
*    s7 : result
*
%loi@8:  bss       0
         s1        ,a7            ; pop byte address of first byte to load
         a7        a7+1
         s2        <3             ; extract byte index of first byte to load
         s0        s2&s1
         s1        s1>3           ; word address of byte
         jsn       1f             ; if first byte is not word-aligned
         a1        s1
         s7        ,a1
         j         b00
1:
         a7        a7-1           ; restore SP
         s1        8
         j         %loi

**
*  LOI - load indirect a specified number of bytes
*
*  Entry
*    S1   : number of bytes to load
*    (SP) : byte address of first byte to load
*
*  Exit
*    Result on stack
*
%loi:    bss       0
         a1        s1             ; byte count to a1
         s2        ,a7            ; pop address of first byte
         a7        a7+1
         a0        a1
         jaz       5f             ; if byte count is 0
         s3        7              ; calculate number of words needed for result
         s3        s3+s1
         s3        s3>3
         a2        s3             ; word count to a2
         a7        a7-a2          ; adjust stack pointer to reference first result word
1:
         s7        0              ; initialize next result word
         s6        8              ; bytes per word
2:
         s3        s2             ; calculate word address of next source byte
         s3        s3>3
         a3        s3
         s4        <3             ; byte index mask
         s3        s4&s2          ; isolate index of source byte
         s6        7              ; calculate source byte shift count
         s3        s6-s3
         s3        s3<3
         a4        s3
         s4        ,a3            ; fetch word containing byte
         s4        s4>a4          ; right-justify byte
         s5        <8             ; isolate it
         s4        s5&s4
         s7        s7<a4          ; merge it into result word
         s7        s7!s4
         a1        a1-1           ; decrement byte count
         a0        a1
         jaz       3f             ; if all source bytes processed
         s5        1              ; increment source byte address
         s2        s2+s5
         s6        s6-s5          ; decrement bytes remaining in result word
         s0        s6
         jsn       2b             ; if result word not full
         ,a7       s7             ; store full result word
         a7        a7+1           ; increment address of next result word
         j         1b
3:
         s3        8
         s3        s1-s3
         jsm       4f             ; if fewer than 8 bytes originally requested
         s3        1              ; calculate shift count for last word
         s3        s6-s3
         s3        s3<3
         a3        s3
         s7        s7<a3          ; left-justify last word
4:
         ,a7       s7             ; store last result word
         a7        a7-a2          ; re-adjust SP to address first result word
         a7        a7+1
5:
         j         b00

         end
