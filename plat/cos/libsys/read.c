#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "files.h"

ssize_t read(int fd, void *buffer, size_t count) {
    u8 *bp;
    FtEntry *entry;
    u8 *limit;
    int n;

    entry = _ftPtr(fd);
    if (entry == NULL || entry->allocated == 0 || (entry->access & O_ACCMODE) == O_WRONLY) {
        errno = EBADF;
        return -1;
    }

    bp = (u8 *)buffer;
    limit = bp + count;

    while (bp < limit) {
        if (entry->out >= entry->in) {
            entry->out = entry->in = 0;
            if (entry->status == 0) break;
            if (entry->status < 0 && (entry->access & O_TEXT) != 0) {
                *bp++ = '\n';
            }
            n = _cosrdp(entry, entry->uda, COS_UDA_SIZE);
            if (n == -1) {
                errno = EIO;
                return -1;
            }
            entry->in = n * 8;
            if (entry->status <= 0) { /* EOR, EOF, or EOD */
                entry->in -= entry->unusedBits >> 3;
            }
        }
        else {
            *bp++ = entry->uda[entry->out++];
        }
    }

    n = bp - (u8 *)buffer;
    entry->position += n;

    return n;
}
