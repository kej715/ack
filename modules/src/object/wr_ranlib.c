/* $Header$ */
/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
#include <ranlib.h>
#include "object.h"

wr_ranlib(fd, ran, cnt)
	struct ranlib	*ran;
	register long	cnt;
{
#if BYTE_ORDER == 0x0123
	if (sizeof (struct ranlib) != SZ_RAN)
#endif
	{
		register struct ranlib *r = ran;
		register char *c = (char *) r;

		while (cnt--) {
			put4(r->ran_off,c); c += 4;
			put4(r->ran_pos,c); c += 4;
			r++;
		}
	}
	wr_bytes(fd, (char *) ran, cnt * SZ_RAN);
}
