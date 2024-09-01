#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/files.h>

int open(const char *path, int access, ...)
{
    u8 *cioBuf;
    DSP *dsp;
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

    memset(entry->odn.fname, 0, 8);
    memcpy(entry->odn.fname, path, len);
    entry->odn.attrs = 0;
    entry->access    = access;
    entry->status    = 0;

    mode = access & O_ACCMODE;

    if (IS_STDIN(entry)) {
        if (mode != O_RDONLY || (access & O_BINARY) != 0) {
            errno = EINVAL;
            return -1;
        }
    }
    else if (IS_STDOUT(entry)) {
        if (mode != O_WRONLY || (access & O_BINARY) != 0) {
            errno = EINVAL;
            return -1;
        }
    }
    else if (IS_STDERR(entry)) {
        if (mode != O_WRONLY || (access & O_BINARY) != 0) {
            errno = EINVAL;
            return -1;
        }
        return entry->fd;
    }
    else {
        if ((access & O_TRUNC) != 0 && _exists(path)) {
            _cosrls(&entry->odn);
        }
        dsp = _ftDsp(entry);
        entry->odn.attrs = _bp2wp(dsp);
        memset(dsp, 0, sizeof(DSP));
        memcpy(dsp->fname, entry->odn.fname, 8);
        if (entry->cioBuffer == 0) {
            cioBuf = (u8 *)malloc(COS_CIO_BUF_SIZE * 8);
            if (cioBuf == NULL) {
                errno = EMFILE;
                _ftFree(entry);
                return -1;
            }
            entry->cioBuffer = _bp2wp(cioBuf);
        }
        dsp->first = entry->cioBuffer;
        dsp->in = dsp->out = dsp->first;
        dsp->limit = dsp->first + COS_CIO_BUF_SIZE;
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
        errno = ((access & O_CREAT) == 0) ? ENOENT : EMFILE;
        return -1;
    }

    return entry->fd;
}
