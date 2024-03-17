#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

int close(int fd)
{
    FtEntry *entry;
    int n;
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
    if ((entry->access & O_ACCMODE) == O_WRONLY && entry->position > 0 && !IS_STDERR(entry)) {
        rc = _coswed(entry);
        if (rc == 0 && !IS_STDOUT(entry)) {
            rc = _coscls(&entry->odn);
        }
    }
    _ftFree(entry);
    if (rc != 0) {
        errno = EIO;
        return -1;
    }
    return 0;
}

