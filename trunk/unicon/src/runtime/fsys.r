/*
 * File: fsys.r
 *  Contents: close, chdir, exit, getenv, open, read, reads, remove, rename,
 *  [save], seek, stop, system, where, write, writes, [getch, getche, kbhit]
 */

#if MICROSOFT
#define BadCode
#endif					/* MICROSOFT */

#ifdef XENIX_386
#define register
#endif					/* XENIX_386 */
/*
 * The following code is operating-system dependent [@fsys.01]. Include
 *  system-dependent files and declarations.
 */

#if PORT
   /* nothing to do */
Deliberate Syntax Error
#endif					/* PORT */

#if AMIGA
extern FILE *popen(const char *, const char *);
extern int pclose(FILE *);
#endif AMIGA                            /* AMIGA */

#if MSDOS || MVS || OS2 || UNIX || VM || VMS
   /* nothing to do */
#endif					/* MSDOS ... */

#if MACINTOSH && MPW
extern int MPWFlush(FILE *f);
#define fflush(f) MPWFlush(f)
#endif					/* MACINTOSH && MPW*/

#ifdef PosixFns
extern int errno;
#endif					/* PosixFns */
/*
 * End of operating-system specific code.
 */


/*
 * Change the mixed case of string s1 to the lower case string s2 by
 * copying s2 (without the NUL terminator; can be at front or in the middle).
 */
void UtoL (char *s1, char *s2)
{
   int i, l = strlen(s2);

   for (i = 0; i < l; i++)
      *(s1+i) = *(s2+i);
}

/*
 * is_url() takes a string s as its parameter. If s starts with a URL scheme,
 * is_url() returns 1. If s starts with "net:", it returns 2. Otherwise,
 * for normal files, is_url() returns 0.
*/

int is_url(char *s)
{
   char *tmp = s;

   while ( *tmp == ' ' || *tmp == '\t' || *tmp == '\n' )
      tmp++;

   if (!strncasecmp (tmp, "http:", 5) ){
      UtoL(tmp, "http");
      return 1;
      }
   if (!strncasecmp (tmp, "file:", 5) ) {
      UtoL(tmp, "file");
      return 1;
      }
   if (!strncasecmp (tmp, "ftp:", 4) ) {
      UtoL(tmp, "ftp");
      return 1;
      }
   if (!strncasecmp (tmp, "gopher:", 7) ) {
      UtoL(tmp, "gopher");
      return 1;
      }
   if (!strncasecmp (tmp, "telnet:", 7) )  {
      UtoL(tmp, "telnet");
      return 1;
      }
   if ( !strncasecmp(tmp, "net:", 4) )
      return 2;
   return 0;
}

"close(f) - close file f."

function{1} close(f)

   if !is:file(f) then
      runerr(105, f)

   abstract {
      return file ++ integer
      }

   body {
#ifdef HAVE_VOICE
      PVSESSION Ptr;
#endif					/* HAVE_VOICE */
      FILE *fp = BlkD(f,File)->fd.fp;
      int status = BlkD(f,File)->status;
      CURTSTATE();

      if ((status & (Fs_Read|Fs_Write)) == 0) return f;

      /*
       * Close f, using fclose, pclose, closedir, or wclose as appropriate.
       */
#ifdef Messaging
      if (status & Fs_Messaging) {
	 BlkLoc(f)->File.status = 0;
	 return C_integer Mclose(BlkD(f,File)->fd.mf);
	 }
#endif                                  /* Messaging */

#ifdef PosixFns
      if (BlkD(f,File)->status & Fs_Socket) {
	 BlkLoc(f)->File.status = 0;
#if NT
	 return C_integer closesocket((SOCKET)BlkLoc(f)->File.fd.fd);
#else					/* NT */
	 return C_integer close(BlkLoc(f)->File.fd.fd);
#endif					/* NT */
	 }
#endif					/* PosixFns */

#ifdef ReadDirectory
#if !NT || defined(NTGCC)
      if (BlkD(f,File)->status & Fs_Directory) {
	 BlkLoc(f)->File.status = 0;
	 closedir((DIR *)fp);
	 return f;
         }
#endif
#endif					/* ReadDirectory */

#if HAVE_LIBZ
      if (BlkD(f,File)->status & Fs_Compress) {
	 BlkLoc(f)->File.status = 0;
	 if (gzclose((gzFile) fp)) fail;
	 return C_integer 0;
	 }
#endif					/* HAVE_LIBZ */

#ifdef ISQL
      if (BlkD(f,File)->status & Fs_ODBC) {
	 BlkLoc(f)->File.status = 0;
	 if (dbclose((struct ISQLFile *)fp)) fail;
	 return C_integer 0;
	 }
#endif					/* ISQL */

#ifdef PseudoPty
      if (BlkD(f,File)->status & Fs_Pty) {
	 ptclose(BlkLoc(f)->File.fd.pt);
	 return C_integer 0;
	 }
#endif					/* PseudoPty */

#ifdef Dbm
      if (BlkD(f,File)->status & Fs_Dbm) {
	 BlkLoc(f)->File.status = 0;
	 dbm_close((DBM *)fp);
	 return f;
         }
#endif					/* Dbm */


#ifdef Graphics
      /*
       * Close window if windows are supported.
       */

      pollctr >>= 1;
      pollctr++;
      if (BlkD(f,File)->status & Fs_Window) {
	 if (BlkLoc(f)->File.status != Fs_Window) { /* not already closed? */
	    BlkLoc(f)->File.status = Fs_Window;
	    SETCLOSED((wbp) fp);
	    wclose((wbp) fp);
	    }
	 return f;
	 }
      else
#endif					/* Graphics */
#ifdef HAVE_VOICE
	if(BlkD(f,File)->status & Fs_Voice) {
	/* PVSESSION Ptr; */
	Ptr = (PVSESSION)BlkLoc(f)->File.fd.fp;
	CloseVoiceSession(Ptr);
	return C_integer 1;
	}
	else
#endif					/* HAVE_VOICE */

#if NT
#ifndef NTGCC
#define pclose _pclose
#define popen _popen
#endif					/* NTGCC */
#endif					/* NT */

#if AMIGA || ARM || OS2 || UNIX || VMS || NT
      /*
       * Close pipe if pipes are supported.
       */

      if (BlkD(f,File)->status & Fs_Pipe) {
	 BlkLoc(f)->File.status = 0;
	 return C_integer((pclose(fp) >> 8) & 0377);
	 }
      else
#endif					/* AMIGA || ARM || OS2 || ... */

      fclose(fp);
      BlkLoc(f)->File.status = 0;

      /*
       * Return the closed file.
       */
      return f;
      }
end

#undef exit
#passthru #undef exit

"exit(i) - exit process with status i, which defaults to 0."

function{} exit(status)
   if !def:C_integer(status, EXIT_SUCCESS) then
      runerr(101, status)
   inline {

#ifdef Concurrent
   /*
    * exit if this is a thread.
    * May want to check/fix thread  activator initialization 
    * depending on desired join semantics.
    * coclean calls pthread_exit() in case of Async threads.
    */
   if ( status==10101 ){
     CURTSTATE();
     #ifdef CoClean
     coclean(BlkD(k_current, Coexpr)->cstate);
     #endif				/* CoClean */
      }
#endif					/* Concurrent */
      c_exit((int)status);
#if !COMPILER
      fail;				/* avoid spurious warning message */
#endif					/* COMPILER */
      }
end


"getenv(s) - return contents of environment variable s."

function{0,1} getenv(s)

   /*
    * Make a C-style string out of s
    */
   if !cnv:C_string(s) then
      runerr(103,s)
   abstract {
      return string
      }

   inline {
      char *p, sbuf[4096];
      long l;

      if (getenv_r(s,sbuf,4095) == 0) {
	 l = strlen(sbuf);
	 Protect(p = alcstr(sbuf,l),runerr(0));
	 return string(l,p);
	 }
      else 				/* fail if not in environment */
	 fail;
      }
end


#if defined(Graphics) || defined(Messaging) || defined(ISQL)
"open(s1, s2, ...) - open file named s1 with options s2"
" and attributes given in trailing arguments."
function{0,1} open(fname, spec, attr[n])
#else						/* Graphics */
#ifdef OpenAttributes
"open(fname, spec, attrstring) - open file fname with specification spec."
function{0,1} open(fname, spec, attrstring)
#else						/* OpenAttributes */
"open(fname, spec) - open file fname with specification spec."
function{0,1} open(fname, spec)
#endif						/* OpenAttributes */
#endif						/* Graphics */
   declare {
      tended struct descrip filename;
      }

   /*
    * fopen and popen require a C string, but it looks terrible in
    *  error messages, so convert it to a string here and use a local
    *  variable (fnamestr) to store the C string.
    */
   if !cnv:string(fname) then
      runerr(103, fname)

   /*
    * spec defaults to "r".
    */
   if !def:tmp_string(spec, letr) then
      runerr(103, spec)

#ifdef OpenAttributes
   /*
    * Convert attrstr to a string, defaulting to "".
    */
   if !def:C_string(attrstring, emptystr) then
      runerr(103, attrstring)
#endif					/* OpenAttributes */

   abstract {
      return file
      }

   body {
      tended char *fnamestr;
      register word slen;
      register int i;
      register char *s;
      int status;
      char mode[4];
      extern FILE *fopen();
      FILE *f;
      SOCKET fd;
      struct b_file *fl;
#ifdef PosixFns
      struct stat st;
#endif					/* PosixFns */

#ifdef Graphics
      int j, err_index = -1;
      tended struct b_list *hp;
#endif					/* Graphics */

#ifdef Messaging
      int is_shortreq = 0;
      C_integer timeout = 0;
#endif                                  /* Messaging */

/*
 * The following code is operating-system dependent [@fsys.02].  Make
 *  declarations as needed for opening files.
 */

#if PORT
Deliberate Syntax Error
#endif					/* PORT */

#if AMIGA || MACINTOSH || MSDOS || MVS || OS2 || VM
   /* nothing is needed */
#endif					/* AMIGA || ... */

#if ARM
      extern FILE *popen(const char *, const char *);
      extern int pclose(FILE *);
#endif					/* ARM */

#ifdef PosixFns
      int is_udp_or_listener = 0;	/* UDP = 1, listener = 2 */
#endif					/* PosixFns */

#if OS2 || UNIX || VMS || NT
      extern FILE *popen();
#endif					/* OS2 || UNIX || VMS || NT */

/*
 * End of operating-system specific code.
 */
      /*
       * get a C string for the file name
       */
      if (!cnv:C_string(fname, fnamestr))
	 runerr(103,fname);

      if (strlen(fnamestr) != StrLen(fname)) {
	 fail;
	 }

      status = 0;

      /*
       * Scan spec, setting appropriate bits in status.  Produce a
       *  run-time error if an unknown character is encountered.
       */
      s = StrLoc(spec);
      slen = StrLen(spec);

      for (i = 0; i < slen; i++) {
	 switch (*s++) {
	    case 'a':
	    case 'A':
	       status |= Fs_Write|Fs_Append;
	       continue;
	    case 'b':
	    case 'B':
	       status |= Fs_Read|Fs_Write;
	       continue;
	    case 'c':
	    case 'C':
	       status |= Fs_Create|Fs_Write;
	       continue;
	    case 'r':
	    case 'R':
	       status |= Fs_Read;
	       continue;
	    case 'w':
	    case 'W':
	       status |= Fs_Write;
	       continue;

	    case 's':
	    case 'S':
#ifdef Messaging
	       if (status & Fs_Messaging) {
		  is_shortreq = 1;
		  continue;
		  }
#endif                                  /* Messaging */
#ifdef RecordIO
	       status |= Fs_Untrans;
	       status |= Fs_Record;
#endif					/* RecordIO */
	       continue;

	    case 't':
	    case 'T':
	       status &= ~Fs_Untrans;
#ifdef RecordIO
               status &= ~Fs_Record;
#endif                                  /* RecordIO */
	       continue;

	    case 'u':
	    case 'U':
#ifdef PosixFns
	       is_udp_or_listener = 1;
#endif					/* PosixFns */
	       if ((status & Fs_Socket)==0)
		  status |= Fs_Untrans;
#ifdef RecordIO
	       status &= ~Fs_Record;
#endif					/* RecordIO */
	       continue;

#if AMIGA || ARM || OS2 || UNIX || VMS || NT
	    case 'p':
	    case 'P':
	       status |= Fs_Pipe;
	       continue;
#endif					/* AMIGA || ARM || OS2 || UNIX ... */

	    case 'x':
	    case 'X':
	    case 'g':
	    case 'G':
#ifdef Graphics
	       status |= Fs_Window | Fs_Read | Fs_Write;
#ifdef XWindows
	       XInitThreads();
#endif					/* XWindows */
	       continue;
#else					/* Graphics */
	       fail;
#endif					/* Graphics */

	    case 'l':
	    case 'L':
#ifdef PosixFns
	       if (status & Fs_Socket) {
		  status |= Fs_Listen | Fs_Append;
		  is_udp_or_listener = 2;
		  continue;
		  }
#endif					/* PosixFns */
#ifdef Graphics3D
	       if (status & Fs_Window) {
		  status |= Fs_Window3D;
		  continue;
		  }
#else					/* Graphics3D */
	       fail;
#endif					/* Graphics3D */


	    case 'd':
	    case 'D':
#ifdef Dbm
	       status |= Fs_Dbm;
	       continue;
#else
	       fail;
#endif	   				/* DBM */

	    case 'm':
	    case 'M':
#ifdef Messaging
	       status |= Fs_Messaging|Fs_Read|Fs_Write;
	       continue;
#else
	       fail;
#endif                                  /* Messaging */

	    case 'n':
	    case 'N':
#ifdef PosixFns
	       status |= Fs_Socket|Fs_Read|Fs_Write|Fs_Unbuf;
	       continue;

#else 					/* PosixFns */
	       fail;
#endif 					/* PosixFns */


	    case 'o':
	    case 'O':
#ifdef ISQL
	       status |= Fs_ODBC;
	       continue;

#else 					/* ISQL */
	       fail;
#endif 					/* ISQL */

	    case 'v':
	    case 'V':
#ifdef HAVE_VOICE
	       status |= Fs_Voice;
	       continue;

#else 					/* HAVE_VOICE */
	       fail;
#endif 					/* HAVE_VOICE */

            case 'z':
	    case 'Z':

#if HAVE_LIBZ      
	       status |= Fs_Compress;

               continue; 
#else					/* HAVE_LIBZ */
               fail; 
#endif					/* HAVE_LIBZ */



	    default:
	       runerr(209, spec);
	    }
	 }

      /*
       * Construct a mode field for fopen/popen.
       */
      mode[0] = '\0';
      mode[1] = '\0';
      mode[2] = '\0';
      mode[3] = '\0';

#ifdef Dbm
      /* If we're opening a dbm database, the default is set further down to
         "rw" */
      if (!(status & Fs_Dbm))
#endif					/* Dbm */
#ifdef ISQL
      /* If we're opening a sql database, modes are not used */
      if (!(status & Fs_ODBC))
#endif					/* ISQL */

      if ((status & (Fs_Read|Fs_Write)) == 0)	/* default: read only */
	 status |= Fs_Read;
      if (status & Fs_Create)
	 mode[0] = 'w';
      else if (status & Fs_Append)
	 mode[0] = 'a';
      else if (status & Fs_Read)
	 mode[0] = 'r';
      else
	 mode[0] = 'w';

/*
 * The following code is operating-system dependent [@fsys.05].  Handle open
 *  modes.
 */

#if PORT
      if ((status & (Fs_Read|Fs_Write)) == (Fs_Read|Fs_Write))
	 mode[1] = '+';
Deliberate Syntax Error
#endif					/* PORT */

#if AMIGA || ARM || UNIX || VMS
      if ((status & (Fs_Read|Fs_Write)) == (Fs_Read|Fs_Write))
	 mode[1] = '+';
#endif					/* AMIGA || ARM || UNIX || VMS */

#if MACINTOSH
      if ((status & (Fs_Read|Fs_Write)) == (Fs_Read|Fs_Write)) {
         mode[1] = '+';
         if ((status & Fs_Untrans) != 0) mode[2] = 'b';
         }
      else if ((status & Fs_Untrans) != 0) mode[1] = 'b';
#endif					/* MACINTOSH */

#if MSDOS || OS2
      if ((status & (Fs_Read|Fs_Write)) == (Fs_Read|Fs_Write)) {
	 mode[1] = '+';
#if CSET2
         /* we don't have the 't' in C Set/2 */
         if ((status & Fs_Untrans) != 0) mode[2] = 'b';
         } /* End of if - open file for reading or writing */
      else if ((status & Fs_Untrans) != 0) mode[1] = 'b';
#else					/* CSET2 */
	 mode[2] = ((status & Fs_Untrans) != 0) ? 'b' : 't';
	 }
      else mode[1] = ((status & Fs_Untrans) != 0) ? 'b' : 't';
#endif					/* CSET2 */
#endif					/* MSDOS || OS2 */

#if MVS || VM
      if ((status & (Fs_Read|Fs_Write)) == (Fs_Read|Fs_Write)) {
	 mode[1] = '+';
	 mode[2] = ((status & Fs_Untrans) != 0) ? 'b' : 0;
	 }
      else mode[1] = ((status & Fs_Untrans) != 0) ? 'b' : 0;
#endif					/* MVS || VM */

/*
 * End of operating-system specific code.
 */

      /*
       * Open the file with fopen or popen.
       */

#ifdef OpenAttributes
#if SASC
#ifdef RecordIO
	 f = afopen(fnamestr, mode, status & Fs_Record ? "seq" : "",
		    attrstring);
#else					/* RecordIO */
	 f = afopen(fnamestr, mode, "", attrstring);
#endif					/* RecordIO */
#endif					/* SASC */

#else					/* OpenAttributes */


#ifdef Graphics
      if (status & Fs_Window) {
	 /*
	  * allocate an empty event queue for the window
	  */
	 Protect(hp = alclist(0, MinListSlots), runerr(0));

	 /*
	  * loop through attributes, checking validity
	  */
	 for (j = 0; j < n; j++) {
	    if (is:null(attr[j]))
	       attr[j] = emptystr;
	    if (!is:string(attr[j]))
	       runerr(109, attr[j]);
	    }

#ifdef Graphics3D
	 if (status & Fs_Window3D)
	    f = wopengl(fnamestr, hp, attr, n, &err_index);
	 else
#endif					/* Graphics3D */
	    f = wopen(fnamestr, hp, attr, n, &err_index,0);

	 if (f == NULL) {
	    if (err_index >= 0) runerr(145, attr[err_index]);
	    else if (err_index == -1) fail;
	    else runerr(305);
	    }
	 } else
#endif					/* Graphics */

#ifdef Messaging
	    if (status & Fs_Messaging) {
	       extern int Merror;
	       if (status & ~(Fs_Messaging|Fs_Read|Fs_Write|Fs_Untrans)) {
		  runerr(209, spec);
		  }
	       else {
		  URI *puri;
		  register int a;
		  char *buf[4192];
		  tended char *tmps;

		  /* Check attributes (stolen from above) */
		  for (a=0; a<n; a++) {
		     if (is:null(attr[a])) {
			attr[a] = emptystr;
			}
		     else if (!cnv:C_integer(attr[a], timeout)) {
			M_open_timeout = timeout;
			continue;
			}
		     else if (!is:string(attr[a])) {
			runerr(109, attr[a]);
			}
		     if (cnv:C_string(attr[a], tmps)) {
#ifdef MDEBUG
			fprintf(stderr, "header: %s\n", tmps);
			fflush(stderr);
#endif                                  /* MDEBUG */
			}
		     }

		  /* Try to parse the filename as a URL */
		  puri = uri_parse(fnamestr);
		  switch (puri->status) {
		     case URI_OK:
			break;
		     case URI_EMALFORMED:
			runerr(1201, fname);
			break;
		     case URI_ENOUSER:
			runerr(1202, fname);
			break;
		     case URI_EUNKNOWNSCHEME:
			runerr(1203, fname);
			break;
		     case URI_ECHECKERRNO:
		     default:
#ifdef PosixFns
			if (errno != 0) {
			   IntVal(amperErrno) = errno;
			   }
#endif                                  /* PosixFns */
			runerr(1204, fname);
		     }

		  f = (FILE *)Mopen(puri, attr, n, is_shortreq);
		  if (Merror > 1200) {
		    runerr(Merror, fname);
		  }
		  switch (Merror) {
		     case 0:
			break;
		     case TP_ECONNECT:
			/*
			 * used to be runerr 1205
			 */
			fail;
		     case TP_EHOST:
			/*
			 * used to be runerr 1206
			 */
			fail;
		     case TP_ESERVER:
			runerr(1212, fname);
			break;
		     case TP_EMEM:
		     case TP_EOPEN:
		     default:
			runerr(1200, fname);
			break;
		     }
		  }
	       }
	    else
#endif                                  /* Messaging */

#ifdef ISQL
   if (status & Fs_ODBC) {
      if (n < 2) runerr(103);
      if (!is:string(attr[0])) runerr(103, attr[0]);
      if (!is:string(attr[1])) runerr(103, attr[1]);
      if (n >= 3) {
	 if (!is:string(attr[2])) runerr(103, attr[2]);
	 f = isql_open(fnamestr, attr, attr+1, attr+2);
	 }
      else { /* n == 2, treat as omitting table; user, password required */
	 f = isql_open(fnamestr, NULL, attr, attr+1);
	 }
      }
   else
#endif					/* ISQL */

#ifdef HAVE_VOICE
   if (status & Fs_Voice) {
      /* check arguments, number and type */
      /* attr[0] is a destination */
      if( n > 0){
      	tended char *tmps; 
      	
	if (is:null(attr[0])) 
		attr[0] = emptystr;
	
	if (!is:string(attr[0])) 
		runerr(109, attr[0]);
	
	if (cnv:C_string(attr[0], tmps))
		f = (FILE*) CreateVoiceSession(fnamestr,tmps);
	else
		fail;
      }
      else
      	f = (FILE*) CreateVoiceSession(fnamestr,NULL);
      }
   else
#endif					/* HAVE_VOICE */

      /* a bidirectional pipe can mean only one thing: pseudotty */
      if (status == (Fs_Pipe | Fs_Read | Fs_Write)) {
#ifdef PseudoPty
	 status = Fs_Pty | Fs_Read | Fs_Write;
	 f = (FILE*) ptopen(fnamestr);
#else
	 fprintf(stderr, "This VM is not built with bidirectional pipes.\n");
	 fail;
#endif
	 }
      else

#if AMIGA || ARM || OS2 || UNIX || VMS || NT
      if (status & Fs_Pipe) {
	 tended char *sbuf, *sbuf2, *my_s = NULL;
	 int c, fnamestrlen = strlen(fnamestr);
	 if (status != (Fs_Read|Fs_Pipe) && status != (Fs_Write|Fs_Pipe))
	    runerr(209, spec);
	 /*
	  * fnamestr is a program command line.  Extract its first
	  * argument (the command) and expand that with a path search.
	  */
	 Protect(reserve(Strings, (fnamestrlen<<1)+PATH_MAX+2), runerr(0));
	 sbuf = alcstr(fnamestr, fnamestrlen+1);
	 sbuf[fnamestrlen] = '\0';
	 if ((my_s = strchr(sbuf, ' ')) != NULL) *my_s = '\0';
	 if (!strchr(sbuf,'\\') && !strchr(sbuf, '/')) {
	    sbuf2 = alcstr(NULL, PATH_MAX+fnamestrlen);
	    if (findonpath(sbuf, sbuf2, PATH_MAX) == NULL)
	       fail;
	    fnamestr = sbuf2;
	    if (my_s) {
	       strcat(fnamestr, " ");
	       strcat(fnamestr, my_s+1);
	       }
	    }

	 f = popen(fnamestr, mode);
	 if (!strcmp(mode,"r")) {
	    if ((c = getc(f)) == EOF) {
	       pclose(f);
	       fail;
	       }
	    else
	       ungetc(c, f);
	    }
	 }
      else
#endif					/* AMIGA || ARM || OS2 || ... */

#ifdef Dbm
      if (status & Fs_Dbm) {
	 int mode;
	 if ((status & Fs_Read && status & Fs_Write) || status == Fs_Dbm) {
	    mode = O_RDWR|O_CREAT;
	    status |= Fs_Read|Fs_Write;
	 }
	 else if (status & Fs_Write) {
	    mode = O_WRONLY|O_CREAT;
	 }
	 else
	   mode = O_RDONLY;

	 f = (FILE *)dbm_open(fnamestr, mode, 0666);
	 if (!f) {
	    fail;
	    }
      }
      else
#endif					/* DBM */

#if HAVE_LIBZ
      if (status & Fs_Compress) {
         /*add new code here*/
         f = (FILE *)gzopen(fnamestr, mode);
         }
      else 
#endif					/* HAVE_LIBZ */


#ifdef PosixFns
      {
	 if (status & Fs_Socket) {
	    /* The only allowed values for flags are "n" and "na" */
	    if (status & ~(Fs_Read|Fs_Write|Fs_Socket|Fs_Append|Fs_Unbuf|Fs_Listen))
	       runerr(209, spec);
	    if (status & Fs_Append) {
	       /* "na" => listen for connections */
      	       DEC_NARTHREADS;
	       fd = sock_listen(fnamestr, is_udp_or_listener);
      	       INC_NARTHREADS_CONTROLLED;
	       }
	    else {
	       C_integer timeout = 0;
#if defined(Graphics) || defined(Messaging) || defined(ISQL)
	       if (n > 0 && !is:null(attr[0])) {
                  if (!cnv:C_integer(attr[0], timeout))
                     runerr(101, attr[0]);
               }
#endif					/* Graphics || Messaging || ISQL */
	       /* connect to a port */
      	       DEC_NARTHREADS;
	       fd = sock_connect(fnamestr, is_udp_or_listener, timeout);
      	       INC_NARTHREADS_CONTROLLED;
	    }
	    /*
	     * read/reads is not allowed on a listener socket, only select
	     * read/reads is not allowed on a UDP socket, only receive
	     */
	    if (is_udp_or_listener == 2)
	       status = Fs_Socket | Fs_Listen;
	    else if (is_udp_or_listener == 1)
	       status = Fs_Socket | Fs_Write;
	    else
	       status = Fs_Socket | Fs_Read | Fs_Write;


	    if (!fd) {
	       IntVal(amperErrno) = errno;
	       fail;
	       }

	    StrLen(filename) = strlen(fnamestr);
	    StrLoc(filename) = fnamestr;
	    Protect(fl = alcfile(0, status, &filename), runerr(0));
	    fl->fd.fd = fd;
	    return file(fl);
	    }
	 else if (stat(fnamestr, &st) < 0) {
	    /* stat reported an error; file does not exist */

            if (strchr(fnamestr, '*') || strchr(fnamestr, '?')) {
		char tempbuf[1024];
#if UNIX
	    	strcpy(tempbuf, "ls -1d ");
/*
 * Get rid of colored ls output.  On by default.
 */
#ifndef NoLsExtensions
	    	strcat(tempbuf, "--indicator-style=none ");
#endif					/* LsExtensions */
	    	strcat(tempbuf, fnamestr);
	    	status |= Fs_Pipe;
	    	f = popen(tempbuf, "r");
#endif
#if NT
		*tempbuf = '\0';
         	if (strchr(fnamestr, '*') || strchr(fnamestr, '?')) {
            	   /*
	     	    * attempted to open a wildcard, do file completion
	     	    */
		   strcpy(tempbuf, fnamestr);
            	   }
	 	else {
            	   /*
	     	    * check and see if the file was actually a directory
	      	    */
            	    struct stat fs;

            	    if (stat(fnamestr, &fs) == -1) fail;
	    	    if (S_ISDIR(fs.st_mode)) {
	       	       strcpy(tempbuf, fnamestr);
	       	       if (tempbuf[strlen(tempbuf)-1] != '\\')
	               strcat(tempbuf, "\\");
	       	       strcat(tempbuf, "*.*");
	       	       }
	    	    }
         	if (*tempbuf) {
            	   FINDDATA_T fd;
	    	   if (!FINDFIRST(tempbuf, &fd)) fail;
            	   f = tmpfile();
            	   if (f == NULL) fail;
            	   do {
               	      fprintf(f, "%s\n", FILENAME(&fd));
               	      } while (FINDNEXT(&fd));
            	   FINDCLOSE(&fd);
            	   fflush(f);
            	   fseek(f, 0, SEEK_SET);
            	   if (f == NULL) fail;
	    	   }
#endif					/* NT */
		/*
		 * Return the resulting file value. Duplicate of code below,
		 * because rtt does not support goto statements.
		 */
		StrLen(filename) = strlen(fnamestr);
		StrLoc(filename) = fnamestr;
		Protect(fl = alcfile(f, status, &filename), runerr(0));
#ifdef Graphics
		/*
		 * link in the Icon file value so this window can find it
		 */
		if (status & Fs_Window) {
		  linkfiletowindow((wbp)f, fl);
		  }
#endif					/* Graphics */
		return file(fl);
	    	}
	    else
	    if (errno == ENOENT && (status & Fs_Read))
	       fail;
	    else
	       f = fopen(fnamestr, mode);
	 }
	 else {
	    /*
	     * check and see if the file was actually a directory
	     */
	    if (S_ISDIR(st.st_mode)) {
	       if (status & Fs_Write)
		  runerr(173, fname);
	       else {
#if !NT || defined(NTGCC)
		  f = (FILE *)opendir(fnamestr);
		  status |= Fs_Directory;
#else					/* !NT */
		  char tempbuf[512];
		  strcpy(tempbuf, fnamestr);
		  if (tempbuf[strlen(tempbuf)-1] != '\\')
		     strcat(tempbuf, "\\");
		  strcat(tempbuf, "*.*");
		  if (*tempbuf) {
		     extern FILE *mytmpfile();
		     FINDDATA_T fd;
		     if (!FINDFIRST(tempbuf, &fd)) {
			fail;
			}
		     f = mytmpfile();
		     if (f == NULL) {
			fail;
			}
		     do {
			fprintf(f, "%s\n", FILENAME(&fd));
			}
		     while (FINDNEXT(&fd));
		     FINDCLOSE(&fd);
		     fflush(f);
		     fseek(f, 0, SEEK_SET);
		     }
#endif					/* NT */
		  }
	       }
	    else {
	       f = fopen(fnamestr, mode);
	       }
	    }
	 }
#else					/* PosixFns */
  	 f = fopen(fnamestr, mode);
#endif 					/* PosixFns */
#endif					/* OpenAttributes */

      /*
       * Fail if the file cannot be opened.
       */
      if (f == NULL)
      	 fail;

#if MACINTOSH
#if MPW
      {
	 void SetFileToMPWText(const char *fname);

	 if (status & Fs_Write)
	    SetFileToMPWText(fnamestr);
      }
#endif					/* MPW */
#endif					/* MACINTOSH */

      /*
       * Return the resulting file value.
       */
      StrLen(filename) = strlen(fnamestr);
      StrLoc(filename) = fnamestr;

      Protect(fl = alcfile(f, status, &filename), runerr(0));

#ifdef Graphics
      /*
       * link in the Icon file value so this window can find it
       */
      if (status & Fs_Window) {
	 linkfiletowindow((wbp)f, fl);
	 }
#endif					/* Graphics */
      return file(fl);
      }
end


"read(f) - read line on file f."

function{0,1} read(f)
   /*
    * Default f to &input.
    */
   if is:null(f) then
      inline {
	 f.dword = D_File;
	 BlkLoc(f) = (union block *)&k_input;
	 }
   else if !is:file(f) then
      runerr(105, f)

   abstract {
      return string
      }

   body {
      register word slen, rlen;
      tended char *sptr;
      int status;
      char sbuf[MaxReadStr];
      tended struct descrip s;
      FILE *fp;
#ifdef PosixFns
      SOCKET ws;
#endif					/* PosixFns */

      /*
       * Get a pointer to the file and be sure that it is open for reading.
       */
      fp = BlkD(f,File)->fd.fp;
      status = BlkLoc(f)->File.status;
      if ((status & Fs_Read) == 0)
	 runerr(212, f);

/*
 * Should probably move these cases into getstrg() in rsys.r, where
 * the other cases, such as Fs_Messaging, are handled.
 */

#ifdef PosixFns
       if (status & Fs_Socket) {
	  StrLen(s) = 0;
          do {
	     ws = (SOCKET)BlkD(f,File)->fd.fd;
      	     DEC_NARTHREADS;
	     if ((slen = sock_getstrg(sbuf, MaxReadStr, ws)) == -1) {
	        /*IntVal(amperErrno) = errno; */
      	        INC_NARTHREADS_CONTROLLED;
	        fail;
		}
      	     INC_NARTHREADS_CONTROLLED;
	     if (slen == -3)
		fail;
	     if (slen == 1 && *sbuf == '\n')
		break;
	     rlen = slen < 0 ? (word)MaxReadStr : slen;

	     Protect(reserve(Strings, rlen), runerr(0));
	     if (StrLen(s) > 0 && !InRange(strbase,StrLoc(s),strfree)) {
	        Protect(reserve(Strings, StrLen(s)+rlen), runerr(0));
	        Protect((StrLoc(s) = alcstr(StrLoc(s),StrLen(s))), runerr(0));
		}

	     Protect(sptr = alcstr(sbuf,rlen), runerr(0));
	     if (StrLen(s) == 0)
	        StrLoc(s) = sptr;
	     StrLen(s) += rlen;
	     if (StrLoc(s) [ StrLen(s) - 1 ] == '\n') { StrLen(s)--; break; }
	     else {
		/* no newline to trim; EOF? */
		}
	     }
	  while (slen > 0);

         return s;
	  }

      /*
       * well.... switching from unbuffered to buffered actually works so
       * we will allow it except for sockets.
       */
      if ((status & Fs_Unbuf) && (!(status & Fs_Messaging))) {
	 if (status & Fs_Socket)
	    runerr(1048, f);
	 status &= ~Fs_Unbuf;
#ifdef Graphics
	 /* windows never turn on buffering */
	 if (! (status & Fs_Window))
#endif					/* Graphics */
	    status |= Fs_Buff;
	 BlkLoc(f)->File.status = status;
	 }
#endif					/* PosixFns */

      /* add more restriction on non-seekable entities. */
      if ((status & Fs_Writing) && !(status & Fs_BPipe)) {
	 if (fseek(fp, 0L, SEEK_CUR) != 0) {
	    /* add bad stuff here, almost certainly EBADF not-seekable */
	    }
	 BlkLoc(f)->File.status &= ~Fs_Writing;
	 }
      BlkLoc(f)->File.status |= Fs_Reading;

#ifdef ConsoleWindow
      /*
       * if file is &input, then make sure our console is open and read
       * from it, unless input redirected
       */
      if (fp == stdin
           && !(ConsoleFlags & StdInRedirect)
           ) {
        fp = OpenConsole();
        status = Fs_Window | Fs_Read | Fs_Write;
        }

#endif					/* ConsoleWindow */
      /*
       * Use getstrg to read a line from the file, failing if getstrg
       *  encounters end of file. [[ What about -2?]]
       */
      StrLen(s) = 0;
      StrLoc(s) = "";
      do {

#ifdef Graphics
	 pollctr >>= 1;
	 pollctr++;
	 if (status & Fs_Window) {
      	    DEC_NARTHREADS;
	    slen = wgetstrg(sbuf,MaxReadStr,fp);
      	    INC_NARTHREADS_CONTROLLED;
	    if (slen == -1)
	       runerr(141);
	    else if (slen == -2)
	       runerr(143);
	    else if (slen == -3)
               fail;
	    }
	 else
#endif					/* Graphics */

#ifdef PosixFns
#if !NT || defined(NTGCC)
	  if (status & Fs_Directory) {
	     struct dirent *d;
	     char *s, *p=sbuf;
	     IntVal(amperErrno) = 0;
	     slen = 0;
      	     DEC_NARTHREADS;
	     d = readdir((DIR *)fp);
      	     INC_NARTHREADS_CONTROLLED;
	     if (!d)
	        fail;
	     s = d->d_name;
	     while(*s && slen++ < MaxReadStr)
	        *p++ = *s++;
	     if (slen == MaxReadStr)
		slen = -2;
	  }
	  else
#endif
#endif					/* PosixFns */


#if HAVE_LIBZ
        /*
	 * Read a line from a compressed file
	 */
	if (status & Fs_Compress) {
            
            if (gzeof(fp)) fail;
      	    DEC_NARTHREADS;
            if (gzgets((gzFile)fp,sbuf,MaxReadStr+1) == Z_NULL) {
      	       INC_NARTHREADS_CONTROLLED;
	       runerr(214);
               }
      	    INC_NARTHREADS_CONTROLLED;
	    slen = strlen(sbuf);

            if (slen==MaxReadStr && sbuf[slen-1]!='\n') slen = -2;
	    else if (sbuf[slen-1] == '\n') {
               sbuf[slen-1] = '\0';
               slen--;
               }
           
	    }
           
	else 
#endif					/* HAVE_LIBZ */

#ifdef PseudoPty
	   if (status & Fs_Pty) {
/*	      struct timeval timeout;
	      timeout.tv_sec = 1L;
	      timeout.tv_usec = 0L; */
      	      DEC_NARTHREADS;
	      if ((slen = ptgetstr(sbuf, MaxReadStr, (struct ptstruct *)fp, 0))
		== -1){
      		 INC_NARTHREADS_CONTROLLED;
		 fail;
		 }
      	      INC_NARTHREADS_CONTROLLED;
	      }
	 else
#endif					/* PseudoPty */

#ifdef RecordIO
	 if ((slen = (status & Fs_Record ? getrec(sbuf, MaxReadStr, fp) :
			   getstrg(sbuf, MaxReadStr, BlkD(f,File))))
	     == -1)
	     fail;
#else					/* RecordIO */

	 if ((slen = getstrg(sbuf, MaxReadStr, BlkD(f,File))) == -1) {
#ifdef PosixFns
	    IntVal(amperErrno) = errno;
#endif					/* PosixFns */
	    fail;
	    }
#endif					/* RecordIO */

	 /*
	  * Allocate the string read and make s a descriptor for it.
	  */
	 if ((status & Fs_Messaging) && (slen == -2)) rlen = MaxReadStr-1;
	 else
	 rlen = slen < 0 ? (word)MaxReadStr : slen;

	 Protect(reserve(Strings, rlen), runerr(0));
	 /*
	  * If extending our read string bumped us into a new heap...
	  */
	 if (StrLen(s) > 0 && !InRange(strbase,StrLoc(s),strfree)) {
	    /*
	     * Copy the prefix into the new heap, followed by the new part.
	     * Start by reserving enough space for the whole thing.
	     */
	    Protect(reserve(Strings, StrLen(s)+rlen), runerr(0));
	    /*
	     * recast this as a single call to alcstr(NULL, StrLen(s)+rlen)
	     * followed by two copies.
	     */
	     { int i, j;
	     sptr = alcstr(NULL, StrLen(s)+rlen);
	     for(i=0; i<StrLen(s); i++) sptr[i] = StrLoc(s)[i];
	     for(j=0; j<rlen; j++) sptr[i+j] = sbuf[j];
	     StrLoc(s) = sptr;
	     }
	    }
	 else
	    Protect(sptr = alcstr(sbuf,rlen), runerr(0));

	 if (StrLen(s) == 0)
	    StrLoc(s) = sptr;
	 StrLen(s) += rlen;
	 } while (slen < 0);
      return s;
      }
end


"reads(f,i) - read i characters on file f."

function{0,1} reads(f,i)
   /*
    * Default f to &input.
    */
   if is:null(f) then
      inline {
	 f.dword = D_File;
	 BlkLoc(f) = (union block *)&k_input;
	 }
   else if !is:file(f) then
      runerr(105, f)

   /*
    * i defaults to 1 (read a single character)
    */
   if !def:C_integer(i,1L) then
      runerr(101, i)

   abstract {
      return string
      }

   body {
      register word slen, rlen;
      register char *sptr;
      char sbuf[MaxReadStr];
      SOCKET ws;
      int bytesread = 0;
      int Maxread = 0;
      long tally, nbytes;
      int status, fd, kk;
      FILE *fp = NULL;
      tended struct descrip s;

#if defined(NTGCC) && (WordBits==32)
#passthru #if (__GNUC__==4) && (__GNUC_MINOR__>7)
#passthru #define stat _stat64i32
#passthru #endif
#endif					/* NTGCC && WordBits==32*/
      struct stat statbuf;

      /*
       * Get a pointer to the file and be sure that it is open for reading.
       */
      status = BlkD(f,File)->status;
      if ((status & Fs_Read) == 0)
	 runerr(212, f);

#ifdef Messaging
      if (status & Fs_Messaging) {
	 struct MFile *mf = BlkLoc(f)->File.fd.mf;
	 /* Casting to unsigned lets us use reads(f, -1) */

	 Maxread = (unsigned)i <= MaxReadStr ? i : MaxReadStr;

	 StrLoc(s) = NULL;
	 StrLen(s) = 0;
      	 DEC_NARTHREADS;
	 if (!MFIN(mf, READING)) {
	    Mstartreading(mf);
	    }
      	 INC_NARTHREADS_CONTROLLED;
	 nbytes = 0;
	 do {
	    if (bytesread > 0) {
	       if (i - bytesread <= MaxReadStr)
		  Maxread = i - bytesread;
	       else
		  Maxread = MaxReadStr;
	       }
      	    DEC_NARTHREADS;
	    slen = tp_read(mf->tp, sbuf, Maxread);
      	    INC_NARTHREADS_CONTROLLED;

	    if (slen <= 0) {
	       extern int Merror;
	       if (Merror >= 1200) {
		  runerr(Merror, f);
		  }
	       if (bytesread == 0)
		  fail;
	       else return s;
	       }
	    bytesread += slen;
	    rlen = slen < 0 ? (word)MaxReadStr : slen;

	    Protect(reserve(Strings, StrLen(s) + rlen), runerr(0));
	    if (StrLen(s) > 0 && !InRange(strbase, StrLoc(s), strfree)) {
	       Protect((StrLoc(s) =
                        alcstr(StrLoc(s), StrLen(s))), runerr(0));
	       }

	    Protect(sptr = alcstr(sbuf, rlen), runerr(0));
	    if (StrLen(s) == 0)
	       StrLoc(s) = sptr;
	    StrLen(s) += rlen;

	    } while ((i == -1) || (bytesread < i));

	 return s;
	 }

      else
#endif                                  /* Messaging */

#ifdef PseudoPty
      if (status & Fs_Pty) {
	 struct ptstruct *p = (struct ptstruct *)BlkLoc(f)->File.fd.fp;
	 tended char *s = alcstr(NULL, i);
      	 DEC_NARTHREADS;
	 if ((slen = ptlongread(s, i, p)) == -1) {
      	    INC_NARTHREADS_CONTROLLED;
	    fail;
	    }
      	 INC_NARTHREADS_CONTROLLED;
	 return string(slen, s);
	 }
      else
#endif                                  /* PseudoPty */


#ifdef PosixFns
         if (status & Fs_Socket) {
	    StrLen(s) = 0;
	    Maxread = (i <= MaxReadStr)? i : MaxReadStr;
	    do {
	       ws = (SOCKET)BlkD(f,File)->fd.fd;
	       if (bytesread > 0) {
		  if (i - bytesread <= MaxReadStr)
		     Maxread = i - bytesread;
		  else
		     Maxread = MaxReadStr;
		  }
      	       DEC_NARTHREADS;
	       if ((slen = sock_getstrg(sbuf, Maxread, ws)) == -1) {
		    /*IntVal(amperErrno) = errno; */
      	            INC_NARTHREADS_CONTROLLED;
		    if (bytesread == 0)
		        fail;
		    else
		        return s;
		}
      	        INC_NARTHREADS_CONTROLLED;
		if (slen == -3)
		    fail;

		if (slen > 0)
		    bytesread += slen;
		rlen = slen < 0 ? (word)MaxReadStr : slen;

		Protect(reserve(Strings, StrLen(s) + rlen), runerr(0));
		if (StrLen(s) > 0 && !InRange(strbase, StrLoc(s), strfree)) {
		    Protect(reserve(Strings, StrLen(s) + rlen), runerr(0));
		    Protect((StrLoc(s) =
                        alcstr(StrLoc(s), StrLen(s))), runerr(0));
		    }

		Protect(sptr = alcstr(sbuf, rlen), runerr(0));
		if (StrLen(s) == 0)
		    StrLoc(s) = sptr;
		StrLen(s) += rlen;
	    } while ((i == -1) || (bytesread < i));
	    return s;
	}

        /* This is a hack to fix things for the release. The solution to be
	 * implemented after release: all I/O is low-level, no stdio. This
	 * makes the Fs_Buff/Fs_Unbuf go away and select will work -- 
	 * correctly. */
        if (strcmp(StrLoc(BlkD(f,File)->fname), "pipe") != 0) {
	    status |= Fs_Buff;
	    BlkLoc(f)->File.status = status;
	}
#endif					/* PosixFns */

      fp = BlkD(f,File)->fd.fp;
      if (status & Fs_Writing) {
	 fseek(fp, 0L, SEEK_CUR);
	 BlkLoc(f)->File.status &= ~Fs_Writing;
	 }
      BlkLoc(f)->File.status |= Fs_Reading;

#ifdef ConsoleWindow
      /*
       * if file is &input, then make sure our console is open and read
       * from it, unless input redirected
       */
      if (fp == stdin
          && !(ConsoleFlags & StdInRedirect)
          ) {
        fp = OpenConsole();
        status = Fs_Read | Fs_Write | Fs_Window;
        }
#endif					/* ConsoleWindow */

#ifdef ReadDirectory
#if !NT
      /*
       *  If reading a directory, return up to i bytes of next entry.
       */
      if ((BlkD(f,File)->status & Fs_Directory) != 0) {
         char *sptr;
	 struct dirent *de;
      	 DEC_NARTHREADS;
         de = readdir((DIR*) fp);
      	 INC_NARTHREADS_CONTROLLED;
         if (de == NULL)
            fail;
         nbytes = strlen(de->d_name);
         if (nbytes > i)
            nbytes = i;
         Protect(sptr = alcstr(de->d_name, nbytes), runerr(0));
         return string(nbytes, sptr);
         }
#endif
#endif					/* ReadDirectory */

      /*
       * For ordinary files, reads -1 means the whole file.
       */
      if ((i == -1) && (status == (Fs_Read|Fs_Buff))) {
	 if ((fd = fileno(fp)) == -1) fail;
	 if ((kk = fstat(fd, &statbuf)) == -1) fail;
	 i = statbuf.st_size;
	 }
      /*
       * For suspiciously large reads on normal files, cap at file size.
       */
      else if ((i >= 65535) && (status == (Fs_Read|Fs_Buff))) {
	 if ((fd = fileno(fp)) == -1) fail;
	 if ((kk = fstat(fd, &statbuf)) == -1) fail;
	 if (i > statbuf.st_size) i = statbuf.st_size;
	 }
      /*
       * Be sure that a positive number of bytes is to be read.
       */
      else if (i <= 0) {
	 irunerr(205, i);

	 errorfail;
	 }

#ifdef PosixFns
      /* Remember, sockets are always unbuffered */
      if ((status & Fs_Unbuf) && !(status & Fs_BPipe)) {
	 /* We do one read(2) call here to avoid interactions with stdio */

	 int fd;

	 if ((fd = get_fd(f, 0)) < 0)
	    runerr(174, f);

	 IntVal(amperErrno) = 0;
      	 DEC_NARTHREADS;
	 if (u_read(fd, i, &s) == 0){
      	    INC_NARTHREADS_CONTROLLED;
	    fail;
	    }
      	 INC_NARTHREADS_CONTROLLED;
	 return s;
      }
#endif					/* PosixFns */

      /*
       * For now, assume we can read the full number of bytes.
       */
      Protect(StrLoc(s) = alcstr(NULL, i), runerr(0));
      StrLen(s) = 0;

#if HAVE_LIBZ
      /*
       * Read characters from a compressed file
       */
      if (status & Fs_Compress) {
	 if (gzeof(fp)) {
	    fail;
	    }
      	 DEC_NARTHREADS;
	 slen = gzread((gzFile)fp,StrLoc(s),i);
      	 INC_NARTHREADS_CONTROLLED;
	 if (slen == 0)
	    fail;
	 else if (slen == -1)
	    runerr(214);
	 return string(slen, StrLoc(s));
	 }
#endif					/* HAVE_LIBZ */

#ifdef Graphics
      pollctr >>= 1;
      pollctr++;
      if (status & Fs_Window) {
	 tally = wlongread(StrLoc(s),sizeof(char),i,fp);
	 if (tally == -1)
	    runerr(141);
	 else if (tally == -2)
	    runerr(143);
	 else if (tally == -3)
            fail;
	 }
      else {
#endif					/* Graphics */
      DEC_NARTHREADS;
      tally = longread(StrLoc(s),sizeof(char),i,fp);
      INC_NARTHREADS_CONTROLLED;
#ifdef Graphics
      }
#endif					/* Graphics */

      if (tally == 0)
	 fail;
      StrLen(s) = tally;
      /*
       * We may not have used the entire amount of storage we reserved.
       */
      nbytes = DiffPtrs(StrLoc(s) + tally, strfree);
      EVStrAlc(nbytes);
      strtotal += nbytes;
      strfree = StrLoc(s) + tally;
      return s;
      }
end


"remove(s) - remove the file named s."

function{0,1} remove(s)

   /*
    * Make a C-style string out of s
    */
   if !cnv:C_string(s) then
      runerr(103,s)
   abstract {
      return null
      }

   inline {
      CURTSTATE();
      if (remove(s) != 0) {
#ifdef PosixFns
	 IntVal(amperErrno) = 0;
#if NT
#define rmdir _rmdir
#endif					/* NT */
	 if (rmdir(s) != 0) {
	    IntVal(amperErrno) = errno;
	    fail;
            }
#endif					/* PosixFns */
	 fail;
         }
      return nulldesc;
      }
end


"rename(s1,s2) - rename the file named s1 to have the name s2."

function{0,1} rename(s1,s2)

   /*
    * Make C-style strings out of s1 and s2
    */
   if !cnv:C_string(s1) then
      runerr(103,s1)
   if !cnv:C_string(s2) then
      runerr(103,s2)

   abstract {
      return null
      }

   body {
      int i=0;
#if NT
      if ((i = rename(s1,s2)) != 0) {
	 remove(s2);
	 if (rename(s1,s2) != 0)
	    fail;
	 }
      return nulldesc;
#else					/*NT*/
      if (rename(s1,s2) != 0)
	 fail;
      return nulldesc;
#endif					/* NT */
      }
end

#ifdef ExecImages

"save(s) - save the run-time system in file s"

function{0,1} save(s)

   if !cnv:C_string(s) then
      runerr(103,s)

   abstract {
      return integer
      }

   body {
      char sbuf[MaxCvtLen];
      int f, fsz;

      dumped = 1;

      /*
       * Open the file for the executable image.
       */
      f = creat(s, 0777);
      if (f == -1)
	 fail;
      fsz = wrtexec(f);
      /*
       * It happens that most wrtexecs don't check the system call return
       *  codes and thus they'll never return -1.  Nonetheless...
       */
      if (fsz == -1)
	 fail;
      /*
       * Return the size of the data space.
       */
      return C_integer fsz;
      }
end
#endif					/* ExecImages */


"seek(f,i) - seek to offset i in file f."
" [[ What about seek error ? ]] "

function{0,1} seek(f,o)

   /*
    * f must be a file
    */
   if !is:file(f) then
      runerr(105,f)

   /*
    * o must be an integer and defaults to 1.
    */
   if !def:C_integer(o,1L) then
      runerr(0)

   abstract {
      return file
      }

   body {
      FILE *fd;
      CURTSTATE();

      fd = BlkD(f,File)->fd.fp;
      if (BlkLoc(f)->File.status == 0)
	 fail;

#ifdef ReadDirectory
      if (BlkLoc(f)->File.status & Fs_Directory)
	 fail;
#endif					/* ReadDirectory */

#ifdef Graphics
      pollctr >>= 1;
      pollctr++;
      if (BlkD(f,File)->status & Fs_Window)
	 fail;
#endif					/* Graphics */


#if HAVE_LIBZ
      if (BlkD(f,File)->status & Fs_Compress) {
	 if ((o<0) || (gzseek(fd, o - 1, SEEK_SET)==-1))
	    fail;
	 else
	    return f;        
	 }
#endif                                 /* HAVE_LIBZ */

      if (o > 0) {
/* fseek returns a non-zero value on error for CSET2, not -1 */
#if CSET2
	 if (fseek(fd, o - 1, SEEK_SET))
#else
	 if (fseek(fd, o - 1, SEEK_SET) == -1)
#endif					/* CSET2 */
	    fail;

	 }

      else {

#if CSET2
/* unreliable seeking from the end in CSet/2 on a text stream, so
   we will fixup seek-from-end to seek-from-beginning */
	long size;
	long save_pos;

	/* save the position in case we have to reset it */
	save_pos = ftell(fd);
	/* seek to the end and get the file size */
	fseek(fd, 0, SEEK_END);
	size = ftell(fd);
	/* try to accomplish the fixed-up seek */
	if (fseek(fd, size + o, SEEK_SET)) {
	   fseek(fd, save_pos, SEEK_SET);
	   fail;
	   }  /* End of if - seek failed, reset position */
#else
	 if (fseek(fd, o, SEEK_END) == -1)
	    fail;
#endif					/* CSET2 */

	 }
      BlkLoc(f)->File.status &= ~(Fs_Reading | Fs_Writing);
      return f;
      }
end


#ifdef PosixFns
"system() - create a new process, optionally mapping its stdin/stdout/stderr."

function{0,1} system(argv, d_stdin, d_stdout, d_stderr, mode)
   if !is:file(d_stdin) then
      if !is:string(d_stdin) then
	 if !is:null(d_stdin) then
	    runerr(105, d_stdin)
   if !is:file(d_stdout) then
      if !is:string(d_stdout) then
	 if !is:null(d_stdout) then
	    runerr(105, d_stdout)
   if !is:file(d_stderr) then
      if !is:string(d_stderr) then
	 if !is:null(d_stderr) then
	    runerr(105, d_stderr)
   if !is:list(argv) then
      if !is:string(argv) then
         runerr(110, argv)
   if !is:string(mode) then
      if !is:integer(mode) then
	 if !is:file(mode) then
	    if !is:null(mode) then
	       runerr(170, mode)
   abstract {
      return null ++ integer
      }
   body {
      int i, j, n, fd_0=-1, fd_1=-1, fd_2=-1, is_argv_str=0, pid;
      C_integer i_mode=0;
      tended union block *ep;
	 
      /*
       * We are subverting the RTT type system here w.r.t. garbage
       * collection but we're going to be doing an exec() so ...
       */
      tended char *p;
      tended char *cmdline;
      char **margv=NULL;
      IntVal(amperErrno) = 0;

      /* Decode the mode */
      if (is:integer(mode))
	 cnv:C_integer(mode, i_mode);
      else if (is:string(mode)) {
	 tended char *s_mode;
         cnv:C_string(mode, s_mode);
	 i_mode = (strcmp(s_mode, "nowait") == 0);
      }

      if (is:list(argv)) {
         margv = (char **)malloc((BlkD(argv,List)->size+3) * sizeof(char *));
         if (margv == NULL) runerr(305);
	 n = 0;
	 /* Traverse the list */
	 for (ep = BlkD(argv,List)->listhead; BlkType(ep) == T_Lelem;
	      ep = Blk(ep,Lelem)->listnext) {
	    for (i = 0; i < Blk(ep,Lelem)->nused; i++) {
	       dptr f;
	       j = Blk(ep,Lelem)->first + i;
	       if (j >= Blk(ep,Lelem)->nslots)
		  j -= Blk(ep,Lelem)->nslots;
	       f = &Blk(ep,Lelem)->lslots[j];

	       if (!cnv:C_string((*f), p))
		  runerr(103, *f);
#if NT
	       if ((n == 0) && is_internal(p)) {
		  margv[n++] = "cmd"; /* on Win9x this should be command */
		  margv[n++] = "/C";
		  margv[n++] = p;
		  }
	       else {
		  margv[n++] = p;
		  }
#else
		  margv[n++] = p;
#endif

	       }
	    }
	 margv[n] = 0;
         }
      else if (is:string(argv)) {
	 char *s;
	 is_argv_str = 1;
         cnv:C_string(argv, cmdline);

	 /*
	  * If we have a string it may have redirection orders.
	  * Since execl("/bin/sh"...) doesn't seem to handle those
	  * redirections for us, figure out how to do them ourselves.
	  * This is a lame hack. Someone needs to think through
	  * a general solution and rewrite it.
	  */
	 if (s = strstr(cmdline, "&>")) {
	    *s = '\0';
	    s += 2;
	    while (*s == ' ') s++;
	    StrLen(d_stdout) = StrLen(d_stderr) = strlen(s);
	    StrLoc(d_stdout) = StrLoc(d_stderr) = s;
	    while (*s) {
	       if (*s == ' ') {
		  *s = '\0';
		  break;
		  }
	       s++;
	       }
	    }
	 else if (s = strstr(cmdline, ">>")) {
	    tended char *s_stdout;
	    *s = '\0';
	    s += 2;				/* skip over >> */
	    while (*s == ' ') s++;
	    StrLen(d_stdout) = strlen(s);
	    StrLoc(d_stdout) = s;

            cnv:C_string(d_stdout, s_stdout);
	    d_stdout.dword = D_Integer;
	    d_stdout.vword.integr =
#if UNIX
	       open(s_stdout, O_WRONLY|O_CREAT|O_APPEND, S_IRUSR|S_IWUSR);
#endif
#if NT
	       _open(s_stdout, O_WRONLY|O_CREAT|O_APPEND, _S_IWRITE|_S_IREAD);
#endif

	    while (*s) {
	       if (*s == ' ') {
		  *s = '\0';
		  break;
		  }
	       s++;
	       }
	    }
	 else if (s = strchr(cmdline, '>')) {
	    *s = '\0';
	    s++;
	    while (*s == ' ') s++;
	    StrLen(d_stdout) = strlen(s);
	    StrLoc(d_stdout) = s;
	    while (*s) {
	       if (*s == ' ') {
		  *s = '\0';
		  break;
		  }
	       s++;
	       }
	    }
      }

      /*
       * File redirection to/from (string) named files.
       * Open in the parent, fork/exec, close (in the parent).
       */
      if (is:string(d_stdin)) {
	 tended char *s_stdin;
         cnv:C_string(d_stdin, s_stdin);
	 d_stdin.dword = D_Integer;
	 d_stdin.vword.integr = open(s_stdin, O_RDONLY);
	 }
      if (is:string(d_stdout) && is:string(d_stderr) &&
	  (StrLen(d_stdout) == StrLen(d_stderr)) &&
	  !strncmp(StrLoc(d_stdout), StrLoc(d_stderr), StrLen(d_stdout))) {
	 /* special case: stderr/stdout to same file */
	 tended char *s_stdouterr;
         cnv:C_string(d_stdout, s_stdouterr);
	 d_stdout.dword = d_stderr.dword = D_Integer;
	 d_stdout.vword.integr =
#if UNIX
	    open(s_stdouterr, O_WRONLY|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR);
#endif
#if NT
	    _open(s_stdouterr, O_WRONLY|O_CREAT|O_TRUNC, _S_IWRITE|_S_IREAD);
#endif

	 d_stderr.vword.integr = d_stdout.vword.integr;
	 }
      else {
      if (is:string(d_stdout)) {
	 tended char *s_stdout;
         cnv:C_string(d_stdout, s_stdout);
	 d_stdout.dword = D_Integer;
	 d_stdout.vword.integr =
#if UNIX
	    open(s_stdout, O_WRONLY|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR);
#endif
#if NT
	    _open(s_stdout, O_WRONLY|O_CREAT|O_TRUNC, _S_IWRITE|_S_IREAD);
#endif
	 }
      if (is:string(d_stderr)) {
	 tended char *s_stderr;
         cnv:C_string(d_stderr, s_stderr);
	 d_stderr.dword = D_Integer;
	 d_stderr.vword.integr =
#if UNIX
	    open(s_stderr, O_WRONLY|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR);
#endif
#if NT
	    _open(s_stderr, O_WRONLY|O_CREAT|O_TRUNC, _S_IWRITE|_S_IREAD);
#endif
	 }
      }

#if !NT
      /* 
       * We don't use system(3) any more since the program is allowed to
       * re-map the files even for foreground execution
       */
#ifdef HAVE_WORKING_VFORK
      switch (pid = vfork()) {
#else					/* HAVE_WORKING_VFORK */
      switch (pid = fork()) {
#endif					/* HAVE_WORKING_VFORK */
      case 0:

	 dup_fds(&d_stdin, &d_stdout, &d_stderr);

	 if (is_argv_str) {
	    execl("/bin/sh", "sh", "-c", cmdline, (char *)0);
	    }
	 else {
	    if (execvp(margv[0], margv) == -1) {
	       free(margv);
	       }
            }

	  /*
	   * If we returned.... this is the child, so failure is no good;
	   * stop with a runtime error so at least the user will get some
	   * indication of the problem.
	   */
	  IntVal(amperErrno) = errno;
	  runerr(500);
	  break;
      case -1:
         if (margv) free(margv);
	 fail;
	 break;
      default:
         if (margv) free(margv);
	 if (is:integer(d_stdin) &&IntVal(d_stdin)>-1) close(IntVal(d_stdin));
	 if (is:integer(d_stdout)&&IntVal(d_stdout)>-1) close(IntVal(d_stdout));
	 if (is:integer(d_stderr) && (IntVal(d_stderr)>-1) &&
	     ((!is:integer(d_stdout))||(IntVal(d_stdout)!=IntVal(d_stderr))))
	    close(IntVal(d_stderr));
	 if (!i_mode) {
	    int status;
	    waitpid(pid, &status, 0);
	    return C_integer status;
	    }
	 else {
	    return C_integer pid;
            }
      }
#else					/* NT */
     /*
      * We might want to use CreateProcess and pass the file handles
      * for stdin/stdout/stderr to the child process.  Another candidate
      * is _execvp().
      */
      if (i_mode) {
         _flushall();
	 if (is:string(argv)) {
	    int argc;
	    char **garbage;
	    argc = CmdParamToArgv(cmdline, &garbage, 0);
	    if (is_internal(garbage[0])) {
	       int jj;
	       argc += 2;
	       garbage = realloc(garbage, (sizeof (char *)) * (argc+1));
	       garbage[argc] = NULL;
	       for(jj = argc-1; jj >= 2; jj--)
		  garbage[jj] = garbage[jj-2];
	       garbage[0] = "cmd";
	       garbage[1] = "/C";
	       }
	    i = (C_integer)_spawnvp(_P_NOWAITO, garbage[0], (const char* const*) garbage);
	    free(garbage);
	    }
	 else {
	    i = (C_integer)_spawnvp(_P_NOWAITO, margv[0], (const char* const*) margv);
	    free(margv);
            }
	 if (i != 0) {
	    IntVal(amperErrno) = errno;
	    fail;
	    }
         }
      else {
	    /* Sigh... old "system". Collect all args into a string. */
	    if (is_argv_str) {
	       int argc;
	       char **garbage, *g2;
extern char *ArgvToCmdline(char **);
	       argc = CmdParamToArgv(cmdline, &garbage, 0);
	       if (is_internal(garbage[0])) {
	       	  int jj;
	       	  argc += 2;
	       	  garbage = realloc(garbage, (sizeof (char *)) * (argc+1));
	       	  garbage[argc] = NULL;
	       	  for(jj = argc-1; jj >= 2; jj--)
		     garbage[jj] = garbage[jj-2];
	       	  garbage[0] = "cmd";
	       	  garbage[1] = "/C";
	       	  }
               g2 = ArgvToCmdline(garbage);

#ifdef MSWindows
	       i = (C_integer)mswinsystem(g2);
#else					/* MSWindows */
	       i = (C_integer)system(g2);
#endif					/* MSWindows */
	       free(garbage);
	       free(g2);
	       return C_integer i;
	       }
	    else {
	       int i, total = 0, n;
	       tended char *s;
	       i = 0;
	       while (margv[i]) {
		  total += strlen(margv[i]) + 1;
		  i++;
		  }
	       n = i;
	       /* We use Icon's allocator, it's the only safe way. */
	       Protect(s = alcstr(0, total), runerr(0));
	       p = s;
	       for (i = 0; i < n; i++) {
		  strcpy(p, margv[i]);
		  p += strlen(margv[i]);
		  *p++ = ' ';
		  }
               --p;
	       *p = '\0';
#ifdef MSWindows
	       i = (C_integer)mswinsystem(s);
#else					/* MSWindows */
	       i = (C_integer)system(s);
#endif					/* MSWindows */
	       free(margv);
	       return C_integer i;
	       }
	    }
#endif					/* NT */

      /*NOTREACHED*/
      return nulldesc;
   }
end
#else

"system(s) - execute string s as a system command."

function{1} system(s, o)
   /*
    * Make a C-style string out of s
    */
   if !cnv:C_string(s) then
      runerr(103,s)
   /*
    * o must be an integer and defaults to 1.
    */
   if !def:C_integer(o,1L) then
      runerr(0)

   abstract {
      return integer
      }

   inline {
      /*
       * Pass the C string to the system() function and return
       * the exit code of the command as the result of system().
       * Note, the expression on a "return" may not have side effects,
       * so the exit code must be returned via a variable.
       */
      C_integer i, j;
      char *cmdname;
      char *args[256];

#ifdef Graphics
      pollctr >>= 1;
      pollctr++;
#endif					/* Graphics */

#if NT
      if (o == 0)   { /* nowait, or 0, for second argument */
         cmdname = strtok(s, " ");
         for(j = 0; j<256; j++)
            if ((args[j] = strtok(NULL, " ")) == NULL)
	       break;
	 args[j] = NULL;
         _flushall();
         i = (C_integer)_spawnvp(_P_NOWAITO, cmdname, args);
      }
      else
	 i = mswinsystem(s);
#else					/*NT*/
      i = (C_integer)system(s);
#endif					/*NT*/

      return C_integer i;
      }
end
#endif					/* PosixFns */


"where(f) - return current offset position in file f."

function{0,1} where(f)

   if !is:file(f) then
      runerr(105,f)

   abstract {
      return integer
      }

   body {
      FILE *fd;
      long ftell();
      long pos;
      CURTSTATE();

      fd = BlkD(f,File)->fd.fp;

      if (BlkLoc(f)->File.status == 0)
	 fail;

#ifdef ReadDirectory
      if ((BlkLoc(f)->File.status & Fs_Directory) != 0)
         fail;
#endif					/* ReadDirectory */

#ifdef Graphics
      pollctr >>= 1;
      pollctr++;
      if (BlkLoc(f)->File.status & Fs_Window)
	 fail;
#endif					/* Graphics */

      pos = ftell(fd) + 1;
      if (pos == 0)
	 fail;	/* may only be effective on ANSI systems */

      return C_integer pos;
      }
end

/*
 * stop(), write(), and writes() differ in whether they stop the program
 *  and whether they output newlines. The macro GenWrite is used to
 *  produce all three functions.
 */
#define False 0
#define True 1

#begdef DefaultFile(error_out)
   inline {
#if error_out
#ifdef Concurrent
	 fblk = &k_errout;
         MUTEX_LOCKID_CONTROLLED(fblk->mutexid);
#endif					/* Concurrent */

      if ((k_errout.status & Fs_Write) == 0){
	 MUTEX_UNLOCKID(fblk->mutexid);
	 runerr(213);
	 }
      else {
#ifndef ConsoleWindow
	 f.fp = k_errout.fd.fp;
#else					/* ConsoleWindow */
         f.fp=(ConsoleFlags & StdErrRedirect) ? k_errout.fd.fp : OpenConsole();
#endif					/* ConsoleWindow */
	 }
#else					/* error_out */
#ifdef Concurrent
	 fblk = &k_output;
         MUTEX_LOCKID_CONTROLLED(fblk->mutexid);
#endif					/* Concurrent */
      if ((k_output.status & Fs_Write) == 0){
	 MUTEX_UNLOCKID(fblk->mutexid);
	 runerr(213);
	 }
      else {
#ifndef ConsoleWindow
	 f.fp = k_output.fd.fp;
#else					/* ConsoleWindow */
         f.fp=(ConsoleFlags & StdOutRedirect) ? k_output.fd.fp : OpenConsole();
#endif					/* ConsoleWindow */
	 }
#endif					/* error_out */
      }
#enddef					/* DefaultFile */

#begdef Finish(retvalue, nl, terminate)
#if nl
   /*
    * Append a newline to the file.
    */
#ifdef Graphics
   pollctr >>= 1;
   pollctr++;
   if (status & Fs_Window)
      wputc('\n', f.wb);
   else
#endif					/* Graphics */

#ifdef PseudoPty
		     if (status & Fs_Pty) {
			ptputc('\n', f.pt);
			}
		     else
#endif					/* PseudoPty */

#if HAVE_LIBZ
   if (status & Fs_Compress) {
      if (gzputc((gzFile)(f.fp),'\n')==-1)
          runerr(214);
      }
   else
#endif					/* HAVE_LIBZ */

#ifdef RecordIO
      if (!(status & Fs_Record)) {
#endif					/* RecordIO */
#ifdef Messaging
      if (status & Fs_Messaging) {
	 struct MFile *mf = f.mf;
	 extern int Merror;
	 if (!MFIN(mf, WRITING)){
	    MUTEX_UNLOCKID(fblk->mutexid);
	    runerr(213);
	    }
	 if (tp_write(mf->tp, "\n", 1) < 0) {
	 MUTEX_UNLOCKID(fblk->mutexid);
#if terminate
	    syserr("tp_write failed in stop()");
#else
	    fail;
#endif
	    }
	 if (Merror != 0) {
	    MUTEX_UNLOCKID(fblk->mutexid);
	    runerr(Merror);
	    }
	 }
      else
#endif                                  /* Messaging */
#ifdef PosixFns
      if (status & Fs_Socket) {
	 if (sock_write(f.fd, "\n", 1) < 0){
	    MUTEX_UNLOCKID(fblk->mutexid);
#if terminate
	    syserr("sock_write failed in stop()");
#else
	    fail;
#endif
	  }
         }
      else
#endif					/* PosixFns */
	 putc('\n', f.fp);

#ifdef RecordIO
      }
#endif					/* RecordIO */
#endif					/* nl */

   /*
    * Flush the file.
    */
#ifdef Messaging
   if (!(status & Fs_Messaging)) {
#endif					/* Messaging */
#ifdef Graphics
   if (!(status & Fs_Window)) {
#endif					/* Graphics */
#ifdef PseudoPty
   if (!(status & Fs_Pty)) {
#endif
#ifdef RecordIO
      if (status & Fs_Record)
	 flushrec(f.fp);
#endif					/* RecordIO */

#ifdef PosixFns
      if (!(status & Fs_Socket)) {
#endif					/* PosixFns */

#if HAVE_LIBZ
      if (status & (Fs_Compress
		    )) {

       /*if (ferror(f)){
	    MUTEX_UNLOCKID(fblk->mutexid);
	    runerr(214);
	    }
         gzflush(f, Z_SYNC_FLUSH);  */
         }
      else{
         if (ferror(f.fp)){
	    MUTEX_UNLOCKID(fblk->mutexid);
	    runerr(214);
	    }
         fflush(f.fp);
      }
#else					/* HAVE_LIBZ */
         if (ferror(f.fp)){
	    MUTEX_UNLOCKID(fblk->mutexid);
	    runerr(214);
	    }
         fflush(f.fp);
      
#endif					/* HAVE_LIBZ */

#ifdef PosixFns
      }
#endif					/* PosixFns */

#ifdef Graphics
      }
#ifdef PresentationManager
    /* must be writing to a window, then, if it is not the console,
       we have to set the background mix mode of the character bundle
       back to LEAVEALONE so the background is no longer clobbered */
    else if (f != ConsoleBinding) {
      /* have to set the background mode back to leave-alone */
      ((wbp)f)->context->charBundle.usBackMixMode = BM_LEAVEALONE;
      /* force the reload on next use */
      ((wbp)f)->window->charContext = NULL;
      } /* End of else if - not the console window we're writing to */
#endif					/* PresentationManager */
#endif					/* Graphics */
#ifdef PseudoPty
   }
#endif					/* PseudoPty */
#ifdef Messaging
   }
#endif					/* Messaging */
	    MUTEX_UNLOCKID(fblk->mutexid);
#if terminate
	    c_exit(EXIT_FAILURE);
#if !COMPILER
            return retvalue;            /* avoid spurious warning message */
#endif					/* except on the COMPILER... */
#else					/* terminate */
	    return retvalue;
#endif					/* terminate */
#enddef					/* Finish */

#begdef GenWrite(name, nl, terminate)

#name "(a,b,...) - write arguments"
#if !nl
   " without newline terminator"
#endif					/* nl */
#if terminate
   " (starting on error output) and stop"
#endif					/* terminate */
"."

#if terminate
function {} name(x[nargs])
#else					/* terminate */
function {1} name(x[nargs])
#endif					/* terminate */

   declare {
      union f f;
#ifdef Concurrent
      tended struct b_file *fblk = NULL;
#endif					/* terminate */
      word status =
#if terminate
#ifndef ConsoleWindow
	k_errout.status;
#else					/* ConsoleWindow */
        (ConsoleFlags & StdErrRedirect) ? k_errout.status : Fs_Read | Fs_Write | Fs_Window;
#endif					/* ConsoleWindow */
#else					/* terminate */
#ifndef ConsoleWindow
	k_output.status;
#else					/* ConsoleWindow */
        (ConsoleFlags & StdOutRedirect) ? k_output.status : Fs_Read | Fs_Write | Fs_Window;
#endif					/* ConsoleWindow */
#endif					/* terminate */

#ifdef BadCode
      struct descrip temp;
#endif					/* BadCode */
      }

#if terminate
   abstract {
      return empty_type
      }
#endif					/* terminate */

   len_case nargs of {
      0: {
#if !terminate
	 abstract {
	    return null
	    }
#endif					/* terminate */
	 DefaultFile(terminate)
	 body {
	    Finish(nulldesc, nl, terminate)
	    }
	 }

      default: {
#if !terminate
	 abstract {
	    return type(x)
	    }
#endif					/* terminate */
	 /*
	  * See if we need to start with the default file.
	  */
	 if !is:file(x[0]) then
	    DefaultFile(terminate)

	 body {
	    tended struct descrip t;
	    register word n;

	    /*
	     * Loop through the arguments.
	     */
	    for (n = 0; n < nargs; n++) {
	       if (is:file(x[n])) {	/* Current argument is a file */

#if nl
		  /*
		   * If this is not the first argument, output a newline to the
		   * current file and flush it.
		   */
		  if (n > 0) {

		     /*
		      * Append a newline to the file and flush it.
		      */
#ifdef Graphics
		     pollctr >>= 1;
		     pollctr++;
		     if (status & Fs_Window) {
			wputc('\n', f.wb);
			wflush(f.wb);
			}
		     else {
#endif					/* Graphics */

#ifdef PseudoPty
		     if (status & Fs_Pty) {
			ptputc('\n', f.pt);
			}
		     else
#endif					/* PseudoPty */

#if HAVE_LIBZ
                     if (status & Fs_Compress) {
			if (gzputc(f.fp,'\n')==-1){
#ifdef Concurrent 
			   if (fblk)
			   MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
                           runerr(214);
			   }
/*			gzflush(f.fp,4); */
			  }
		     else {
                          }
#endif					/* HAVE_LIBZ */


#ifdef RecordIO
			if (status & Fs_Record)
			   flushrec(f.fp);
			else
#endif					/* RecordIO */
#ifdef Messaging
                        if (status & Fs_Messaging) {
			   struct MFile *mf = f.mf;
			   extern int Merror;
			   if (!MFIN(mf, WRITING)) {
#ifdef Concurrent 
			      if (fblk)
			      MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
			      runerr(213);
			      }
			   if (tp_write(mf->tp, "\n", 1) < 0) {
#ifdef Concurrent 
			      if (fblk)
			      MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
#if terminate
			      syserr("tp_write failed in stop()");
#else
			      fail;
#endif
			      }
			   if (Merror != 0) {
#ifdef Concurrent 
			      if (fblk)
		    	      MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
			      runerr(Merror, x[n]);
			      }
			   }
			else
#endif                                  /* Messaging */
#ifdef PosixFns
			if (status & Fs_Socket) {
			   if (sock_write(f.fd, "\n", 1) < 0){
#ifdef Concurrent 
			      if (fblk)
			      MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
#if terminate
			      syserr("sock_write failed in stop()");
#else
			      fail;
#endif
			     }
			}
			else {
#endif					/* PosixFns */
			putc('\n', f.fp);
			if (ferror(f.fp)){
#ifdef Concurrent 
			   if (fblk)
	    		   MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
			   runerr(214);
			   }
			fflush(f.fp);
#ifdef PosixFns
                        }
#endif					/* PosixFns */
#ifdef Graphics
			}
#endif					/* Graphics */
#ifdef Concurrent 
		     if (fblk)
			MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
		     }
#endif					/* nl */

#ifdef PresentationManager
                 /* have to put the background mix back on the current file */
                 if (f != NULL && (status & Fs_Window) && f != ConsoleBinding) {
                   /* set the background back to leave-alone */
                   ((wbp)f)->context->charBundle.usBackMixMode = BM_LEAVEALONE;
                   /* unload the context from this window */
                   ((wbp)f)->window->charContext = NULL;
                   }
#endif					/* PresentationManager */

		  /*
		   * Switch the current file to the file named by the current
		   * argument providing it is a file.
		   */
		  status = BlkD(x[n],File)->status;
		  if ((status & Fs_Write) == 0){
#ifdef Concurrent 
		     if (fblk)
	    	     MUTEX_UNLOCKID(fblk->mutexid);
#endif					/* Concurrent */
		     runerr(213, x[n]);
		     }
		  f.fp = BlkLoc(x[n])->File.fd.fp;
#ifdef Concurrent 
		  fblk = BlkD(x[n], File);
        	  MUTEX_LOCKID_CONTROLLED(fblk->mutexid);
#endif					/* Concurrent */

#ifdef ConsoleWindow
                  if ((f.fp == stdout && !(ConsoleFlags & StdOutRedirect)) ||
                      (f.fp == stderr && !(ConsoleFlags & StdErrRedirect))) {
                     f.fp = OpenConsole();
                     status = Fs_Read | Fs_Write | Fs_Window;
                     }
#endif					/* ConsoleWindow */
#ifdef PresentationManager
                  if (status & Fs_Window) {
                     /*
		      * have to set the background to overpaint - the one
                      * difference between DrawString and write(s)
		      */
                    f.wb->context->charBundle.usBackMixMode = BM_OVERPAINT;
                    /* unload the context from the window so it will be reloaded */
                    f.wb->window->charContext = NULL;
                    }
#endif					/* PresentationManager */
		  }
	       else {
		  /*
		   * Convert the argument to a string, defaulting to a empty
		   *  string.
		   */
		  if (!def:tmp_string(x[n],emptystr,t)){
	    	     MUTEX_UNLOCKID(fblk->mutexid);
		     runerr(109, x[n]);
		     }

		  /*
		   * Output the string.
		   */
#ifdef Graphics
		  if (status & Fs_Window)
		     wputstr(f.wb, StrLoc(t), StrLen(t));
		  else
#endif					/* Graphics */

#ifdef PseudoPty
		  if (status & Fs_Pty)
		     ptputstr(f.pt, StrLoc(t), StrLen(t));
		  else
#endif

#if HAVE_LIBZ
	          if (status & Fs_Compress){
                     if (gzputs(f.fp, StrLoc(t))==-1){
	    	     	MUTEX_UNLOCKID(fblk->mutexid); 
			runerr(214);
			}
                     }
		  else
#endif					/* HAVE_LIBZ */


#ifdef RecordIO
		     if ((status & Fs_Record ? putrec(f.fp, &t) :
					     putstr(f.fp, &t)) == Failed)
#else					/* RecordIO */
#ifdef Messaging
                     if (status & Fs_Messaging) {
			struct MFile *mf = f.mf;
			extern int Merror;
			Merror = 0;
			tp_write(mf->tp, StrLoc(t), StrLen(t));
			if (Merror > 1200) {
	    		   MUTEX_UNLOCKID(fblk->mutexid);
			   runerr(Merror);
			   }
			}
		     else
#endif                                  /* Messaging */

#ifdef PosixFns
		     if (status & Fs_Socket) {

			if (sock_write(f.fd, StrLoc(t), StrLen(t)) < 0) {
        	  	   MUTEX_UNLOCKID(fblk->mutexid);
#if terminate
			   syserr("sock_write failed in stop()");
#else
			   fail;
#endif
			   }
		     } else {
#endif					/* PosixFns */
		     if (putstr(f.fp, &t) == Failed)
#endif					/* RecordIO */
			{
	    		MUTEX_UNLOCKID(fblk->mutexid);
			runerr(214, x[n]);
			}
#ifdef PosixFns
			}
#endif
		  }
	       }

	    Finish(x[n-1], nl, terminate)
	    }
	 }
      }
end
#enddef					/* GenWrite */

GenWrite(stop,	 True,	True)  /* stop(s, ...) - write message and stop */
GenWrite(write,  True,	False) /* write(s, ...) - write with new-line */
GenWrite(writes, False, False) /* writes(s, ...) - write with no new-line */

#ifdef KeyboardFncs

"getch() - return a character from console."

function{0,1} getch()
   abstract {
      return string;
      }
   body {
      int i;
#ifndef ConsoleWindow
      i = getch();
#else					/* ConsoleWindow */
      struct descrip res;
      if (wgetchne((wbp)OpenConsole(), &res) < 0) fail;
      i = *StrLoc(res);
#endif					/* ConsoleWindow */
      if (i<0 || i>255)
	 fail;
      return string(1, (char *)&allchars[FromAscii(i) & 0xFF]);
      }
end

"getche() -- return a character from console with echo."

function{0,1} getche()
   abstract {
      return string;
      }
   body {
      int i;
#ifndef ConsoleWindow
      i = getche();
#else					/* ConsoleWindow */
      struct descrip res;
      if (wgetche((wbp)OpenConsole(), &res) < 0) fail;
      i = *StrLoc(res);
#endif					/* ConsoleWindow */
      if (i<0 || i>255)
	 fail;
      return string(1, (char *)&allchars[FromAscii(i) & 0xFF]);
      }
end


"kbhit() -- Check to see if there is a keyboard character waiting to be read."

function{0,1} kbhit()
   abstract {
      return null
      }
   inline {
      int rv;
#ifndef ConsoleWindow
      if (kbhit())
	 return nulldesc;
      else fail;
#else					/* ConsoleWindow */
     /* make sure we're up-to-date event wise */
     if (ConsoleBinding) {
        pollevent();
        /*
	 * perhaps should look in the console's icon event list for a keypress;
	 *  either a string or event > 60k; presently, succeed for all events
	 */
        if (BlkD(((wbp)ConsoleBinding)->window->listp,List)->size > 0)
	   return nulldesc;
        }
     fail;
#endif					/* ConsoleWindow */
      }
end
#endif					/* KeyboardFncs */

"chdir(s) - change working directory to s."
function{0,1} chdir(s)
   if !cnv:string(s) then
       if !is:null(s) then
	  runerr(103, s)
   abstract {
      return string
   }
   body {
#if NT
#ifndef NTGCC
#define chdir nt_chdir
#passthru #include <direct.h>
#endif
#endif

#if PORT
   Deliberate Syntax Error
#endif                                  /* PORT */
#if ARM || MACINTOSH || MVS || VM
      runerr(121);
#endif                                  /* ARM || MACINTOSH ... */
#if AMIGA || MSDOS || OS2 || UNIX || VMS || NT

      char path[PATH_MAX];
      int len;

      if (is:string(s)) {
	 tended char *dir;
	 cnv:C_string(s, dir);
	 if (chdir(dir) != 0)
	    fail;
	 }
#ifndef PATH_MAX
#define PATH_MAX 512
#endif					/* PATH_MAX */
      if (getcwd(path, PATH_MAX) == NULL)
	  fail;

      len = strlen(path);
      Protect(StrLoc(result) = alcstr(path, len), runerr(0));
      StrLen(result) = len;
      return result;

#endif
   }
end

#if NT
#ifdef MSWindows
#ifdef NTGCC
/*
 * gcc has a getenv() but it doesn't work as well as GetEnvironmentVariable.
 * As of Visual Studio 12, cl wants to use a getenv from LIBCMT.lib.
 */
char *getenv(const char *s)
{
static char tmp[1537];
DWORD rv;
rv = GetEnvironmentVariable(s, tmp, 1536);
if (rv > 0) return tmp;
return NULL;
}
#endif					/* NTGCC */
#endif					/* MSWindows */

#ifndef NTGCC
#undef chdir
int nt_chdir(char *s)
{
    return chdir(s);
}
#endif
#endif					/* NT */

"delay(i) - delay for i milliseconds."

function{0,1} delay(n)

   if !cnv:C_integer(n) then
      runerr(101,n)
   abstract {
      return null
      }

   inline {
      if (idelay(n) == Failed)
        fail;
#ifdef Graphics
{
      CURTSTATE();
      pollctr >>= 1;
      pollctr++;
}
#endif					/* Graphics */
      return nulldesc;
      }
end

"flush(f) - flush file f."

function{1} flush(f)
   if !is:file(f) then
      runerr(105, f)
   abstract {
      return type(f)
      }

   body {
      FILE *fp = BlkD(f,File)->fd.fp;
      int status = BlkD(f,File)->status;
      CURTSTATE();

      /*
       * File types for which no flushing is possible, or is a no-op.
       */
      if (((status & (Fs_Read | Fs_Write)) == 0)	/* if already closed */
#ifdef ReadDirectory
	  || (status & Fs_Directory)
#endif					/* ReadDirectory */
#ifdef PosixFns
	  || (status & Fs_Socket)
#endif					/* PosixFns */
	  )
	 return f;

#ifdef Graphics
      pollctr >>= 1;
      pollctr++;

      if (status & Fs_Window)
	 wflush((wbp)fp);
      else
#endif					/* Graphics */
	 fflush(fp);

      /*
       * Return the flushed file.
       */
      return f;
      }
end