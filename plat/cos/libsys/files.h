#ifndef FILES_H
#define FILES_H

#include <sys/types.h>

typedef struct dsp {
    char fname[8];
    u64  first;
    u64  in;
    u64  out;
    u64  limit;
    u64  other[19];
} DSP;

typedef struct odn {
    char fname[8];
    u64  attrs;
} ODN;

typedef struct ftEntry {
    DSP dsp;                     /* COS DataSet Parameter table        */
    ODN odn;                     /* COS Open Dataset Name table        */
    int fd;                      /* file descriptor number             */
    int status;                  /* status after I/O operation         */
    u64 unusedBits;              /* unused bits in last word of record */
    int allocated;               /* 1 if entry allocated for use       */
    int access;                  /* file access mode                   */
    u64 position;                /* current file position              */
    int in;                      /* index of next byte to store in uda */
    int out;                     /* index of next byte to get from uda */
    int isDirty;                 /* 1 if uda has unflushed bytes       */
    u8  *uda;                    /* user data area                     */
} FtEntry;

void    _bcopy(void *dst, void *src, int ct);
u64     _bp2wp(void *ptr);
int     _coscls(ODN *odn);
int     _cosopn(ODN *odn, int pd);
int     _cosrdp(FtEntry *entry, void *uda, int ct);
int     _cosrew(FtEntry *entry);
int     _cosrls(ODN *odn);
int     _coswdr(FtEntry *entry, void *uda, int ct, int unusedBits);
int     _coswdp(FtEntry *entry, void *uda, int ct);
int     _coswed(FtEntry *entry);
FtEntry *_ftAllo(void);
int     _ftFlsh(FtEntry *entry);
void    _ftFree(FtEntry *entry);
FtEntry *_ftPtr(int fd);
void    *_wp2bp(u64 u);

#endif
