#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/files.h>
#include <sys/syslog.h>

extern void syslog(char *msg, int dest, int class, int override);

static FtEntry fileTable[COS_MAX_OPEN_FILES];

static int isInit = 0;

void _cosrst(FtEntry *entry) {
    if (entry != NULL) {
        entry->status = 0;
    }
}

FtEntry *_ftAllo(void) {
    FtEntry *entry;
    int fd;

    for (entry = fileTable, fd = 0; fd < COS_MAX_OPEN_FILES; fd++, entry++) {
        if (entry->allocated == 0) {
            if (entry->uda == NULL) {
                entry->uda = (u8 *)malloc(COS_UDA_SIZE_BYTES);
                if (entry->uda == NULL) return NULL;
                entry->cioBufAddr = _bp2wp(malloc(sizeof(u64) * COS_CIO_BUF_SIZE));
                if (entry->cioBufAddr == 0) return NULL;
            }
            entry->dsp.first = entry->cioBufAddr;
            entry->dsp.in = entry->dsp.out = entry->dsp.first;
            entry->dsp.limit = entry->dsp.first + COS_CIO_BUF_SIZE;
            entry->dsp.cwf = entry->dsp.lpw = entry->dsp.bio = 0;
            entry->status = 0;
            entry->in = entry->out = 0;
            entry->position  = 0;
            entry->allocated = 1;
            return entry;
        }
    }
    return NULL;
}

DSP *_ftDsp(int fd) {
    FtEntry *entry;

    entry = _ftPtr(fd);

    return (entry != NULL) ? &entry->dsp : NULL;
}

void _ftFini(void) {
    fclose(stdout);
    fclose(stderr);
}

void _ftFree(FtEntry *entry) {
    entry->allocated = 0;
}

void _ftInit(void) {
    FtEntry *entry;
    int fd;

    if (isInit == 0) {
        for (entry = fileTable, fd = 0; fd < COS_MAX_OPEN_FILES; fd++, entry++) {
            entry->fd = fd;
        }
        isInit = 1;
        if (freopen("$IN", "r", stdin) == NULL 
            || freopen("$OUT", "w", stdout) == NULL
            || freopen("$ERR", "w", stderr) == NULL) {
            syslog("Failed to initialize stdio", SYSLOG_USER|SYSLOG_SYSTEM, 1, 1);
            exit(1);
        }
    }
}

FtEntry *_ftPtr(int fd) {

    return (fd >= 0 && fd < COS_MAX_OPEN_FILES) ? fileTable + fd : NULL;
}
