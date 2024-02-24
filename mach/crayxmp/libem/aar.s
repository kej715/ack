         entry     %aar
         entry     %%aarval
         ext       @earray
text:    section   code

**
*  AAR - load address of array element
*
*  Entry
*    (SP)   : byte address of array descriptor
*    (SP+1) : array index
*    (SP+2) : byte address of array
*
*  Exit
*    s7 : byte address of selected array element
*
%aar:    bss       0
         a1        1f             ; return address
         b01       a1
         a1        2f             ; trap handler
         b02       a1
         j         %%aarval
1:
         a1        3              ; empty stack
         a7        a7+a1
         j         b00
2:
         a1        3              ; empty stack
         a7        a7+a1
         j         @earray

**
*  %%aarval - validate array reference
*
*  Entry
*    (SP)   : byte address of array descriptor
*    (SP+1) : array index
*    (SP+2) : byte address of array
*    b01    : return address
*    b02    : address of trap handler
*
*  Exit
*    s7 : byte address of selected array element
*
%%aarval: bss      0
         s1        0,a7           ; get byte address of array descriptor
         s1        s1>3           ; convert to word address
         a1        s1
         s1        1,a7           ; get array index
         s2        ,a1            ; get lower bound of indices
         s1        s1-s2          ; adjust index relative to lower bound
         s0        s1
         jsm       2f             ; if index less than lower bound
         jsz       1f             ; if index is 0 (no need to check upper bound or multiply by element size)
         s2        1,a1           ; get upper bound of indices
         s0        s2-s1
         jsm       2f             ; if index greater than upper bound
         s2        2,a1           ; get number of bytes per element
         s3        o'40060        ; convert index and element size to float
         s3        s3<48
         s1        s1!s3
         s1        +Fs1
         s2        s2!s3
         s2        +Fs2
         s1        s1*Fs2         ; index * size
         s2        <15            ; exponent mask
         s3        s1
         s3        s3>48
         s3        s3&s2          ; isolate exponent
         s2        o'40060        ; calculate shift count for mantissa
         s2        s2-s3
         a1        s2
         s3        <48            ; isolate mantissa
         s1        s3&s1
         s1        s1>a1          ; de-normalize it (i.e., convert to integer)
1:
         s7        2,a7           ; get byte address of array
         s7        s7+s1          ; add offset to element
         j         b01
2:
         j         b02            ; pass control to trap handler

         end
