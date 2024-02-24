#include "cos.h"

         ext       @strlen
         ext       %blm

         entry     @syslog

text:    section   code

;
;  void syslog(char *message, int dest, int class, int override);
;
@syslog:
         s1        0,a7           ; byte address of message
         s2        <3
         s0        s2&s1
         jsn       2f             ; if message not word-aligned
         s1        s1>3           ; convert to word address
1:
         s2        1,a7           ; destination log (user)
         s3        2,a7           ; message class
         s3        s3<3
         s2        s2!s3
         s3        3,a7           ; override
         s3        s3<2
         s2        s2!s3
         s0        F$MSG
         ex
         j         b00
2:
         a7        a7-1           ; push return address
         a0        b00
         ,a7       a0
         a7        a7-1           ; push byte address of message as param of strlen()
         ,a7       s1
         r         @strlen        ; get length of message
         a7        a7+1           ; remove strlen() parameter
         s2        1,a7           ; retrieve byte address of original message
         s6        1              ; account for null byte at end of string
         s7        s7+s6
         s3        7              ; calculate number of words needed for message
         s3        s3+s7
         s3        s3>3
         a2        s3             ; allocate space on stack for word-aligned message
         a7        a7-a2
         a1        a7             ; word-aligned message address to a1
         a7        a7-1           ; push length of message block
         ,a7       a2
         a7        a7-1           ; push address of word-aligned message block
         ,a7       a1
         s0        0              ; clear the allocated message block
3:
         a0        a2
         jaz       4f             ; if all words cleared
         ,a1       s0
         a1        a1+1
         a2        a2-1
         j         3b
4:
         s1        ,a7            ; retrieve address of word-aligned buffer
         s1        s1<3           ; convert to byte address
         a1        s7             ; length of message + 1
         r         %blm           ; copy message to word-aligned buffer on stack
         s1        ,a7            ; pop address of word-aligned buffer
         a7        a7+1
         a1        ,a7            ; pop length of message block
         a7        a7+1
         a7        a7+a1          ; pop message block
         a0        ,a7            ; restore return address
         a7        a7+1
         b00       a0
         j         1b

         end
