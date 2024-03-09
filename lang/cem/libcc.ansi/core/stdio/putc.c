/*
 * putc.c - print (or buffer) one character
 */
/* $Id$ */

#include <stdio.h>

#if ACKCONF_WANT_STDIO

int(putc)(int c, FILE* stream)
{
#if defined(__cos)
	stream->_count -= 1;
	if (stream->_count >= 0)
		*stream->_ptr++ = c;
	else
		c = __flushbuf(c, stream);
	return c;
#else
	return putc(c, stream);
#endif
}

#endif
