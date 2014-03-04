/*
 * Unicon configuration file for x86_64-bit Mac OSX.
 */

#define UNIX 1
#define COpts "-I/usr/X11R6/include"
#define NEED_UTIME

/* CPU architecture */
#define IntBits 32
#define WordBits 64
#define Double
#define StackAlign 16
/* a non-default datatype for SQLBindCol's 6th parameter */
#define SQL_LENORIND SQLLEN
#define NoLIBZ

#define NamedSemaphores
#define MacOSX
#define INTMAIN
#define PROFIL_CHAR_P
/* LoadFunc not implemented */
#define LoadFunc
