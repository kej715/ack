text:    section   code

**
*  @%frmptr - return caller's frame pointer
*
*  Exit:
*    s7 : caller's frame pointer
*
         entry     @%frmptr
@%frmptr:bss       0
         s7        a6
         s7        s7<3           ; convert frame pointer to byte pointer
         j         b00

         end
