MAX%ARGS: = 100              ; maximum number of command line arguments
MAX%OPEN: = 20               ; max open files

* Job Communication Block definitions
JCCCI:    = O'005            ; address of control card image
JCHLM:    = O'101            ; address of high limit of user code (bits 16-39)
JCFL:     = O'101            ; address of field length (bits 40-63)
JCDSP:    = O'102            ; Base address of DSP area (bits 40-63)
JCLFT:    = O'103            ; Base of LFT (bits 40-63)

* System function numbers
F$ADV:    = 0                ; advance to next job step
F$ABT:    = 1                ; abort job

          ext      @%ftFini
          ext      @%ftInit
          ext      @%m%a%i%n
          ext      @%pargs

text:   section code
%%start:  =        *
          start    %%start
*
*  Initialize local base, stack pointer, and heap pointer
*
          s1       JCLFT,    ; preset stack pointer to base of system-managed LFT's
          s2       <24
          s3       s1&s2
          s1       MAX%OPEN*2 ; allow for LFT's associated with max open files
          s3       s3-s1
          a7       s3
          a6       a7        ; preset local base to stack pointer
          s1       JCHLM,    ; preset heap pointer to current field length
          s1       s1>24
          s3       s1&s2
          a5       s3
*
*  Parse command line arguments
*
          a7       a7-1
          s1       argv
          s1       s1<3
          ,a7      s1
          a7       a7-1
          s1       argc
          s1       s1<3
          ,a7      s1
          a7       a7-1
          s1       JCCCI*8
          ,a7      s1
          r        @%pargs
          a1       3
          a7       a7+a1
*
*  Open stdin, stdout, stderr
*
          r        @%ftInit
*
*  Push the main() arguments
*
          s1       envp      ; push envp
          s1       s1<3
          a7       a7-1
          ,a7      s1
          s1       argv      ; push argv after converting to byte pointer
          s1       s1<3
          a7       a7-1
          ,a7      s1
          s1       argc,     ; push argc
          a7       a7-1
          ,a7      s1
*
*  Call main()
*
          r        @%m%a%i%n
          a7       a7+1      ; remove args from stack
          a7       a7+1
          ,a7      s7        ; push return value
*
*  Exit gracefully
*
          entry    @%exit
@%exit:   r        @%ftFini  ; finalize stdio
          s0       ,a7
          jsn      @%exit1
          s0       F$ADV     ; advance to next job step
          ex

@%exit1:  s0       F$ABT
          ex

data:     section data

*  Trap ignore mask

          entry    @ignmask
@ignmask: =        o.*
          bssz     1

*  Address of user-provided trap handler

          entry    @trphand
@trphand: =        w.*
          bssz     1

*  Last registered error number

          entry    @errno
@errno:   =        o.*
          bssz     1

*  This data block is used to store information about the current line number
*  and file.

          entry    hol0
hol0:     =        w.*
          bssz     8

*  Storage for argc, argv, and the envp array.

bss:      section  data
argc:     bss      1
argv:     bssz     MAX%ARGS+1
envp:     bssz     1

          end
