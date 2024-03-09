#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

ssize_t read(int fd, void *buffer, size_t count) {
    u8 *bp;
    u8 cwf;
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
            if (entry->status == COS_EOR && (entry->access & O_TEXT) != 0) {
                *bp++ = '\n';
                entry->status = 0;
            }

            if (entry->status != 0) break;

            entry->out = entry->in = 0;

            n = _cosrdp(entry, entry->uda, COS_UDA_SIZE);

            cwf = entry->dsp.cwf >> 60;
            if ((cwf & 1) != 0)
                entry->status = COS_EOD;
            else if ((cwf & 4) != 0)
                entry->status = COS_EOF;
            else if ((cwf & 8) != 0)
                entry->status = COS_EOR;

            if (n == -1) {
                errno = EIO;
                return -1;
            }

            entry->in = n * 8;
            if (entry->status == COS_EOR) {
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
