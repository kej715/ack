         entry     %lar
         ext       %%aarval
         ext       %blm
         ext       @earray
text:    section   code

**
*  LAR - load array element
*
*  Entry
*    (SP)   : byte address of array descriptor
*    (SP+1) : array index
*    (SP+2) : byte address of array
*
%lar:    bss       0
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
         s2        7              ; calculate number of words per element
         s2        s1+s2
         s2        s2>3
         a1        3              ; pop parameters from stack
         a7        a7+a1
         a1        s3             ; allocate space on stack for array element
         a7        a7-a1
         a1        s1             ; number of bytes per element
         s1        a7             ; destination for block move
         s1        s1<3           ; convert to byte address
         s2        s7             ; source address from %%aarval
         j         %blm           ; copy the element to the stack
2:
         a1        3              ; empty stack
         a7        a7+a1
         j         @earray

         end
