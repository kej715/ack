MAX%ARGV: = 25               ; max size of argv
MAX%OPEN: = 20               ; max open files

* Job Communication Block definitions
* Address of control card image in job communication area
JCCCI:    = 5                ; address of control card image
JCCPR:    = O'20             ; address of parsed command line parameters
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

text:   section code
%%start:  =        *
          start    %%start
*
*  arg-ify command line
*
*  Unpack the control card image
*
          a1       JCCCI
          a7       JCCPR
          a2       cci
          a3       8
          s1       <8
          a6       0         ; argc

start1:   a4       64
          s3       ,a1

start2:   a4       a4-a3
          s4       s3
          s4       s4>a4
          s4       s4&s1
          ,a2      s4
          a2       a2+1
          a0       a4
          jan      start2
          a1       a1+1
          a0       a1-a7
          jam      start1
          s7       0
          ,a2      s7
*
*  Assemble tokens from unpacked image
*
          a1       cci
          a2       args
          a3       argv0
          a4       8

start3:   s7       a2        ; store next argv entry
          s7       s7<3
          ,a3      s7
          a3       a3+1

start4:   a5       64
          s6       0

start5:   s1       ,a1       ; get next character from image
          a1       a1+1
          s0       s1
          jsz      start8    ; if end of image
          s2       X'2c      ; ','
          s0       s1\s2
          jsz      start7    ; if end of token
          s2       X'3a      ; ':'
          s0       s1\s2
          jsz      start7    ; if end of token
          s2       X'28      ; '('
          s0       s1\s2
          jsz      start7    ; if end of token
          s2       X'3d      ; '='
          s0       s1\s2
          jsz      start6    ; if end of keyword token
          s2       X'2e      ; '.'
          s0       s1\s2
          jsz      start8    ; if end of statement
          s2       X'29      ; ')'
          s0       s1\s2
          jsz      start8    ; if end of statement
          a5       a5-a4
          s1       s1<a5
          s6       s6!s1
          a0       a5
          jan      start5    ; if word not full
          ,a2      s6        ; store next full word
          a2       a2+1
          j        start4

start6:   a5       a5-a4     ; append '=' to token
          s1       s1<a5
          s6       s6!s1

start7:   ,a2      s6        ; store last part of token
          a2       a2+1
          a6       a6+1      ; argc += 1
          j        start3    ; process next token

start8:   ,a2      s6        ; store last part of token
          a6       a6+1      ; argc += 1
          s7       0         ; store NULL at end of argv
          ,a3      s7
          s6       a6        ; move argc to s6
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
          s1       JCHLM,    ; preset stack pointer to current field length
          s1       s1>24     ; preset heap pointer to HLM
          s3       s1&s2
          a5       s3
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
          s1       argv0     ; push argv
          s1       s1<3
          a7       a7-1
          ,a7      s1
          a7       a7-1      ; push argc
          ,a7      s6
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
          jsn      @%abort
          s0       F$ADV     ; advance to next job step
          ex

          entry    @%abort
@%abort:  s0       F$ABT
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

*  Storage for the argv array.

bss:      section  data
args:     bss      MAX%ARGV
argc:     bssz     1
argv0:    bssz     1
argv:     bssz     MAX%ARGV+1
envp:     bssz     1

cci:      bss      (JCCPR-JCCCI)*8
          bssz     1

          end
