#include "cos.h"

TEXT:    SECTION   MIXED

**
*  $REWD - Rewind file
*
*  Entry:
*    (A1) DSP address
*
*  Return conditions:
*    (S1) Error status:
*           = 0 No errors encountered.
*           = 1 Unrecovered data error encountered.
*
*  Uses: S2
*
         ENTRY     $REWD
$REWD:   ENTER

$REW1:   S0        DPBIO,A1
         JSM       $REW4          ; if buffered I/O busy
         S2        BIOFREW        ; Function Rewind
         S2        S2<(D'63-D'9)  ; position function code
         S1        A2             ; merge user data area address
         S1        S1!S2
         DPBIO,A1  S1
         S0        F$BIO          ; initiate function
         S1        A1
         EX
$REW2:   RECALL    A1             ; wait for function to complete
         S0        DPBIO,A1
         JSM       $REW2          ; if not complete
         S0        S0<1
         JSM       $REW3          ; if error
         S1        0              ; no error
         RETURN

$REW3:   S1        1              ; set error indication
         RETURN

$REW4:   RECALL    A1
         J         $REW1

**
*  $RWDP/$RWDR - Read Words Partial/Record
*
*  Entry:
*    (A1) DSP address
*    (A2) FWA of user data area (UDA)
*    (A3) Requested word count (CT)
*
*  Return conditions:
*    (A1) DSP address
*    (A2) FWA of user data area (UDA)
*    (A3) Requested word count (CT)
*    (A4) Actual LWA+1 of data transferred to UDA. (A4)=(A2) if a null
*         record was read.
*    (S0) Condition of termination:
*           < 0 EOR encountered.
*           = 0 Null record, EOF, EOD, or unrecovered data error
*               encountered.
*           > 0 User-specified count (A3) exhausted before EOR is
*               encountered. For partial read (READP) if EOR and end of
*               count coincide, EOR takes precedence.
*    (S1) Error status:
*           = 0 No errors encountered.
*           = 1 Unrecovered data error encountered.
*    (S6) Contents of DPCWF if (S0)<=0 and (S1)=0, otherwise, meaningless.
*         Note that for READ/READP, the unused bit count can also be
*         obtained from S6 if (S0)<O.
*
*  Uses: S2, S3
*
         ENTRY     $RWDP
$RWDP:   ENTER
         S2        BIOFRRP        ; Function Read Record Partial
         J         $RWD

         ENTRY     $RWDR
$RWDR:   ENTER
         S2        BIOFRR         ; Function Read Record
         J         $RWD

$RWD:    S0        DPBIO,A1
         JSM       $RWD5          ; if buffered I/O busy
         S2        S2<(D'63-D'9)  ; position function code
         S3        A3
         S3        S3<(D'63-D'39) ; position and merge word count
         S1        S2!S3
         S2        A2             ; merge user data area address
         S1        S1!S2
         DPBIO,A1  S1
         S0        F$BIO          ; initiate function
         S1        A1
         EX
$RWD1:   RECALL    A1             ; wait for function to complete
         S2        DPBIO,A1
         S0        S2
         JSM       $RWD1          ; if not complete
         S0        S0<1
         JSM       $RWD4          ; if error
         S2        S2>(D'63-D'39) ; position and isolate count of words read
         A0        S2
         JAZ       $RWD3          ; if no words read
         A4        S2             ; compute LWA+1 of data transferred to UDA
         S2        A4             ; isolate word count
         A4        A2+A4
         S1        A3
         S0        S2-S1
         JSM       $RWD2          ; if words read < words requested
         S1        0              ; no error
         S0        1              ; all requested words read
         RETURN

$RWD2:   S6        DPBUBC,A1      ; position and isolate unused bit count
         S6        S6>(D'63-D'15)
         S2        <6
         S6        S6&S2
         S1        0              ; no error
         S0        -1             ; indicate EOR
         RETURN

$RWD3:   A4        A2             ; no words read, determine whether EOR/EOF/EOD
         S2        DPCWF,A1       ; check for EOR
         S3        <2
         S2        S2>(D'63-D'03)
         S0        S2&S3
         JSZ       $RWD2          ; if EOR
         S1        0              ; no error
         S0        0              ; indicate EOF/EOD
         RETURN

$RWD4:   S1        1              ; indicate error encountered
         S0        0
         RETURN

$RWD5:   RECALL    A1
         J         $RWD

**
*  $WWDS/$WWDR - Write Words Partial/Record
*
*  Entry:
*    (A1) DSP address
*    (A2) FWA of user data area (UDA)
*    (A3) Requested word count (CT)
*    (S2) Unused bit count ($WWDR)
*
*  Return conditions:
*    (A1) DSP address
*    (A2) FWA of user data area (UDA)
*    (A3) Requested word count (CT)
*    (S1) Error status:
*           = 0 No errors encountered.
*           = 1 Unrecovered data error encountered.
*
*  Uses: S3, S4
*
         ENTRY     $WWDS
$WWDS:   ENTER
         S2        0              ; Unused bit count (ignored)
         S3        BIOFWRP        ; Function Write Record Partial
         J         $WWD

         ENTRY     $WWDR
$WWDR:   ENTER
         S3        BIOFWR         ; Function Write Record
         J         $WWD

$WWD:    S0        DPBIO,A1
         JSM       $WWD3          ; if buffered I/O busy
         S2        S2<(D'63-D'15) ; position unused bit count
         S3        S3<(D'63-D'9)  ; position function code
         S4        A3
         S4        S4<(D'63-D'39) ; position word count
         S1        S2!S3          ; merge function code, bit count, word count
         S1        S1!S4
         S2        A2             ; merge user data area address
         S1        S1!S2
         DPBIO,A1  S1
         S0        F$BIO          ; initiate function
         S1        A1
         EX
$WWD1:   RECALL    A1             ; wait for function to complete
         S0        DPBIO,A1
         JSM       $WWD1          ; if not complete
         S0        S0<1
         JSM       $WWD2          ; if error
         S1        0              ; set no errors encountered
         RETURN

$WWD2:   S1        1              ; indicate error encountered
         RETURN

$WWD3:   RECALL    A1
         J         $WWD

**
*  $WEOD - Write End-of-Data
*
*  Entry:
*    (A1) DSP address
*
*  Return conditions:
*    (A1) DSP address
*    (S1) Error status:
*           = 0 No errors encountered.
*           = 1 Unrecovered data error encountered.
*
*  Uses: S2
*
         ENTRY     $WEOD
$WEOD:   ENTER
         S2        BIOFEOD
         J         $WEFD

**
*  $WEOF - Write End-of-File
*
*  Entry:
*    (A1) DSP address
*
*  Return conditions:
*    (A1) DSP address
*    (S1) Error status:
*           = 0 No errors encountered.
*           = 1 Unrecovered data error encountered.
*
*  Uses: S2
*
         ENTRY     $WEOF
$WEOF:   ENTER
         S2        BIOFEOF
         J         $WEFD

$WEFD:   S0        DPBIO,A1
         JSM       $WEFD3         ; if buffered I/O busy
         S2        S2<(D'63-D'9)  ; position and store function code
         DPBIO,A1  S2
         S0        F$BIO          ; initiate function
         S1        A1
         EX
$WEFD1:  RECALL    A1             ; wait for function to complete
         S0        DPBIO,A1
         JSM       $WEFD1         ; if not complete
         S0        S0<1
         JSM       $WEFD2         ; if error
         S1        0              ; set no errors encountered
         RETURN

$WEFD2:  S1        1              ; indicate error
         RETURN

$WEFD3:  RECALL    A1
         J         $WEFD

         END
