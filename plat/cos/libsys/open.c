#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

int open(const char* path, int access, ...)
{
    FtEntry *entry;
    int len;
    int mode;
    int pd;
    int rc;

    len = strlen(path);
    if (len > 7) {
        errno = EINVAL;
        return -1;
    }

    entry = _ftAllo();
    if (entry == NULL) {
        errno = EMFILE;
        return -1;
    }

    memset(entry->dsp.fname, 0, 8);
    memcpy(entry->dsp.fname, path, len);
    memcpy(entry->odn.fname, entry->dsp.fname, 8);
    entry->access = access;
    entry->status = 0;

    mode = access & O_ACCMODE;

    /* Map stderr onto system log */
    if (entry->fd == 2 && strcmp(path, "$ERR") == 0) {
        if (mode != O_WRONLY || (access & O_BINARY) != 0) {
            errno = EINVAL;
            return -1;
        }
        return entry->fd;
    }

    /* Open with saved position and specify user-managed DSP */
    entry->odn.attrs |= (1 << 60) | _bp2wp(&entry->dsp);
    if ((access & O_TRUNC) != 0 && strcmp(path, "$OUT") != 0) {
        _cosrls(&entry->odn);
    }

    if (mode == O_WRONLY)
        pd = 1;
    else if (mode == O_RDONLY)
        pd = 2;
    else
        pd = 3;

    rc = _cosopn(&entry->odn, pd);
    if (rc != 0) {
        _ftFree(entry);
        errno = EMFILE;
        return -1;
    }

    return entry->fd;
}
