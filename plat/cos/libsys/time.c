#include <stdlib.h>
#include <time.h>
#include <unistd.h>

extern void _cosdat(char *date);
extern void _costim(char *time);

#define SECS_PER_MIN  60
#define SECS_PER_HOUR 60*SECS_PER_MIN
#define SECS_PER_DAY  24*SECS_PER_HOUR
#define SECS_PER_YEAR 365*SECS_PER_DAY

static int  lastDay  = 0;
static int  lastMon  = 0;
static long lastSecs = 0;
static int  lastYear = 0;

static int  secsPerMon[] = {
    31 * SECS_PER_DAY,
    28 * SECS_PER_DAY,
    31 * SECS_PER_DAY,
    30 * SECS_PER_DAY,
    31 * SECS_PER_DAY,
    30 * SECS_PER_DAY,
    31 * SECS_PER_DAY,
    31 * SECS_PER_DAY,
    30 * SECS_PER_DAY,
    31 * SECS_PER_DAY,
    30 * SECS_PER_DAY,
    31 * SECS_PER_DAY
};

static int a2i(char *s) {
    return (*s - '0') * 10 + (*(s + 1) - '0');
}

time_t time(time_t* t) {
    long curSecs;
    time_t curTime;
    char dateStr[16];
    int i;
    int isLeapYear;
    int leapYears;
    int *spm;
    char timeStr[16];
    int day, hour, min, mon, sec, year;

    _cosdat(dateStr);
    _costim(timeStr);
    mon  = a2i(dateStr);
    day  = a2i(dateStr + 3);
    year = a2i(dateStr + 6);
    hour = a2i(timeStr);
    min  = a2i(timeStr + 3);
    sec  = a2i(timeStr + 6);

    curSecs = (hour * 3600) + (min * 60) + sec;
    if (lastSecs == 0
        || day   != lastDay
        || mon   != lastMon
        || year  != lastYear) {
        lastDay  = day;
        lastMon  = mon;
        lastYear = year;
        year = (year >= 70) ? year - 70 : year + 30;
        curTime = year * SECS_PER_YEAR;
        year += 2;
        leapYears = (year / 4) - 1;
        isLeapYear = (year % 4) == 0;
        curTime += leapYears * SECS_PER_DAY;
        mon -= 1;
        for (i = 0, spm = secsPerMon; i < mon; i++)
            curTime += *spm++;
        if (isLeapYear && mon >= 2) curTime += SECS_PER_DAY;
        curTime += ((day - 1) * SECS_PER_DAY) + (hour * SECS_PER_HOUR) + (min * SECS_PER_MIN) + sec;
    }
    else {
        curTime += curSecs - lastSecs;
    }
    lastSecs = curSecs;

    if (t) *t = curTime;

    return curTime;
}
