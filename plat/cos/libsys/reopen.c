#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

int _reopen(int fd)
{
    DSP *dsp;
    FtEntry *entry;
    int mode;
    int n;
    int pd;
    int rc;

    entry = _ftPtr(fd);
    if (entry == NULL
        || entry->allocated == 0
        || IS_STDIN(entry)
        || IS_STDOUT(entry)
        || IS_STDERR(entry)) {
        errno = EBADF;
        return -1;
    }
    if ((entry->flags & IsDirty) != 0) {
        n = _ftFlsh(entry);
        if (n < 0) return -1;
    }
    if ((entry->access & O_ACCMODE) == O_WRONLY && entry->position > 0) {
        rc = _coswed(entry);
        if (rc != 0) {
            errno = EIO;
            return -1;
        }
    }
    rc = _coscls(&entry->odn);
    if (rc != 0) {
        errno = EIO;
        return -1;
    }

    mode = entry->access & O_ACCMODE;
    if (mode == O_WRONLY)
        pd = 1;
    else if (mode == O_RDONLY)
        pd = 2;
    else
        pd = 3;

    entry->odn.attrs   = 0;
    entry->status      = 0;
    entry->position    = 0;
    entry->maxPosition = 0;
    entry->flags       = 0;
    entry->in          = 0;
    entry->out         = 0;
    dsp = _ftDsp(entry);
    memset(dsp, 0, sizeof(DSP));
    memcpy(dsp->fname, entry->odn.fname, 8);
    entry->odn.attrs = _bp2wp(dsp);
    dsp->first = entry->cioBuffer;
    dsp->in = dsp->out = dsp->first;
    dsp->limit = dsp->first + COS_CIO_BUF_SIZE;

    rc = _cosopn(&entry->odn, pd);
    if (rc != 0) {
        errno = EIO;
        return -1;
    }

    return 0;
}
