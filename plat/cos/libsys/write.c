#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "files.h"

int _ftFlsh(FtEntry *entry) {
    int i;
    int n;
    int unusedBytes;
    int wc;

    wc = (entry->in + 7) >> 3;
    unusedBytes = (8 - (entry->in & 7)) & 7;
    for (i = 0; i < unusedBytes; i++) entry->uda[entry->in++] = 0;
    if (_coswdr(entry, entry->uda, wc, unusedBytes << 3) != wc) {
        errno = EIO;
        return -1;
    }
    entry->position += entry->in;
    n = entry->in;
    entry->in = 0;
    entry->isDirty = 0;

    return n;
}

ssize_t write(int fd, void *buffer, size_t count) {
    u8 *bp;
    u8 byte;
    FtEntry *entry;
    u8 *limit;
    int n;
    int rem;
    int si;

    entry = _ftPtr(fd);
    if (entry == NULL || entry->allocated == 0 || (entry->access & O_ACCMODE) == O_RDONLY) {
        errno = EBADF;
        return -1;
    }

    if ((entry->access & O_BINARY) != 0) {
        si  = 0;
        while (si < count) {
            rem = count - si;
            n   = COS_UDA_SIZE_BYTES - entry->in;
            if (n > rem) n = rem;
            _bcopy(&entry->uda[entry->in], (u8 *)buffer + si, n);
            si += n;
            entry->in += n;
            if (entry->in >= COS_UDA_SIZE_BYTES) {
                if (_coswdp(entry, entry->uda, COS_UDA_SIZE) != COS_UDA_SIZE) {
                    errno = EIO;
                    return -1;
                }
                entry->position += COS_UDA_SIZE_BYTES;
                entry->in = 0;
            }
        }
    }
    else {
        bp = (u8 *)buffer;
        limit = bp + count;
        while (bp < limit) {
            byte = *bp++;
            if (byte == '\n') {
                n = _ftFlsh(entry);
                if (n < 0) return -1;
                entry->position += 1;
            }
            else {
                entry->uda[entry->in++] = byte;
                if (entry->in >= COS_UDA_SIZE_BYTES) {
                    if (_coswdp(entry, entry->uda, COS_UDA_SIZE) != COS_UDA_SIZE) {
                        errno = EIO;
                        return -1;
                    }
                    entry->position += COS_UDA_SIZE_BYTES;
                    entry->in = 0;
                }
            }
        }
    }

    entry->isDirty = entry->in > 0;

    return count;
}
