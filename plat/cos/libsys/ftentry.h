#ifndef FTENTRY_H
#define FTENTRY_H

*
*  This header defines assembly language equivalences reflecting the
*  structure of the FtEntry type defined in sys/files.h. If the definition
*  in sys/files.h changes, this file must be updated to reflect them.
*
*  FtEntry is defined in sys/files.h as follows:
*
*  typedef struct ftEntry {
*      ODN odn;                     /* COS Open Dataset Name table        */
*      int fd;                      /* file descriptor number             */
*      int status;                  /* status after I/O operation         */
*      u64 unusedBits;              /* unused bits in last word of record */
*      int allocated;               /* 1 if entry allocated for use       */
*      int access;                  /* file access mode                   */
*      u64 position;                /* current file position              */
*      int in;                      /* index of next byte to store in uda */
*      int out;                     /* index of next byte to get from uda */
*      int isDirty;                 /* 1 if uda has unflushed bytes       */
*      int blankCount;              /* COS blank compression indicator    */
*      u8  *uda;                    /* user data area                     */
*      u64 cioBuffer;               /* word address of CIO buffer         */
*  } FtEntry;
*

FTE$ODN:  = 0
FTE$FD:   = FTE$ODN+2
FTE$STAT: = FTE$FD+1
FTE$BITS: = FTE$STAT+1
FTE$ALLO: = FTE$BITS+1
FTE$ACC:  = FTE$ALLO+1
FTE$POS:  = FTE$ACC+1
FTE$IN:   = FTE$POS+1
FTE$OUT:  = FTE$IN+1
FTE$DIRT: = FTE$OUT+1
FTE$BLNK: = FTE$DIRT+1
FTE$UDA:  = FTE$BLNK+1
FTE$CIOB: = FTE$UDA+1

#endif
