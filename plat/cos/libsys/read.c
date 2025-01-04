#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

static int readNextSegment(FtEntry *entry) {
    u8 cwf;
    DSP *dsp;
    int n;

    entry->out = entry->in = 0;

    n = _cosrdp(entry, entry->uda, COS_UDA_SIZE);

    dsp = _getdsp(entry);
    cwf = dsp->cwf >> 60;
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

    return n;
}

ssize_t read(int fd, void *buffer, size_t count) {
    u8 b;
    u8 *bp;
    FtEntry *entry;
    u8 *limit;
    int n;

    entry = _ftPtr(fd);
    if (entry == NULL || entry->allocated == 0 || (entry->access & O_ACCMODE) == O_WRONLY) {
        errno = EBADF;
        return -1;
    }

    bp    = (u8 *)buffer;
    limit = bp + count;

    if ((entry->access & O_BINARY) == 0) { // text mode

        while (bp < limit) {
            if (entry->blankCount > 0) {
                *bp++ = ' ';
                entry->blankCount -= 1;
            }
            else if (entry->out >= entry->in) {
                if (entry->status == COS_EOR) {
                    *bp++ = '\n';
                    entry->status = 0;
                    entry->blankCount = 0;
                }

                if (entry->status != 0) break;

                if (readNextSegment(entry) == -1) return -1;

                if (entry->blankCount < 0 && entry->out < entry->in) {
                    /* blank count is biased by 36 octal */
                    b = entry->uda[entry->out++];
                    if (b >= 036) {
                        entry->blankCount = b - 036;
                    }
                    else {
                        *bp++ = 0x1b;
                        entry->out -= 1;
                    }
                }
            }
            else {
                b = entry->uda[entry->out++];
                if (b == 0x1b) { /* COS blank compression indication */
                    if (entry->out < entry->in) {
                        /* blank count is biased by 36 octal */
                        b = entry->uda[entry->out++];
                        if (b >= 036) {
                            entry->blankCount = b - 036;
                        }
                        else {
                            *bp++ = 0x1b;
                            entry->out -= 1;
                        }
                    }
                    else {
                        entry->blankCount = -1; /* count is in first byte of next segment */
                    }
                }
                else {
                    *bp++ = b;
                }
            }
        }
    }
    else { // binary mode

        while (bp < limit) {
            if (entry->out >= entry->in) {

                if (entry->status != 0) break;

                if (readNextSegment(entry) == -1) return -1;
            }
            else {
                *bp++ = entry->uda[entry->out++];
            }
        }
    }

    n = bp - (u8 *)buffer;
    entry->position += n;
    if (entry->position > entry->maxPosition) entry->maxPosition =  entry->position;

    return n;
}
