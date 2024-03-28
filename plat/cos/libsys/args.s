#include "cos.h"

         EXT       $pack,$unpack

**
*  $pargs - Parse command line arguments
*
*  This function parses the command line image in the job communication area
*  and produces a vector of addresses, each address pointing to a packed
*  character string representing a command line token. Each token is 0-byte
*  delimited, and the vector itself is delimited by a word of 0.
*
*  Exit:
*    (A1) Pointer to vector of token addresses
*    (A2) number of addresses in vector
*

text:    SECTION   code

         ENTRY     $pargs
$pargs:  ENTER
         S0        0              ; initialize argument count
         argc,     S0
         A0        charv          ; initialize address of next token
         nxtokn,   A0
         A1        JCCCI          ; unpack control card image
         A2        charv
         A3        (JCCPR-JCCCI)*8
         R         $unpack
         A1        charv
         R         toupper        ; convert lower case to upper case
         A1        charv
1:
         A2        A1             ; start of next token
2:
         S1        ,A1            ; fetch next character
         S0        S1
         JSZ       9f             ; if end of command
         S2        ','R
         S0        S1\S2
         JSZ       4f             ; if end of token
         S2        ':'R
         S0        S1\S2
         JSZ       4f             ; if end of token
         S2        '('R
         S0        S1\S2
         JSZ       4f             ; if end of token
         S2        '='R
         S0        S1\S2
         JSZ       3f             ; if end of keyword token
         S2        '.'R
         S0        S1\S2
         JSZ       9f             ; if end of command
         S2        ')'R
         S0        S1\S2
         JSZ       9f             ; if end of command
         S2        X'27
         S0        S1\S2
         JSZ       6f             ; if start of string
         A1        A1+1
         J         2b
*
*  Process a keyword token
*
3:
         A3        A1-A2          ; calculate length of token
         A3        A3+1
         J         5f
*
*  Process a non-keyword token
*
4:
         A3        A1-A2          ; calculate length of token
5:
         B01       A1
         A1        A2             ; start of token
         A2        nxtokn,        ; where to deliver packed token
         A4        argc,          ; store address of packed token in argument vector
         argv,A4   A2
         A4        A4+1           ; increment argc
         argc,     A4
         R         $pack          ; pack token
         A2        A2+1           ; ensure 0-byte delimiter
         S0        0
         ,A2       S0
         A2        A2+1           ; advance next token address
         nxtokn,   A2
         A1        B01
         A1        A1+1
         J         1b
*
*  Process a string token
*
6:
         A1        A1+1           ; advance past opening quote character
         A2        A1             ; start of string
         S2        X'27
7:
         S1        ,A1
         S0        S1
         JSZ       8f             ; if end of string
         S0        S1\S2
         JSZ       8f             ; if end of string
         A1        A1+1
         J         7b
8:
         A3        A1-A2          ; calculate length of string
         B01       A1
         A1        A2             ; start of token
         A2        nxtokn,        ; where to deliver packed token
         A4        argc,          ; store address of packed token in argument vector
         argv,A4   A2
         A4        A4+1           ; increment argc
         argc,     A4
         R         $pack          ; pack token
         A2        A2+1           ; ensure 0-byte delimiter
         S0        0
         ,A2       S0
         A2        A2+1           ; advance next token address
         nxtokn,   A2
         A1        B01
         S0        ,A1
         JSZ       p10            ; if end of command line
         A1        A1+1           ; advance past closing quote
         S1        ,A1            ; next character should be a delimiter
         A1        A1+1
         S0        S1
         JSZ       p10            ; if end of command line
         S2        '.'R
         S0        S1\S2
         JSZ       p10            ; if end of command line
         S2        ')'R
         S0        S1\S2
         JSZ       p10            ; if end of command line
         J         1b
*
*  Process last token of command line
*
9:
         A3        A1-A2          ; calculate length of token
         A1        A2             ; start of token
         A2        nxtokn,        ; where to deliver packed token
         A4        argc,          ; store address of packed token in argument vector
         argv,A4   A2
         A4        A4+1           ; increment argc
         argc,     A4
         R         $pack          ; pack token
         A2        A2+1           ; ensure 0-byte delimiter
         S0        0
         ,A2       S0
p10:
         A1        argv
         A2        argc,          ; argument count
         S0        0              ; store null address to mark end of vector
         argv,A2   S0

         RETURN

**
*  toupper - convert lower case to upper case
*
*  Entry:
*    (A1) : address of unpacked character list
*

toupper: S1        ,A1            ; fetch next character
         S0        S1
         JSZ       2f             ; if done
         S2        X'27
         S0        S1\S2
         JSZ       3f             ; if start of string
         S2        'a'R
         S0        S1-S2
         JSM       1f             ; if not lower case
         S2        'z'R+1
         S0        S1-S2
         JSP       1f             ; if not lower case
         S2        'a'R-'A'R
         S1        S1-S2
         ,A1       S1
1:
         A1        A1+1
         J         toupper
2:
         J         B00
3:
         A1        A1+1
         S1        ,A1
         S0        S1
         JSZ       2b             ; if end of character list
         S0        S1\S2
         JSN       3b             ; if not end of string
         A1        A1+1
         J         toupper

data:    SECTION   data

nxtokn:  BSS       1

argc:    BSS       1

argv:    BSS       JCCPR-JCCCI
         CON       0

charv:   BSS       (JCCPR-JCCCI)*8
         CON       0

         END
