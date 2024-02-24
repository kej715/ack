         entry     %mon
         ext       @ebadmon

text:    section   code

**
*  MON - monitor call
*
*  Entry
*    S1   : monitor function number
*    (SP) : parameters
*
*  Exit
*    (SP) : optiohal result
*
%mon:    bss       0
         j         @ebadmon

         end
