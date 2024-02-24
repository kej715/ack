text:    section   code

**
*  @%bp2wp - translate byte pointer to word pointer
*
*  Entry
*    (SP) : byte pointer
*
*  Exit
*    S7 : word pointer
*
         entry     @%bp2wp
@%bp2wp: bss      0
         s7        ,a7
         s7        s7>3
         j         b00

         end
