#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include "files.h"

int close(int fd)
{
    FtEntry *entry;
    int n;
    int rc;

    entry = _ftPtr(fd);
    if (entry == NULL) {
        errno = EBADF;
        return -1;
    }
    if (entry->allocated == 0) return -1;
    if (entry->isDirty) {
        n = _ftFlsh(entry);
        if (n < 0) return -1;
    }
    if ((entry->access & O_ACCMODE) == O_WRONLY && entry->position > 0) {
        rc = _coswed(entry);
        if (rc != 0) return -1;
    }
    rc = _coscls(&entry->odn);
    _ftFree(entry);
    if (rc != 0) {
        errno = EIO;
        return -1;
    }
    return 0;
}

