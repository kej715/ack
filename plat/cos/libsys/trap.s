#include "cos.h"
#include "trap.h"

         ext       @ignmask
         ext       @syslog
         ext       $i24too
         ext       $i2d@24

text:    section   code

**
*  %%trp - system trap handler
*
*  Entry
*    s1 : trap number
*
         entry     %%trp
%%trp:   bss       0
         a0        b00            ; save return address
         %%trpP,   a0
         s2        ESTACK
         s3        s1-s2
         jsp       1f             ; if trap cannot be ignored

*        Check if trap must be ignored

         s2        @ignmask,
         s3        >1
         a1        s1
         s3        s3>a1
         s0        s3&s2
         jsz       1f             ; if trap should not be ignored
         j         b00
1:
         a1        @trphand,
         a0        a1 
         jaz       2f             ; if no user-provided trap handler defined
         b01       a1
         s0        0              ; clear trap handler address
         @trphand, s0
         j         b01            ; call user-provided trap handler
*
*  Default trap handler - issue log message and exit
*
2:
         s2        EBADGTO+1
         s0        s1-s2
         jsp       4f             ; if trap number not valid table index
         a1        s1
         a1        %%trptbl,a1    ; address of log message
         a0        a1
         jaz       4f             ; if invalid address
         s7        ,a1            ; get trap name from table
3:
         s1        >40            ; merge trap name (or digits) into message
         s2        %%trpA,
         s2        s1&s2
         s3        s7
         s3        s3>40
         s2        s2!s3
         %%trpA,   s2
         s7        s7<24
         s6        %%trpD,
         s7        s7!s6
         %%trpA+1, s7
         s1        %%trpP,        ; format return address
         s1        s1>2           ; convert from parcel to word address
         r         $i24too
         s6        s7
         s6        s6>16          ; merge top 6 digits into message
         s1        %%trpB,
         s6        s6!s1
         %%trpB,   s6
         s7        s7<48          ; position bottom 2 digits
         s1        %%trpP,        ; calculate parcel number
         s2        <2
         s1        s2&s1
         s2        'A'R           ; form parcel indicator and merge into message
         s2        s2+s1
         s2        s2<40
         s7        s7!s2
         %%trpB+1, s7
         s1        %%trpA         ; issue log message
         s2        o'15           ; dest=1, class=1, override=1
         s0        F$MSG
         ex
         s0        F$ABT
         ex
4:
         a1        s1             ; translate trap number to decimal
         s7        %%trpC,
         r         $i2d@24
         j         3b

data:    section   data
*
*  Trap message
*
%%trpA:  data      'Trap 'Z
         data      0
%%trpB:  data      'P 'Z
         data      0
%%trpC:  data      '        '
%%trpD:  data      '   'R
%%trpP:  bssz      1

rom:     section   data
*
*  Table of default trap messages
*
%%trptbl: =        w.*
         data      ='EARRAY  '    ;  0
         data      ='ERANGE  '    ;  1
         data      ='ESET    '    ;  2
         data      ='EIOVFL  '    ;  3
         data      ='EFOVFL  '    ;  4
         data      ='EFUNFL  '    ;  5
         data      ='EIDIVZ  '    ;  6
         data      ='EFDIVZ  '    ;  7
         data      ='EIUND   '    ;  8
         data      ='EFUND   '    ;  9
         data      ='ECONV   '    ; 10
         data      0,0,0,0,0
         data      ='ESTACK  '    ; 16
         data      ='EHEAP   '    ; 17
         data      ='EILLINS '    ; 18
         data      ='EODDZ   '    ; 19
         data      ='ECASE   '    ; 20
         data      ='EMEMFLT '    ; 21
         data      ='EBADPTR '    ; 22
         data      ='EBADPC  '    ; 23
         data      ='EBADLAE '    ; 24
         data      ='EBADMON '    ; 25
         data      ='EBADLIN '    ; 26
         data      ='EBADGTO '    ; 27

         end
