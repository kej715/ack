/*
 * isatty - check if a file descriptor is associated with a terminal
 */
/* $Id$ */

#if ACKCONF_WANT_TERMIOS

#include <stdlib.h>
#include <termios.h>
int isatty(int fd)
{
  struct termios dummy;

  return(tcgetattr(fd, &dummy) == 0);
}

#endif
