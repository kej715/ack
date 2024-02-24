         entry     %sar
         ext       %%aarval
         ext       %blm
         ext       @earray
text:    section   code

**
*  SAR - store array element
*
*  Entry
*    (SP)   : byte address of array descriptor
*    (SP+1) : array index
*    (SP+2) : byte address of array
*    (SP+3) : array element to store
*
%sar:    bss       0
         a1        1f             ; return address
         b01       a1
         a1        2f             ; trap handler
         b02       a1
         j         %%aarval
1:
         s1        ,a7            ; get byte address of array descriptor
         s1        s1>3           ; convert to word address
         a1        s1
         s1        2,a1           ; get number of bytes per array element
         s3        7              ; calculate number of words per element
         s3        s1+s3
         s3        s3>3
         a1        3              ; pop parameters from stack
         a7        a7+a1
         s2        a7             ; calculate byte address of source element
         s2        s2<3
         a1        s3             ; pop element from stack
         a7        a7+a1
         a1        s1             ; number of bytes to copy
         s1        s7             ; destination address from %%aarval
         j         %blm           ; copy the element from the stack to the array
2:
         s1        ,a7            ; get byte address of array descriptor
         s1        s1>3           ; convert to word address
         a1        s1
         s1        2,a1           ; get number of bytes per array element
         s2        7              ; calculate number of words per element
         s2        s1+s2
         s2        s2>3
         a1        3              ; pop parameters from stack
         a7        a7+a1
         a1        s3             ; pop array element
         a7        a7+a1
         j         @earray

         end
