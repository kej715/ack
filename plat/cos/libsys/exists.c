#include <errno.h>
#include <string.h>
#include <sys/files.h>

int _exists(const char *dsname)
{
    DDL ddl;
    int len;

    len = strlen(dsname);
    if (len > 7) {
        errno = EINVAL;
        return -1;
    }

    memset(&ddl, 0, sizeof(DDL));
    memcpy(ddl.dsname, dsname, len);
    ddl.w2 = 1 << 61; /* DDNFE = 1 */

    return _cosdnt(&ddl) == 0;
}
