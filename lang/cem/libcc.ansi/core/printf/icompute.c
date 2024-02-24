/*
 * icompute.c - compute an integer
 */
/* $Id$ */

#include <stdio.h>

#if ACKCONF_WANT_STDIO

/* This routine is used in doprnt.c as well as in tmpfile.c and tmpnam.c. */

#define _MAX_DIGITS 64

static char digits[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};

char* _i_compute(unsigned long val, int base, char* s, int nrdigits) {
	char *bp;
	char buf[_MAX_DIGITS+1];
	int mask;
	int shift;

	bp = buf + _MAX_DIGITS;
        *bp-- = '\0';

	if (base == 10) {
		while ((val != 0 || nrdigits > 0) && bp >= buf) {
			*bp-- = (val % 10) + '0';
			val /= 10;
			nrdigits -= 1;
		}
	}
	else {
		switch (base) {
		case 2:
			mask  = 1;
			shift = 1;
			break;
		case 8:
			mask  = 0x07;
			shift = 3;
			break;
		default:
		case 16:
			mask  = 0x0f;
			shift = 4;
			break;
		}
		while ((val != 0 || nrdigits > 0) && bp >= buf) {
			*bp-- = digits[val & mask];
			val >>= shift;
			nrdigits -= 1;
		}
	}

        while (nrdigits-- > 0) *s++ = '0';
	while (*++bp != '\0' ) *s++ = *bp;
        *s = '\0';
	return s;
}

#endif
