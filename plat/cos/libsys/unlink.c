#include <errno.h>
#include <string.h>
#include <sys/files.h>

int unlink(char *path) {
    int len;
    ODN odn;

    len = strlen(path);
    if (len > 8) {
        errno = EINVAL;
        return -1;
    }
    memset(&odn, 0, sizeof(ODN));
    memcpy(&odn.fname, path, len);

    if (_cosrls(&odn) == 0) {
        return 0;
    }
    else {
        errno = EIO;
        return -1;
    }
}
