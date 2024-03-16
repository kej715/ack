#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/files.h>

int _reopen(int fd)
{
    FtEntry *entry;
    int mode;
    int n;
    int pd;
    int rc;

    entry = _ftPtr(fd);
    if (entry == NULL || entry->allocated == 0) {
        errno = EBADF;
        return -1;
    }
    if (entry->isDirty) {
        n = _ftFlsh(entry);
        if (n < 0) return -1;
    }
    if ((entry->access & O_ACCMODE) == O_WRONLY && entry->position > 0) {
        rc = _coswed(entry);
        if (rc != 0) return -1;
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

    rc = _cosopn(&entry->odn, pd);
    if (rc != 0) {
        errno = EIO;
        return -1;
    }

    entry->dsp.first = entry->cioBufAddr;
    entry->dsp.in = entry->dsp.out = entry->dsp.first;
    entry->dsp.limit = entry->dsp.first + COS_CIO_BUF_SIZE;
    entry->dsp.cwf = entry->dsp.lpw = entry->dsp.bio = 0;
    entry->status = 0;
    entry->in = entry->out = 0;
    entry->position  = 0;

    return 0;
}
