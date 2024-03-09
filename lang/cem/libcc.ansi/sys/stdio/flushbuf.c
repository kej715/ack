/*
 * flushbuf.c - flush a buffer
 */
/* $Id$ */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#if ACKCONF_WANT_STDIO && ACKCONF_WANT_EMULATED_FILE

static int
do_write(int d, char* buf, int nbytes)
{
	int n;

	/* POSIX actually allows write() to return a positive value less
	   than nbytes, so loop ...
	*/
	while (nbytes > 0)
	{
		n = write(d, buf, nbytes);
		if (n < 0) return 0;
		nbytes -= n;
		buf += n;
	}
	return 1;
}

int __flushbuf(int c, FILE* stream)
{
	__register_stdio_cleanup();
	if (fileno(stream) < 0)
		return EOF;
	if (!io_testflag(stream, _IOWRITE))
		return EOF;
	if (io_testflag(stream, _IOREADING) && !feof(stream))
		return EOF;

	stream->_flags &= ~_IOREADING;
	stream->_flags |= _IOWRITING;
	if (!io_testflag(stream, _IONBF))
	{
		if (!stream->_buf)
		{
			if (stream == stdout && isatty(fileno(stdout)))
			{
				if (!(stream->_buf = (unsigned char*)malloc(BUFSIZ)))
				{
					stream->_flags |= _IONBF;
				}
				else
				{
					stream->_flags |= _IOLBF | _IOMYBUF;
					stream->_bufsiz = BUFSIZ;
					stream->_count = -1;
				}
			}
			else
			{
				if (!(stream->_buf = (unsigned char*)malloc(BUFSIZ)))
				{
					stream->_flags |= _IONBF;
				}
				else
				{
					stream->_flags |= _IOMYBUF;
					stream->_bufsiz = BUFSIZ;
					if (!io_testflag(stream, _IOLBF))
						stream->_count = BUFSIZ - 1;
					else
						stream->_count = -1;
				}
			}
			stream->_ptr = stream->_buf;
		}
	}

	if (io_testflag(stream, _IONBF))
	{
		char c1 = c;

		stream->_count = 0;
		if (io_testflag(stream, _IOAPPEND))
		{
			if (lseek(fileno(stream), 0L, SEEK_END) == -1)
			{
				stream->_flags |= _IOERR;
				return EOF;
			}
		}
		if (write(fileno(stream), &c1, 1) != 1)
		{
			stream->_flags |= _IOERR;
			return EOF;
		}
		return (unsigned char)c;
	}
	else if (io_testflag(stream, _IOLBF))
	{
		*stream->_ptr++ = c;
		/* stream->_count has been updated in putc macro. */
		if (c == '\n' || stream->_count == -stream->_bufsiz)
		{
			int count = -stream->_count;

			stream->_ptr = stream->_buf;
			stream->_count = 0;

			if (io_testflag(stream, _IOAPPEND))
			{
				if (lseek(fileno(stream), 0L, SEEK_END) == -1)
				{
					stream->_flags |= _IOERR;
					return EOF;
				}
			}
			if (!do_write(fileno(stream), (char*)stream->_buf,
			        count))
			{
				stream->_flags |= _IOERR;
				return EOF;
			}
		}
	}
	else
	{
		int count = stream->_ptr - stream->_buf;

		stream->_count = stream->_bufsiz - 1;
		stream->_ptr = stream->_buf + 1;

		if (count > 0)
		{
			if (io_testflag(stream, _IOAPPEND))
			{
				if (lseek(fileno(stream), 0L, SEEK_END) == -1)
				{
					stream->_flags |= _IOERR;
					return EOF;
				}
			}
			if (!do_write(fileno(stream), (char*)stream->_buf, count))
			{
				*(stream->_buf) = c;
				stream->_flags |= _IOERR;
				return EOF;
			}
		}
		*(stream->_buf) = c;
	}
	return (unsigned char)c;
}

#endif
