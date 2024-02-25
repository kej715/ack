#ifndef SYSLOG_H
#define SYSLOG_H

#define SYSLOG_USER   1
#define SYSLOG_SYSTEM 2

extern void syslog(char *message, int dest, int class, int override);

#endif
