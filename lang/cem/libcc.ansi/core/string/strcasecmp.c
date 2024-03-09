#include <ctype.h>
#include <stdint.h>

int strcasecmp(const char *s1, const char *s2) {
    unsigned int c1;
    unsigned int c2;
    int r;

    for (;;) {
        c1 = (unsigned int)*s1++;
        c2 = (unsigned int)*s2++;
        if (isalpha(c1) && islower(c1)) c1 -= 0x20;
        if (isalpha(c2) && islower(c2)) c2 -= 0x20;
        r = c1 - c2;
        if (r != 0 || c1 == 0) return r;
    }
}
