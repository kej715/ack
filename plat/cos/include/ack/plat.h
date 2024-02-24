#ifndef _ACK_PLAT_H
#define _ACK_PLAT_H

#define ACKCONF_WANT_FLOAT            1
#define ACKCONF_WANT_STDIO_FLOAT      1
#define ACKCONF_WANT_STANDARD_O       1
#define ACKCONF_WANT_O_TEXT_O_BINARY  1
#define ACKCONF_WANT_STANDARD_SIGNALS 1
#define CRAYFLOAT                     1

#define ACKCONF_WANT_EMULATED_FILE    1

/* We're providing a time() system call rather than wanting a wrapper around
 * gettimeofday() in the libc. */
 
#define ACKCONF_WANT_EMULATED_TIME    0

/* No support for popen on COS */

#define ACKCONF_WANT_EMULATED_POPEN   0

#endif
