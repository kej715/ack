#include <math.h>
#include <ack/config.h>

#if ACKCONF_WANT_FLOAT

__IsNan(double d)
{
#if defined(__vax) || defined(__pdp)
#elif defined(__crayxmp)
	if (((*((long*)&d) >> 48) & 0x7fff) >= 060000)
		return 1;
#else
	float f = d;

	if ((*((long*)&f) & 0x7f800000) == 0x7f800000 && (*((long*)&f) & 0x007fffff) != 0)
		return 1;
#endif
	return 0;
}

#endif

