/*
 * ccomp.c - routines for compiling and linking the C program produced
 *   by the translator.
 */
#include "../h/gsupport.h"
#include "cglobals.h"
#include "ctrans.h"
#include "ctree.h"
#include "ccode.h"
#include "csym.h"
#include "cproto.h"

extern char *refpath;

/*
 * The following code is operating-system dependent [@tccomp.01].  Definition
 *  of ExeFlag and LinkLibs.
 */

#if PORT
   /* something is needed */
Deliberate Syntax Error
#endif						/* PORT */

#if MSDOS
#ifdef NTGCC
#define ExeFlag "-o"
#define LinkLibs " -lm"
#else
#define ExeFlag " "
#define LinkLibs " rt.lib libtp.lib gdbm.lib kernel32.lib winmm.lib WSOCK32.LIB ODBC32.LIB SHELL32.LIB"
#endif
#endif

#if UNIX || AMIGA || ATARI_ST || MACINTOSH || MVS || VM || OS2
#define ExeFlag "-o"
#define LinkLibs " -lm"
#endif						/* UNIX ... */
 
#if VMS
#include file
#define ExeFlag "link/exe="
#define LinkLibs ""
#endif						/* VMS */

/*
 * End of operating-system specific code.
 */

/*
 * Structure to hold the list of Icon run-time libraries that must be
 *  linked in.
 */
struct lib {
   char *libname;
   int nm_sz;
   struct lib *next;
   };
static struct lib *liblst;
static int lib_sz = 0;

/*
 * addlib - add a new library to the list the must be linked.
 */
void addlib(libname)
char *libname;
   {
   static struct lib **nxtlib = &liblst;
   struct lib *l;

   l = NewStruct(lib);

/*
 * The following code is operating-system dependent [@tccomp.02].
 *   Change path syntax if necessary.
 */

#if PORT
   /* something is needed */
Deliberate Syntax Error
#endif						/* PORT */

#if UNIX || AMIGA || ATARI_ST || MACINTOSH || MSDOS || MVS || OS2 || VM
   l->libname = libname;
   l->nm_sz = strlen(libname);
#endif						/* UNIX ... */

#if VMS
   /* change directory string to VMS format */
   {
      struct fileparts *fp;
      char   *newlibname = alloc(strlen(libname) + 20);

      strcpy(newlibname, libname);
      fp = fparse(libname);
      if (strcmp(fp->name, "rt") == 0 && strcmp(fp->ext, ".olb") == 0)
         strcat(newlibname, "/lib/include=data");
      else
	 strcat(newlibname, "/lib");
      l->libname = newlibname;
      l->nm_sz = strlen(newlibname);
      }
#endif						/* VMS */

/*
 * End of operating-system specific code.
 */

   l->next = NULL;
   *nxtlib = l;
   nxtlib = &l->next;
   lib_sz += l->nm_sz + 1;
   }

/*
 * This routine removes the optimizations options from
 * the string of options to be sent to the host compiler
 */
static
char *
rmv_ccomp_opts(opts)
   char * opts;
{
   char * p;
   char * q;
   char * rslt;

#if PORT || AMIGA || ATARI_ST || MACINTOSH || MSDOS || MVS || VM || OS2 || VMS
   /* something may be needed */
   fprintf(stderr, "warning: option \"-nO\" unsupported on this platform.\n");
   return opts;
#endif						/* PORT || AMIGA || ... */

#if UNIX
   /*
    * on unix, -O is the first member of COpts
    */
   rslt = alloc(sizeof(char) * (strlen(opts) + 1));
   for (p=opts+1; p && *p != '-'; p++)
      ;
   q = rslt;
   while (p && *p)
      *q++ = *p++;
   *q = 0;
   return rslt;
#endif
}

/*
 * ccomp - perform C compilation and linking.
 */
int ccomp(srcname, exename)
char *srcname;
char *exename;
   {
   struct lib *l;
   char sbuf[MaxFileName];		/* file name construction buffer */
   char *buf, objname[MaxFileName];
   char *s;
   char *dlrgint;
   int cmd_sz, opt_sz, flg_sz, exe_sz, src_sz;
   extern int opt_hc_opts;

   if (!opt_hc_opts)
      /*
       * The user has requested that all optimization
       * options be removed when invoking the host compiler
       */
      c_opts = rmv_ccomp_opts(c_opts);

   /*
    * Compute the sizes of the various parts of the command line
    *  to do the compilation.
    */
   cmd_sz = strlen(c_comp);
   opt_sz = strlen(c_opts);
   flg_sz = strlen(ExeFlag);
   exe_sz = strlen(exename);
   src_sz = strlen(srcname);
   lib_sz += strlen(LinkLibs);
#if 0
   /*
    * dlrgint disabled for now; linking in rt.a/rlrgint seems to conflict.
    */
   if (!largeints) {
      dlrgint = makename(sbuf, refpath, "dlrgint", ObjSuffix);
      lib_sz += strlen(dlrgint) + 1;
      }
#endif

/*
 * The following code is operating-system dependent [@tccomp.03].
 *  Construct the command line to do the compilation.
 */

#if PORT || AMIGA || ATARI_ST || MACINTOSH || MVS || VM || OS2
   /* something may be needed */
Deliberate Syntax Error
#endif						/* PORT || AMIGA || ... */

#if MSDOS
#if NTGCC

   lib_sz += strlen(" -L") + strlen(refpath);

#ifdef Messaging
   lib_sz += strlen(" -ltp ");
   opt_sz += strlen(" -L") + strlen(refpath) + strlen("../src/libtp");
#endif

#ifdef Dbm
   lib_sz += strlen(" -lgdbm ");
   opt_sz += strlen(" -L") + strlen(refpath) + strlen("../src/gdbm");
#endif

#ifdef Graphics
   lib_sz += strlen(" -lXpm ");
#ifdef Graphics3D
   lib_sz += strlen(" -lGL -lGLU ");
#endif					/* Graphics3D */
   lib_sz += strlen(ICONC_XLIB);
   opt_sz += strlen(" -I") + strlen(refpath) + strlen("../src/xpm");
#endif					/* Graphics */

#ifdef mdw_0
#ifdef ISQL
   lib_sz += strlen(" -liodbc ");
#endif /* ISQL */
#endif /* mdw_0 */

#if HAVE_LIBZ
   lib_sz += strlen(" -lz ");
#endif /* HAVE_LIBZ */

#if HAVE_LIBJPEG
   lib_sz += strlen(" -ljpeg ");
#endif /* HAVE_LIBJPEG */

#if HAVE_LIBPTHREAD
   lib_sz += strlen(" -lpthread ");
#endif                                        /* HAVE_LIBPTHREAD */

#if defined(HAVE_LIBFTGL)
   lib_sz += strlen(" -lstdc++ ");
#endif

#if HAVE_LIBSSL
   lib_sz += strlen(" -lssl -lcrypto ");
#endif                                        /* HAVE_LIBSSL */

   lib_sz += strlen(" -lwinmm");
   lib_sz += strlen(" -lwsock32");
   lib_sz += strlen(" -lodbc32");
   lib_sz += strlen(" -lws2_32 "); 

   buf = alloc((unsigned int)cmd_sz + opt_sz + flg_sz + exe_sz + src_sz +
			     lib_sz + 8);
   strcpy(buf, c_comp);
   s = buf + cmd_sz;
   *s++ = ' ';
   strcpy(s, c_opts);
#ifdef Messaging
   strcat(s, " -L");
   strcat(s, refpath);
   strcat(s, "..\\src\\libtp");
#endif
#ifdef Dbm
   strcat(s, " -L");
   strcat(s, refpath);
   strcat(s, "..\\src\\gdbm");
#endif
#ifdef Graphics
   strcat(s, " -I");
   strcat(s, refpath);
   strcat(s, "..\\src\\xpm");
#endif
   s += opt_sz;
   *s++ = ' ';
   strcpy(s, ExeFlag);
   s += flg_sz;
   *s++ = ' ';
   strcpy(s, exename);
   s += exe_sz;
   *s++ = ' ';
   strcpy(s, srcname);
   s += src_sz;
#if 0
   if (!largeints) {
      *s++ = ' ';
      strcpy(s, dlrgint);
      s += strlen(dlrgint);
      }
#endif
   for (l = liblst; l != NULL; l = l->next) {
      *s++ = ' ';
      strcpy(s, l->libname);
      s += l->nm_sz;
      }

   strcpy(s," -L");
   strcat(s, refpath);

#ifdef Messaging
   strcat(s, " -ltp ");
#endif

#ifdef Dbm
   strcat(s, " -lgdbm ");
#endif

#ifdef Graphics
   strcat(s," -lXpm ");
#ifdef Graphics3D
   strcat(s, " -lGL -lGLU ");
#endif					/* Graphics3D */
   strcat(s, ICONC_XLIB);
#endif						/* Graphics */

#ifdef mdw_0
#ifdef ISQL
   strcat(s, " -liodbc ");
#endif /* ISQL */
#endif /* mdw_0 */

#if HAVE_LIBZ
   strcat(s, " -lz ");
#endif /* HAVE_LIBZ */

#if HAVE_LIBJPEG
   strcat(s, " -ljpeg ");
#endif /* HAVE_LIBJPEG */

#if HAVE_LIBPTHREAD
   strcat(s, " -lpthread ");
#endif                                        /* HAVE_LIBPTHREAD */  

   strcat(s, LinkLibs);
#if defined(HAVE_LIBFTGL)
   strcat(s, " -lstdc++ ");
#endif

#if HAVE_LIBSSL
   strcat(s, " -lssl -lcrypto ");
#endif                                        /* HAVE_LIBSSL */

   strcat(s, " -lwinmm");
   strcat(s, " -lwsock32");
   strcat(s, " -lodbc32");
   strcat(s, " -lws2_32 "); 
#else					/* NTGCC */

   opt_sz += strlen(" /I") + strlen(refpath) + strlen("../src/gdbm");
   opt_sz += strlen(" /I") + strlen(refpath) + strlen("../src/libtp");
   lib_sz += strlen(" -L") + strlen(refpath);

   /*
    * Visual Studio / VC++ / cl.exe
    */
   buf = alloc((unsigned int)cmd_sz + opt_sz + flg_sz + exe_sz + src_sz +
			     lib_sz + 64);
   sprintf(buf, "%s /c %s /I%s..\\src\\gdbm /I%s..\\src\\libtp %s ",
	   c_comp, c_opts, refpath, refpath, srcname);

   /* First, the compile. */
   /*
    * Emit command-line if verbosity is set above 2
    */
   if (verbose > 2)
      fprintf(stdout, "%s\n", buf);

   if (system(buf) != 0)
      return EXIT_FAILURE;

   /* then, the link */
   strcpy(objname, srcname);
   strcat(objname+strlen(objname)-1, "obj"); /* trim c extension */

   sprintf(buf, "link -subsystem:console %s /LIBPATH:%s %s -out:%s.exe",
	   objname, refpath, LinkLibs, exename);
#endif					/* NTGCC*/
#endif					/* MS-DOS*/

#if UNIX

   lib_sz += strlen(" -L") + strlen(refpath);

#ifdef Messaging
   lib_sz += strlen(" -ltp ");
   opt_sz += strlen(" -I") + strlen(refpath) + strlen("../src/libtp");
#endif

#ifdef Dbm
   lib_sz += strlen(" -lgdbm ");
   opt_sz += strlen(" -I") + strlen(refpath) + strlen("../src/gdbm");
#endif

#ifdef Graphics
/* mdw: modified   lib_sz += strlen(" -lXpm "); */
   lib_sz += strlen(" -lXpm -lGL -lGLU");
   lib_sz += strlen(ICONC_XLIB);
   opt_sz += strlen(" -I") + strlen(refpath) + strlen("../src/xpm");
#endif						/* Graphics */

#ifdef mdw_0
#ifdef ISQL
   lib_sz += strlen(" -liodbc ");
#endif /* ISQL */
#endif /* mdw_0 */

#if HAVE_LIBZ
   lib_sz += strlen(" -lz ");
#endif /* HAVE_LIBZ */

#if HAVE_LIBJPEG
   lib_sz += strlen(" -ljpeg ");
#endif /* HAVE_LIBJPEG */

#if HAVE_LIBPTHREAD
   lib_sz += strlen(" -lpthread ");
#endif                                        /* HAVE_LIBPTHREAD */

#if defined(MacOSX) || defined(HAVE_LIBFTGL)
   lib_sz += strlen(" -lstdc++ ");
#endif

#if HAVE_LIBSSL
   lib_sz += strlen(" -lssl -lcrypto ");
#endif                                        /* HAVE_LIBSSL */
   
   buf = alloc((unsigned int)cmd_sz + opt_sz + flg_sz + exe_sz + src_sz +
			     lib_sz + 8);
   strcpy(buf, c_comp);
   s = buf + cmd_sz;
   *s++ = ' ';
   strcpy(s, c_opts);
#ifdef Messaging
   strcat(s, " -I");
   strcat(s, refpath);
   strcat(s, "../src/libtp");
#endif
#ifdef Dbm
   strcat(s, " -I");
   strcat(s, refpath);
   strcat(s, "../src/gdbm");
#endif
#ifdef Graphics
   strcat(s, " -I");
   strcat(s, refpath);
   strcat(s, "../src/xpm");
#endif
   s += opt_sz;
   *s++ = ' ';
   strcpy(s, ExeFlag);
   s += flg_sz;
   *s++ = ' ';
   strcpy(s, exename);
   s += exe_sz;
   *s++ = ' ';
   strcpy(s, srcname);
   s += src_sz;
#if 0
   if (!largeints) {
      *s++ = ' ';
      strcpy(s, dlrgint);
      s += strlen(dlrgint);
      }
#endif
   for (l = liblst; l != NULL; l = l->next) {
      *s++ = ' ';
      strcpy(s, l->libname);
      s += l->nm_sz;
      }

   strcpy(s," -L");
   strcat(s, refpath);

#ifdef Messaging
   strcat(s, " -ltp ");
#endif

#ifdef Dbm
   strcat(s, " -lgdbm ");
#endif

#ifdef Graphics
   strcat(s," -lXpm ");
#ifdef Graphics3D
   strcat(s, "-lGL -lGLU ");
#endif					/* Graphics3D */
   strcat(s, ICONC_XLIB);
#endif						/* Graphics */

#ifdef mdw_0
#ifdef ISQL
   strcat(s, " -liodbc ");
#endif /* ISQL */
#endif /* mdw_0 */

#if HAVE_LIBZ
   strcat(s, " -lz ");
#endif /* HAVE_LIBZ */

#if HAVE_LIBJPEG
   strcat(s, " -ljpeg ");
#endif /* HAVE_LIBJPEG */

#if HAVE_LIBPTHREAD
   strcat(s, " -lpthread ");
#endif                                        /* HAVE_LIBPTHREAD */  

   strcat(s, LinkLibs);
#if defined(MacOSX) || defined(HAVE_LIBFTGL)
   strcat(s, " -lstdc++ ");
#endif

#if HAVE_LIBSSL
   strcat(s, " -lssl -lcrypto ");
#endif                                        /* HAVE_LIBSSL */

#endif						/* UNIX */

   /*
    * Emit command-line if verbosity is set above 2
    */
   if (verbose > 2)
      fprintf(stdout, "%s\n", buf);

   /* Execute the (compile+)link */
   if (system(buf) != 0)
      return EXIT_FAILURE;

#if UNIX || NTGCC
   /* Strip debug symbols from target unless they were requested. */
   if (!strstr(buf, " -g ") && !dbgsyms) {
      strcpy(buf, "strip ");
      s = buf + 6;
      strcpy(s, exename);
      system(buf);
      }
#endif						/* UNIX */

#if VMS

#ifdef Graphics
#ifdef HAVE_LIBXPM
   lib_sz += strlen(refpath) + strlen("Xpm/lib,");
#endif						/* HAVE_LIBXPM */
   lib_sz += 1 + strlen(refpath) + strlen("X11.opt/opt");
#endif						/* Graphics */

   buf = alloc((unsigned int)cmd_sz + opt_sz + flg_sz + exe_sz + src_sz +
			     lib_sz + 5);
   strcpy(buf, c_comp);
   s = buf + cmd_sz;
   strcpy(s, c_opts);
   s += opt_sz;
   *s++ = ' ';
   strcpy(s, srcname);

   if (system(buf) == 0)
      return EXIT_FAILURE;
   strcpy(buf, ExeFlag);
   s = buf + flg_sz;
   strcpy(s, exename);
   s += exe_sz;
   *s++ = ' ';
   strcpy(s, srcname);
   s += src_sz - 1;
   strcpy(s, "obj");
   s += 3;
#if 0
   if (!largeints) {
      *s++ = ',';
      strcpy(s, dlrgint);
      s += strlen(dlrgint);
      }
#endif
   for (l = liblst; l != NULL; l = l->next) {
      *s++ = ',';
      strcpy(s, l->libname);
      s += l->nm_sz;
      }
#ifdef Graphics
   strcat(s, ",");
#ifdef HAVE_LIBXPM
   strcat(s, refpath);
   strcat(s, "Xpm/lib,");
#endif						/* HAVE_LIBXPM */
   strcat(s, refpath);
   strcat(s, "X11.opt/opt");
#endif						/* Graphics */

   if (system(buf) == 0)
      return EXIT_FAILURE;
#endif						/* VMS */

/*
 * End of operating-system specific code.
 */

   return EXIT_SUCCESS;
   }