#include "../h/gsupport.h"

/*
 * millisec - returns execution time in milliseconds. Time is measured
 *  from the function's first call, so the function is called at the end
 *  of initialization to time the program run. The granularity of the time
 *  may be more than one millisecond and historically on some systems it
 *  was only accurate to the second.
 */

#if UNIX

/*
 * ANSI C does not support millisecond accuracy, but the ANSI C clock()
 * function was the historical basis for Icon millisec(). On 32-bit platforms,
 * clock() can overflow a signed clock_t value in about 35 minutes.  So,
 * when available (i.e. UNIX) millisec() was upgraded to use the POSIX
 * standard times() function instead.  Under Linux at least, that
 * function tends to only deliver 10ms precision, so use getrtime() or
 * clock_gettime() if it is available.  To complicate matters, clock_gettime()
 * seems to report user time only, not system time(?).
 *
 * TODO:
 *    test Windows code given below.
 *    investigate mach_absolute_time() on OS X.
 *    do performance checks on timer functions to see if that is an issue.
 */

/*
 * Return elapsed CPU time.  This is CPU user time + system time.
 */
long millisec()
   {
   long usertime = 0;
   static long starttime = -2, clk_tck;
   long t;

#ifdef HAVE_GETRUSAGE
   struct rusage ruse;
   int i = getrusage(RUSAGE_SELF, &ruse);
   if (i == -1) return 0;
   return (ruse.ru_utime.tv_sec + ruse.ru_stime.tv_sec)*1000 +
          (ruse.ru_utime.tv_usec + ruse.ru_stime.tv_usec)/1000;
#else					/* HAVE_GETRUSAGE */

#ifdef HAVE_CLOCK_GETTIME
    { struct timespec ts;
      static long system_millisec;
     clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts);
     if (startime == -2)
	system_millisec = ts.tv_sec * 1000 + ts.tv_nsec/1000000;
     usertime = ts.tv_sec * 1000 + ts.tv_nsec/1000000 - system_millisec;
     }
#endif					/* HAVE_CLOCK_GETTIME */

/*
 * t's units here are (system-defined) clock ticks. If we have clock_gettime()
 * for user time, report system ticks, otherwise report user+system ticks.
 */
   {
   struct tms tp;
   times(&tp);
#ifdef HAVE_CLOCK_GETTIME
   t = (long) (tp.tms_stime);
#else					/* HAVE_CLOCK_GETTIME */
   t = (long) (tp.tms_utime + tp.tms_stime);
#endif					/* HAVE_CLOCK_GETTIME */
   }

   if (starttime == -2) {
      starttime = t;
#ifdef CLK_TCK
      clk_tck = CLK_TCK;
#else					/* CLK_TCK */
      clk_tck = sysconf(_SC_CLK_TCK);
#endif
      }

#ifdef HAVE_CLOCK_GETTIME
   return usertime + (long) ((1000.0 / clk_tck) * (t - starttime));
#else					/* HAVE_CLOCK_GETTIME */
   return (long) ((1000.0 / clk_tck) * (t - starttime));
#endif					/* HAVE_CLOCK_GETTIME */
#endif					/* HAVE_GETRUSAGE */
   }
#endif					/* UNIX */

#if 0 /* NT */
/*
 * The following Windows code is presumed to be public domain and is not
 * covered by Unicon's GPL - it came from Carl Staelin's post at
 * http://stackoverflow.com/questions/5404277/porting-clock-gettime-to-windows
 * It is as-yet untested.
 */

LARGE_INTEGER
getFILETIMEoffset()
{
    SYSTEMTIME s;
    FILETIME f;
    LARGE_INTEGER t;

    s.wYear = 1970;
    s.wMonth = 1;
    s.wDay = 1;
    s.wHour = 0;
    s.wMinute = 0;
    s.wSecond = 0;
    s.wMilliseconds = 0;
    SystemTimeToFileTime(&s, &f);
    t.QuadPart = f.dwHighDateTime;
    t.QuadPart <<= 32;
    t.QuadPart |= f.dwLowDateTime;
    return (t);
}

int
clock_gettime(int X, struct timeval *tv)
{
    LARGE_INTEGER           t;
    FILETIME            f;
    double                  microseconds;
    static LARGE_INTEGER    offset;
    static double           frequencyToMicroseconds;
    static int              initialized = 0;
    static BOOL             usePerformanceCounter = 0;

    if (!initialized) {
        LARGE_INTEGER performanceFrequency;
        initialized = 1;
        usePerformanceCounter = QueryPerformanceFrequency(&performanceFrequency);
        if (usePerformanceCounter) {
            QueryPerformanceCounter(&offset);
            frequencyToMicroseconds = (double)performanceFrequency.QuadPart / 1000000.;
        } else {
            offset = getFILETIMEoffset();
            frequencyToMicroseconds = 10.;
        }
    }
    if (usePerformanceCounter) QueryPerformanceCounter(&t);
    else {
        GetSystemTimeAsFileTime(&f);
        t.QuadPart = f.dwHighDateTime;
        t.QuadPart <<= 32;
        t.QuadPart |= f.dwLowDateTime;
    }

    t.QuadPart -= offset.QuadPart;
    microseconds = (double)t.QuadPart / frequencyToMicroseconds;
    t.QuadPart = microseconds;
    tv->tv_sec = t.QuadPart / 1000000;
    tv->tv_usec = t.QuadPart % 1000000;
    return (0);
}
#endif

#if !UNIX /* && !NT */

/*
 * On anything other than UNIX, just use the ANSI C clock() function.
 */

long millisec()
   {
   static clock_t starttime = -2;
   clock_t t;

   t = clock();
   if (starttime == -2)
      starttime = t;
   return (long) ((1000.0 / CLOCKS_PER_SEC) * (t - starttime));
   }

#endif					/* UNIX */
