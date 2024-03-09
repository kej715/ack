/*
 * getc.c - read an unsigned character
 */
/* $Id$ */

#include <stdio.h>

#if ACKCONF_WANT_STDIO

int(getc)(FILE* stream)
{
#if defined(__crayxmp)
	int c;

	if (--stream->_count >= 0)
		c = *stream->_ptr++;
	else
		c = __fillbuf(stream);

	return c;
#define getc(p)         (--(p)->_count >= 0 ? (int) (*(p)->_ptr++) : \
                                __fillbuf(p))

#else
	return getc(stream);
#endif
}

#endif
