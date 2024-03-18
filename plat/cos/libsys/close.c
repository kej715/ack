#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

int close(int fd)
{
    FtEntry *entry;
    int mode;
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
    rc = 0;
    if (!IS_STDIN(entry) && !IS_STDOUT(entry) && !IS_STDERR(entry)) {
        mode = entry->access & O_ACCMODE;
        if (mode == O_RDWR) {
            rc = lseek(entry->fd, 0, SEEK_END);
            if (rc != -1) rc = 0;
        }
        if (rc == 0) {
            if (mode != O_RDONLY) {
                rc = _coswed(entry);
            }
            if (rc == 0) {
                rc = _coscls(&entry->odn);
            }
        }
    }
    _ftFree(entry);
    if (rc != 0) {
        errno = EIO;
        return -1;
    }
    return 0;
}

