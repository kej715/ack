/* $Id$ */

#include <math.h>
#include <ack/config.h>

#if ACKCONF_WANT_STDIO_FLOAT

#if defined(__crayxmp)
#include <stdlib.h>
#include <string.h>

static char *dtostr(double value, int ndigit, int *decpt, int *sign, int ecvtflag);
static void initTables(void);
#else
#include "ext_fmt.h"
#endif

static char*
cvt(long double value, int ndigit, int* decpt, int* sign, int ecvtflag)
{
#if defined(__crayxmp)
	return dtostr(value, ndigit, decpt, sign, ecvtflag);
#else
	struct EXTEND e;

	_dbl_ext_cvt(value, &e);
	return _ext_str_cvt(&e, ndigit, decpt, sign, ecvtflag);
#endif
}

char* _ecvt(long double value, int ndigit, int* decpt, int* sign)
{
	return cvt(value, ndigit, decpt, sign, 1);
}

char* _fcvt(long double value, int ndigit, int* decpt, int* sign)
{
	return cvt(value, ndigit, decpt, sign, 0);
}

#if defined(__crayxmp)

static double E0toE99      [100];
static double E_0toE_99    [100];
static double E00toE2400   [25];
static double E_00toE_2400 [25];

#define MAX_DIGITS 20

static char digits[MAX_DIGITS+1];

static char *dtostr(double value, int ndigit, int *decpt, int *sign, int ecvtflag) {
	union {
		double d;
		unsigned long u;
	} cvt;
	char *dp;
	short exp;
	int fracLen;
	int i;
	int len;
	char *limit;

	initTables();
	*decpt = 0;
	*sign = 0;

	if (ndigit > MAX_DIGITS) ndigit = MAX_DIGITS;

	if (value == 0.0) {
		memset(digits, '0', ndigit);
		digits[ndigit] = '\0';
		return digits;
	}
	if (value < 0.0) {
		*sign = 1;
		value = -value;
	}
	/*
	 *  Transform the value such that it is in the range [1.0 - 10.0), and adjust
	 *  the decimal point indication accordingly.
	 */
	if (value >= 1.0) {
		/*
		 *  First, account for a value that is possibly very large. Find the
		 *  range in which the value sits by factors of 10**(i * 100) and divide
		 *  by the lower bound of the range.
		 */
		i = 0;
		while (i < 25 && value >= E00toE2400[i]) i += 1;
		i -= 1;
		value /= E00toE2400[i];
		*decpt = i * 100;
		/*
		 *  Next, find where the adjusted value sits within the range, by factors
		 *  of 10**i, and divide by the lower bound of the range.
		 */
		i = 0;
		while (i < 100 && value >= E0toE99[i]) i += 1;
		i -= 1;
		value /= E0toE99[i];
		*decpt += i + 1;
	}
	else {
		/*
		 *  First, account for a value that is possibly very small. Find the
		 *  range in which the value sits by factors of 10**(-i * 100) and multiply
		 *  by a factor corresponding to the upper bound of the range.
		 */
		i = 1;
		while (i < 25 && value < E_00toE_2400[i]) i += 1;
		i -= 1;
		value *= E00toE2400[i];
		*decpt = -i * 100;
		/*
		 *  Next, find where the adjusted value sits within the range, by factors
		 *  of 10**-i, and multiply by a factor corresponding to the upper bound of
		 *  the range.
		 */
		i = 1;
		while (i < 100 && value < E_0toE_99[i]) i += 1;
		i -= 1;
		value *= E0toE99[i];
		*decpt -= i;
	}
	/*
	 *  Round the resulting value by adding low-order "noise" bits
	 */
	cvt.d = value;
	exp = (cvt.u >> 48) & 0x7fff;
	cvt.u = (((exp - 45) & 0x7fff) << 48) | (7 << 45);
	value += cvt.d;
	if (value >= 10.0) {
		value /= 10.0;
		*decpt += 1;
	}
	/*
	 *  Value should now be in range [1.0 - 10.0), so begin iteratively generating
	 *  digits.
	 */
	dp = digits;
	limit = digits + MAX_DIGITS;
	while (value > 0.0 && dp < limit) {
		i = value;
		if (i > 0 || dp > digits) {
			*dp++ = i + '0';
		}
		value = (value - (double)i) * 10.0;
	}

	if (ecvtflag) {
		len = dp - digits;
		while (len < ndigit && dp < limit) {
			*dp++ = '0';
			len += 1;
		}
	}
	else {
		fracLen = (dp - digits) - *decpt;
		while (fracLen < ndigit && dp < limit) {
			*dp++ = '0';
			fracLen += 1;
		}
	}
	*dp = '\0';

	return digits;
}

static void initTables(void) {
	int i;
	char nstr[8];

	if (E0toE99[0] == 0) {
		strcpy(nstr, "1E+00");
		for (i = 0; i < 100; i++) {
			nstr[3] = (i / 10) + '0';
			nstr[4] = (i % 10) + '0';
			E0toE99[i] = strtod(nstr, NULL);
		}
		nstr[2] = '-';
		for (i = 0; i < 100; i++) {
			nstr[3] = (i / 10) + '0';
			nstr[4] = (i % 10) + '0';
			E_0toE_99[i] = strtod(nstr, NULL);
		}
		strcpy(nstr, "1E+0000");
		for (i = 0; i < 25; i++) {
			nstr[3] = (i / 10) + '0';
			nstr[4] = (i % 10) + '0';
			E00toE2400[i] = strtod(nstr, NULL);
		}
		nstr[2] = '-';
		for (i = 0; i < 25; i++) {
			nstr[3] = (i / 10) + '0';
			nstr[4] = (i % 10) + '0';
			E_00toE_2400[i] = strtod(nstr, NULL);
		}
	}
}

#endif

#endif
