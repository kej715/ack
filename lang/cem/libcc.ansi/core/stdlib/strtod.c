/* $Id$ */

#include <stdlib.h>
#include <ack/config.h>
#if defined(__crayxmp)
#include <ctype.h>
#else
#include "ext_fmt.h"
#endif

#if ACKCONF_WANT_FLOAT

double
strtod(const char* p, char** pp)
{
#if defined(__crayxmp)
	char c;
	double divisor = 1.0;
	int esign = 0;
	int exp = 0;
	double frac = 0.0;
	char *p1;
	double result = 0.0;
	int sign = 0;

	if (pp) *pp = (char *)p;

	while (isspace(*p)) p++;

	if (*p == '-') {
		sign = 1;
		p += 1;
	}
	else if (*p == '+') {
		p += 1;
	}

	while (isdigit(*p)) result = (result * 10.0) + (double)(*p++ - '0');

	if (*p == '.') {
		p += 1;
		while (isdigit(*p)) {
			divisor *= 10.0;
			frac += ((double)(*p++ - '0')) / divisor;
		}
	}

	result += frac;

	if (*p == 'E' || *p == 'e') {
		p1 = (char *)p;
		p += 1;
		if (*p == '-') {
			esign = 1;
			p += 1;
		}
		else if (*p == '+') {
			p += 1;
		}
		if (isdigit(*p)) {
			while (isdigit(*p)) exp = (exp * 10) + (*p++ - '0');
		}
		else {
			p = p1;
		}
	}

	if (esign) {
		while (exp-- > 0) result /= 10.0;
	}
	else {
		while (exp-- > 0) result *= 10.0;
	}

	if (pp) *pp = (char *)p;

	return sign ? -result : result;
#else
	struct EXTEND e;

	_str_ext_cvt(p, pp, &e);
	return _ext_dbl_cvt(&e);
#endif
}

#endif
