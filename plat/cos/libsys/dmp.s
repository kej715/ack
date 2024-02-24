#include "cos.h"

         ext       $i24too
         ext       $i32tox

text:    section   code

**
*  @%dmpmem - Dump block of memory to log file in hexadecimal format
*
*  Entry:
*    (SP)   : byte address of first byte to dump
*    (SP+1) : number of bytes to dump
*
         entry     @%dmpmem
@%dmpmem:bss       0
         s1        ,a7            ; calculate word address of first byte
         s1        s1>3
         a1        s1
         s2        1,a7           : calculate number of words to dump
         s3        7
         s2        s2+s3
         s2        s2>3
         a2        s2             ; calculate last word address + 1
         a2        a1+a2
         j         $dmpmemx       ; perform the dump

**
*  $dmpmemx - Dump block of memory to log file in hexadecimal format
*
*  Entry:
*    (a1) first word address
*    (a2) last word address + 1
*
         entry     $dmpmemx
$dmpmemx:bss       0
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         a7        a7-1           ; push last word address + 1
         ,a7       a2
         a7        a7-1           ; push first word address
         ,a7       a1
         s1        0              ; store 0-word on stack
         -1,a7     s1
1:
         a0        a1-a2
         jap       2f             ; if done
         s1        ,a1            ; convert top 32 bits to hex
         s1        s1>32
         r         $i32tox
         -3,a7     s7
         a1        0,a7
         s1        ,a1            ; convert bottom 32 bits
         r         $i32tox
         -2,a7     s7
         s1        a7             ; calculate address of log message
         s2        3
         s1        s1-s2
         s2        o'15           ; dest=1, class=1, override=1
         s0        F$MSG          ; issue the message
         ex
         a1        0,a7           ; advance to next word
         a1        a1+1
         0,a7      a1
         a2        1,a7           ; retrieve last word address + 1
         j         1b
2:
         a7        a7+1           ; discard first and last addresses
         a7        a7+1
         a0        ,a7            ; pop return address and return
         a7        a7+1
         b00       a0
         j         b00

**
*  $dmpa - Dump A registers to log file
*
*  All A and S register values on entry are saved on the stack and restored
*  on return.
*
         entry     $dmpa
$dmpa:   bss       0
         -17,a7    a0             ; save A registers
         -16,a7    a1
         -15,a7    a2
         -14,a7    a3
         -13,a7    a4
         -12,a7    a5
         -11,a7    a6
         -10,a7    a7
         -9,a7     s0             ; save S registers
         -8,a7     s1
         -7,a7     s2
         -6,a7     s3
         -5,a7     s4
         -4,a7     s5
         -3,a7     s6
         -2,a7     s7
         a0        b00            ; save return address
         -1,a7     a0
         s1        0              ; store end-of-message on stack
         -18,a7    s1
         a1        7              ; initialize index of stored register
1:
         a2        10             ; retrieve next register
         a2        a7-a2
         a2        a2-a1
         s1        ,a2
         a1        a1-1           ; decrement index
         -20,a7    a1
         r         $i24too        ; convert register value to octal
         a2        19             ; store result
         a2        a7-a2
         ,a2       s7
         s1        a2
         s2        o'15           ; dest=1, class=1, override=1
         s0        F$MSG          ; issue log message
         ex
         a1        -20,a7         ; retrieve index
         a0        a1
         jap       1b             ; if not done
         a0        -1,a7          ; restore return address
         b00       a0
         a0        -17,a7         ; restore A registers
         a1        -16,a7
         a2        -15,a7
         a3        -14,a7
         a4        -13,a7
         a5        -12,a7
         a6        -11,a7
         a7        -10,a7
         s0        -9,a7          ; restore S registers
         s1        -8,a7
         s2        -7,a7
         s3        -6,a7
         s4        -5,a7
         s5        -4,a7
         s6        -3,a7
         s7        -2,a7
         j         b00

**
*  $dmps - Dump S registers to log file
*
*  All A and S register values on entry are saved on the stack and restored
*  on return.
*
         entry     $dmps
$dmps:   bss       0
         -17,a7    a0             ; save A registers
         -16,a7    a1
         -15,a7    a2
         -14,a7    a3
         -13,a7    a4
         -12,a7    a5
         -11,a7    a6
         -10,a7    a7
         -9,a7     s0             ; save S registers
         -8,a7     s1
         -7,a7     s2
         -6,a7     s3
         -5,a7     s4
         -4,a7     s5
         -3,a7     s6
         -2,a7     s7
         a0        b00            ; save return address
         -1,a7     a0
         s1        0              ; store end-of-message on stack
         -18,a7    s1
         a1        7              ; initialize index of stored register
1:
         a2        2              ; retrieve next register
         a2        a7-a2
         a2        a2-a1
         s1        ,a2
         a1        a1-1           ; decrement index
         -22,a7    a1
         s2        <24
         s3        s2&s1
         -19,a7    s3             ; store least significant 24 bits
         s1        s1>24
         s3        s2&s1
         -20,a7    s3             ; store middle 24 bits
         s1        s1>24
         s1        s2&s1
         r         $i24too        ; convert top 16 bits to octal
         s6        >16            ; convert top two leading 0's to blanks
         s7        #s6&s7
         s6        X'2020
         s6        s6<48
         s7        s6!s7
         -21,a7    s7
         s1        -20,a7         ; convert middle 24 bits to octal
         r         $i24too
         -20,a7    s7
         s1        -19,a7         ; convert low 24 bits to octal
         r         $i24too
         a2        19             ; store result
         a2        a7-a2
         ,a2       s7
         a2        a2-1           ; point to first word of digits
         a2        a2-1
         s1        a2
         s2        o'15           ; dest=1, class=1, override=1
         s0        F$MSG          ; issue log message
         ex
         a1        -22,a7         ; retrieve index
         a0        a1
         jap       1b             ; if not done
         a0        -1,a7          ; restore return address
         b00       a0
         a0        -17,a7         ; restore A registers
         a1        -16,a7
         a2        -15,a7
         a3        -14,a7
         a4        -13,a7
         a5        -12,a7
         a6        -11,a7
         a7        -10,a7
         s0        -9,a7          ; restore S registers
         s1        -8,a7
         s2        -7,a7
         s3        -6,a7
         s4        -5,a7
         s5        -4,a7
         s6        -3,a7
         s7        -2,a7
         j         b00

         end
