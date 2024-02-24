text:    section   code

**
*  @%wp2bp - translate word pointer to byte pointer
*
*  Entry
*    (SP) : word pointer
*
*  Exit
*    S7 : byte pointer
*
         entry     @%wp2bp
@%wp2bp: bss      0
         s7        ,a7
         s7        s7<3
         j         b00

         end
