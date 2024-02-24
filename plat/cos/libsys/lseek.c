#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include "files.h"

static int reposition(FtEntry *entry, off_t position, u8 *buf, int bufSize) {
    int ct;
    int mode;
    int n;
  
    if (position < entry->position) {
        mode = entry->access & O_ACCMODE;
        if (position < 0 || mode == O_WRONLY) {
            errno = EINVAL;
            return -1;
        }
        if (_cosrew(entry) == -1) {
            errno = EIO;
            return -1;
        }
        entry->position = 0;
        while (entry->position < position) {
            ct = position - entry->position;
            if (ct > bufSize) ct = bufSize;
            n = read(entry->fd, buf, ct);
            if (n == -1) {
                errno = EIO;
                return -1;
            }
            else if (n < ct) {
                break;
            }
        }
    }
    else if (mode == O_RDONLY && position > entry->position) {
        errno = EINVAL;
        return -1;
    }
    while (entry->position < position) {
        ct = position - entry->position;
        if (ct > bufSize) ct = bufSize;
        memset(buf, 0, ct);
        n = write(entry->fd, buf, ct);
        if (n != ct) {
            errno = EIO;
            return -1;
        }
    }
    return 0;
}

off_t lseek(int fd, off_t offset, int whence) {
    u8 buf[4096];
    FtEntry *entry;
    int mode;
    int n;
    off_t newPos;

    entry = _ftPtr(fd);
    if (entry == NULL) {
        errno = EBADF;
        return -1;
    }
    if (entry->isDirty) {
        n = _ftFlsh(entry);
        if (n < 0) return -1;
    }

    newPos = offset;
    switch (whence) {
    case SEEK_END:
        mode = entry->access & O_ACCMODE;
        if (mode == O_RDONLY || mode == O_RDWR) {
            /*
             *  Position to end of file
             */
            for (;;) {
                n = read(entry->fd, buf, sizeof(buf));
                if (n == -1) {
                    errno = EIO;
                    return -1;
                }
                else if (n == 0) {
                    break;
                }
            }
        }
        /*
         *  Fall through
         */
    case SEEK_CUR:
        newPos += (off_t)entry->position;
        /*
         *  Fall through
         */
    case SEEK_SET:
        if (newPos != entry->position) {
            if (reposition(entry, newPos, buf, sizeof(buf)) == -1) return -1;
        }
        break;
    default:
        errno = EINVAL;
        return -1;
    }
    
    return entry->position;
}
