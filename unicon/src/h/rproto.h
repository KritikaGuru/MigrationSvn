/*
 * Prototypes for run-time functions.
 */

/*
 * Prototypes common to the compiler and interpreter.
 */
void		EVInit		(void);
int		activate	(dptr val, struct b_coexpr *ncp, dptr result);
word		add		(word a,word b);
void		addmem 	(struct b_set *ps,struct b_selem *pe, union block **pl);
struct astkblk	*alcactiv	(void);
#ifdef MultiThread
struct b_cset	*alccset_0	(void);
struct b_cset	*alccset_1	(void);
struct b_file	*alcfile_0	(FILE *fd,int status,dptr name);
struct b_file	*alcfile_1	(FILE *fd,int status,dptr name);
union block	*alchash_0	(int tcode);
union block	*alchash_1	(int tcode);
struct b_slots	*alcsegment_0	(word nslots);
struct b_slots	*alcsegment_1	(word nslots);
struct b_list	*alclist_raw_0	(uword size, uword nslots);
struct b_list	*alclist_raw_1	(uword size, uword nslots);
struct b_list	*alclist_0	(uword size, uword nslots);
struct b_list	*alclist_1	(uword size, uword nslots);
struct b_lelem	*alclstb_0	(uword nslots,uword first,uword nused);
struct b_lelem	*alclstb_1	(uword nslots,uword first,uword nused);
struct b_real	*alcreal_0	(double val);
struct b_real	*alcreal_1	(double val);
struct b_selem	*alcselem_0	(dptr mbr,uword hn);
struct b_selem	*alcselem_1	(dptr mbr,uword hn);
char		*alcstr_0	(char	*s,word slen);
char		*alcstr_1	(char	*s,word slen);
struct b_telem	*alctelem_0	(void);
struct b_telem	*alctelem_1	(void);
struct b_tvtbl	*alctvtbl_0	(dptr tbl,dptr ref,uword hashnum);
struct b_tvtbl	*alctvtbl_1	(dptr tbl,dptr ref,uword hashnum);
struct b_tvmonitored  *alctvmonitored	(dptr tv, word ipc);
void assign_event_functions(struct progstate *p, struct descrip cs);
int invaluemask(struct progstate *p, int evcode, struct descrip *val);
#ifdef PatternType
struct b_pattern	*alcpattern_0 (word size);
struct b_pattern	*alcpattern_1 (word size);
struct b_pelem	*alcpelem_0	(word pattern_code);
struct b_pelem	*alcpelem_1	(word pattern_code);
#endif					/* PatternType */
#else					/* MultiThread */
struct b_cset	*alccset	(void);
struct b_file	*alcfile	(FILE *fd,int status,dptr name);
union block	*alchash	(int tcode);
struct b_slots	*alcsegment	(word nslots);
struct b_list	*alclist_raw	(uword size, uword nslots);
struct b_list	*alclist	(uword size, uword nslots);
struct b_lelem	*alclstb	(uword nslots,uword first,uword nused);
struct b_real	*alcreal	(double val);
struct b_selem	*alcselem	(dptr mbr,uword hn);
char		*alcstr		(char	*s,word slen);
struct b_telem	*alctelem	(void);
struct b_tvtbl	*alctvtbl	(dptr tbl,dptr ref,uword hashnum);
#ifdef PatternType
struct b_pattern	*alcpattern	(word size);
struct b_pelem	*alcpelem(word pattern_code);
#endif					/* PatternType */
#endif					/* MultiThread */
int		anycmp		(dptr dp1,dptr dp2);
int		bfunc		(void);
struct b_proc	*bi_strprc	(dptr s, C_integer arity);
void		c_exit		(int i);
int		c_get		(struct b_list *hp, struct descrip *res);
void		c_put		(struct descrip *l, struct descrip *val);
int		CmdParamToArgv	(char *s, char ***avp, int dequote);
int		cnv_c_dbl	(dptr s, double *d);
int		cnv_c_int	(dptr s, C_integer *d);
int		cnv_c_str	(dptr s, dptr d);
#ifdef MultiThread
int		cnv_cset_0	(dptr s, dptr d);
int		cnv_cset_1	(dptr s, dptr d);
#else
int		cnv_cset	(dptr s, dptr d);
#endif					/* MultiThread */
int		cnv_ec_int	(dptr s, C_integer *d);
int		cnv_eint	(dptr s, dptr d);
#ifdef MultiThread
int		cnv_int_0	(dptr s, dptr d);
int		cnv_int_1	(dptr s, dptr d);
int		cnv_real_0	(dptr s, dptr d);
int		cnv_real_1	(dptr s, dptr d);
int		cnv_str_0	(dptr s, dptr d);
int		cnv_str_1	(dptr s, dptr d);
int		cnv_tcset_0	(struct b_cset *cbuf, dptr s, dptr d);
int		cnv_tcset_1	(struct b_cset *cbuf, dptr s, dptr d);
int		cnv_tstr_0	(char *sbuf, dptr s, dptr d);
int		cnv_tstr_1	(char *sbuf, dptr s, dptr d);
#else					/* MultiThread */
int		cnv_int		(dptr s, dptr d);
int		cnv_real	(dptr s, dptr d);
int		cnv_str		(dptr s, dptr d);
int		cnv_tcset	(struct b_cset *cbuf, dptr s, dptr d);
int		cnv_tstr	(char *sbuf, dptr s, dptr d);
#endif					/* MultiThread */
int		co_chng		(struct b_coexpr *ncp, struct descrip *valloc,
				   struct descrip *rsltloc,
				   int swtch_typ, int first);
void		co_init		(struct b_coexpr *sblkp);
void		coacttrace	(struct b_coexpr *ccp,struct b_coexpr *ncp);
void		cofailtrace	(struct b_coexpr *ccp,struct b_coexpr *ncp);
void		corettrace	(struct b_coexpr *ccp,struct b_coexpr *ncp);
int		coswitch	(word *old, word *new, int first);
int		cphash		(dptr dp1, dptr dp2, word n, int tcode);
#ifdef MultiThread
int		cplist_0	(dptr dp1,dptr dp2,word i,word j);
int		cplist_1	(dptr dp1,dptr dp2,word i,word j);
int		cpset_0		(dptr dp1,dptr dp2,word size);
int		cpset_1		(dptr dp1,dptr dp2,word size);
int		cptable_0	(dptr dp1,dptr dp2,word size);
int		cptable_1	(dptr dp1,dptr dp2,word size);
void		EVStrAlc_0	(word n);
void		EVStrAlc_1	(word n);
#else					/* MultiThread */
int		cplist		(dptr dp1,dptr dp2,word i,word j);
int		cpset		(dptr dp1,dptr dp2,word size);
int		cptable		(dptr dp1,dptr dp2,word size);
#endif					/* MultiThread */
void		cpslots		(dptr dp1,dptr slotptr,word i, word j);
int		csetcmp		(unsigned int *cs1,unsigned int *cs2);
int		cssize		(dptr dp);
word		cvpos		(long pos,long len);
void		datainit	(void);
#ifdef MultiThread
void		deallocate_0	(union block *bp);
void		deallocate_1	(union block *bp);
#else					/* MultiThread */
void		deallocate	(union block *bp);
#endif					/* MultiThread */
int		def_c_dbl	(dptr s, double df, double * d);
int		def_c_int	(dptr s, C_integer df, C_integer * d);
int		def_c_str	(dptr s, char * df, dptr d);
int		def_cset	(dptr s, struct b_cset * df, dptr d);
int		def_ec_int	(dptr s, C_integer df, C_integer * d);
int		def_eint	(dptr s, C_integer df, dptr d);
int		def_int		(dptr s, C_integer df, dptr d);
int		def_real	(dptr s, double df, dptr d);
int		def_str		(dptr s, dptr df, dptr d);
int		def_tcset (struct b_cset *cbuf,dptr s,struct b_cset *df,dptr d);
int		def_tstr	(char *sbuf, dptr s, dptr df, dptr d);
word		div3		(word a,word b);
int		doasgn		(dptr dp1,dptr dp2);
int		doimage		(int c,int q);
int		dp_pnmcmp	(struct pstrnm *pne,dptr dp);
void		drunerr		(int n, double v);
void		dumpact		(struct b_coexpr *ce);
struct b_proc * dynrecord	(dptr s, dptr fields, int n);
void		env_int	(char *name,word *variable,int non_neg, uword limit);
int		equiv		(dptr dp1,dptr dp2);
int		err		(void);
void		err_msg		(int n, dptr v);
void		error		(char *s1, char *s2);
void		fatalerr	(int n,dptr v);
int		findcol		(word *ipc);
char		*findfile	(word *ipc);
int		findipc		(int line);
word		* findoldipc	(struct b_coexpr *ce, int level);
int		findline	(word *ipc);
int		findloc		(word *ipc);
int		findsyntax	(word *ipc);
void		fpetrap		(void);
int		getvar		(char *s,dptr vp);
uword		hash		(dptr dp);
union block	**hchain	(union block *pb,uword hn);
union block	*hgfirst	(union block *bp, struct hgstate *state);
union block	*hgnext		(union block*b,struct hgstate*s,union block *e);
int		hitsyntax	(word *ipc);
union block	*hmake		(int tcode,word nslots,word nelem);
void		icon_init	(char *name, int *argcp, char *argv[]);
void		iconhost	(char *hostname);
int		idelay		(int n);
#ifdef MultiThread
int		interp_0	(int fsig,dptr cargp);
int		interp_1	(int fsig,dptr cargp);
#else
int		interp		(int fsig,dptr cargp);
#endif
void		inttrap		(void);
void		irunerr		(int n, C_integer v);
int		iselect		(int fd, int t);
int		lexcmp		(dptr dp1,dptr dp2);
word		longread	(char *s,int width,long len,FILE *fname);
#if HAVE_LIBZ
word		gzlongread	(char *s,int width,long len,FILE *fd);
#endif					/* HAVE_LIBZ */
#ifdef FAttrib
#if UNIX
char *  make_mode		(mode_t st_mode);
#endif					/* UNIX */
#if MSDOS
char *  make_mode		(unsigned short st_mode);
#ifndef NTGCC
int	strcasecmp		(char *s1, char *s2);
int	strncasecmp		(char *s1, char *s2, int n);
#endif					/* NTGCC */
#endif					/* MSDOS */
#endif					/* FAttrib */
union block	**memb		(union block *pb,dptr x,uword hn, int *res);
void		mksubs		(dptr var,dptr val,word i,word j, dptr result);
word		mod3		(word a,word b);
word		mul		(word a,word b);
word		neg		(word a);
void		new_context	(int fsig, dptr cargp); /* w/o CoExpr: a stub*/
int		numcmp		(dptr dp1,dptr dp2,dptr dp3);
void		outimage	(FILE *f,dptr dp,int noimage);
struct b_coexpr	*popact		(struct b_coexpr *ce);
long physicalmemorysize();
word		prescan		(dptr d);
int		pstrnmcmp	(struct pstrnm *a,struct pstrnm *b);
#ifdef PseudoPty
void ptclose(struct ptstruct *ptStruct);
struct ptstruct *ptopen(char *command);
int ptgetstrt(char *buffer, const int bufsiz, struct ptstruct *ptStruct,
	      unsigned long waittime, int longread);
int ptgetstr(char *buffer, const int bufsiz, struct ptstruct *ptStruct,
	     struct timeval *timeout);
int ptlongread(char *buffer, const int nelem, struct ptstruct *ptStruct);
int ptputstr(struct ptstruct *ptStruct, char *buffer, int bufsize);
int ptputc(const char c, struct ptstruct *ptStruct);
int ptflush(struct ptstruct *ptStruct);
#endif                                        /* PseudoPty */
int		pushact		(struct b_coexpr *ce, struct b_coexpr *actvtr);
int		putstr		(FILE *f,dptr d);
char		*qsearch	(char *key, char *base, int nel, int width,
				   int (*cmp)());
int		qtos		(dptr dp,char *sbuf);
int    		 radix		(int sign, register int r, register char *s,
				 register char *end_s, union numeric *result);
#ifdef MultiThread
char		*reserve_0	(int region, word nbytes);
char		*reserve_1	(int region, word nbytes);
#else					/* MultiThread */
char		*reserve	(int region, word nbytes);
#endif					/* MultiThread */
void		retderef		(dptr valp, word *low, word *high);
void		segvtrap	(void);
void		stkdump		(int);
word		sub		(word a,word b);
void		syserr		(char *s);
struct b_coexpr	*topact		(struct b_coexpr *ce);
void		xmfree		(void);

#ifdef MultiThread
   void	resolve			(struct progstate *pstate);
   struct progstate *findicode	(word *opnd);
   struct b_coexpr *loadicode	(char *name, struct b_file *theInput,
      struct b_file *theOutput, struct b_file *theError,
      C_integer bs, C_integer ss, C_integer stk);
   void actparent (int eventcode);
   void mmrefresh		(void);
   int mt_activate   (dptr tvalp, dptr rslt, struct b_coexpr *ncp);
   struct progstate *findprogramforblock(union block *p);
   void EVVariable(dptr dx, int eventcode);
#else					/* MultiThread */
   void	resolve			(void);
#endif					/* MultiThread */

#ifdef ExternalFunctions
   dptr	extcall			(dptr x, int nargs, int *signal);
#endif					/* ExternalFunctions */

#ifdef LargeInts
#ifdef MultiThread
   struct b_bignum *alcbignum_0	(word n);
   struct b_bignum *alcbignum_1	(word n);
#else					/* MultiThread */
   struct b_bignum *alcbignum	(word n);
#endif					/* MultiThread */
   word		bigradix	(int sign, int r, char *s, char *x,
						   union numeric *result);
   double	bigtoreal	(dptr da);
   int		realtobig	(dptr da, dptr dx);
   int		bigtos		(dptr da, dptr dx);
   void		bigprint	(FILE *f, dptr da);
   int		cpbignum	(dptr da, dptr db);
   int		bigadd		(dptr da, dptr db, dptr dx);
   int		bigsub		(dptr da, dptr db, dptr dx);
   int		bigmul		(dptr da, dptr db, dptr dx);
   int		bigdiv		(dptr da, dptr db, dptr dx);
   int		bigmod		(dptr da, dptr db, dptr dx);
   int		bigneg		(dptr da, dptr dx);
   int		bigpow		(dptr da, dptr db, dptr dx);
   int		bigpowri        (double a, dptr db, dptr drslt);
   int		bigand		(dptr da, dptr db, dptr dx);
   int		bigor		(dptr da, dptr db, dptr dx);
   int		bigxor		(dptr da, dptr db, dptr dx);
   int		bigshift	(dptr da, dptr db, dptr dx);
   word		bigcmp		(dptr da, dptr db);
   int		bigrand		(dptr da, dptr dx);
#endif					/* LargeInts */



#if !HIGHC_386
   int dup2(int h1, int h2);
#endif					/* !HIGHC_386 */

#if ATARI_ST
   char	*sbrk(int incr);
#endif                                  /* ATARI_ST */

#if HIGHC_386
   int	brk(char *p);
#endif					/* HIGHC_386 */

#if MACINTOSH
   #if MPW
      char *brk(char *addr);
      char *sbrk(int incr);
   #endif				/* MPW */
#endif					/* MACINTOSH */

#if MVS || VM
   #if SASC
      #define brk(x) sbrk(((char *)(x))-sbrk(0))
      char *sbrk(int incr);
   #endif				/* SASC */
#endif                                  /* MVS || VM */

#ifdef MSWindows
#ifdef ConsoleWindow
void detectRedirection();
#endif
   #ifdef FAttrib
      #if MSDOS
         char *make_mode(unsigned short st_mode);
#ifndef NTGCC
         int strcasecmp(char *s1, char *s2);
         int strncasecmp(char *s1, char *s2, int n);
#endif					/* NTGCC */
      #endif				/* MSDOS */
   #endif				/* FAttrib */
#endif					/* MSWindows */

#if defined(Graphics) || defined(PosixFns)
   struct b_list *findactivewindow(struct b_list *);
   char	*si_i2s		(siptr sip, int i);
   int	si_s2i		(siptr sip, char *s);
#endif					/* Graphics || PosixFns */

#ifdef Graphics
   /*
    * portable graphics routines in rwindow.r and rwinrsc.r
    */
   wcp	alc_context	(wbp w);
   wbp	alc_wbinding	(void);
   wsp	alc_winstate	(void);
   int	atobool		(char *s);
   void	c_push		(dptr l,dptr val);  /* in fstruct.r */
   int	docircles	(wbp w, int argc, dptr argv, int fill);
   void	drawCurve	(wbp w, XPoint *p, int n);
   char	*evquesub	(wbp w, int i);
   void	genCurve	(wbp w, XPoint *p, int n, void (*h)());
   wsp	getactivewindow	(void);
   int	getpattern	(wbp w, char *answer);
   char *getselection	(wbp w, char *buf);
   void gotorc		(wbp w,int r,int c);
   void gotoxy		(wbp w, int x, int y);
   struct palentry *palsetup(int p);
   int	palnum		(dptr d);
   int	parsecolor	(wbp w, char *s, long *r, long *g, long *b, long *a);
   int	parsefont	(char *s, char *fam, int *sty, int *sz, int *tp);
   int	parsegeometry	(char *buf, SHORT *x, SHORT *y, SHORT *w, SHORT *h);
   int	parsepattern	(char *s, int len, int *w, int *nbits, C_integer *bits);
   void	qevent		(wsp ws, dptr e, int x, int y, uword t, long f);
   int readBMP		(char *filename, int p, struct imgdata *imd);
   int	readGIF		(char *fname, int p, struct imgdata *d);
#if HAVE_LIBJPEG
   int	readJPEG	(char *fname, int p, struct imgdata *d);
   int  writeJPEG	(wbp w, char *fn, int x, int y, int width, int height);
#endif					/* HAVE_LIBJPEG */
#if HAVE_LIBPNG
   int	readPNG		(char *fname, int p, struct imgdata *d);
#endif					/* HAVE_LIBPNG */
   int	rectargs	(wbp w, int argc, dptr argv, int i,
   			   word *px, word *py, word *pw, word *ph);
   char	*rgbkey		(int p, double r, double g, double b);

   int	setselection	(wbp w, dptr val);
   int	setsize		(wbp w, char *s);
   int	ulcmp		(pointer p1, pointer p2);
   int	wattrib		(wbp w, char *s, long len, dptr answer, char *abuf);
   int	wgetche		(wbp w, dptr res);
   int	wgetchne	(wbp w, dptr res);
   int	wgetevent	(wbp w, dptr res, int t);
   int	wgetstrg	(char *s, long maxlen, FILE *f);
   void	wgoto		(wbp w, int row, int col);
   int	wlongread	(char *s, int elsize, int nelem, FILE *f);
   void	wputstr		(wbp w, char *s, int len);
   int	writeGIF	(wbp w, char *filename,
   			  int x, int y, int width, int height);
   int	writeBMP	(wbp w, char *filename,
   			  int x, int y, int width, int height);
   int	xyrowcol	(dptr dx);

   /*
    * graphics implementation routines supplied for each platform
    * (excluding those defined as macros for X-windows)
    */
   int	SetPattern	(wbp w, char *name, int len);
   int	SetPatternBits	(wbp w, int width, C_integer *bits, int nbits);
   int	allowresize	(wbp w, int on);
   int	blimage		(wbp w, int x, int y, int wd, int h,
   			  int ch, unsigned char *s, word len);
   wcp	clone_context	(wbp w);
   int	copyArea	(wbp w,wbp w2,int x,int y,int wd,int h,int x2,int y2);
   int	do_config	(wbp w, int status);
   int	dumpimage	(wbp w, char *filename, unsigned int x, unsigned int y,
			   unsigned int width, unsigned int height);
   void	eraseArea	(wbp w, int x, int y, int width, int height);
   void	fillrectangles	(wbp w, XRectangle *recs, int nrecs);
   void	free_binding	(wbp w);
   void	free_context	(wcp wc);
   void	free_mutable	(wbp w, int mute_index);
   int	free_window	(wsp ws);
   void	freecolor	(wbp w, char *s);
   char	*get_mutable_name (wbp w, int mute_index);
   void	getbg		(wbp w, char *answer);
   void	getcanvas	(wbp w, char *s);
   int	getdefault	(wbp w, char *prog, char *opt, char *answer);
   void	getdisplay	(wbp w, char *answer);
   void	getdrawop	(wbp w, char *answer);
   void	getfg		(wbp w, char *answer);
   void	getfntnam	(wbp w, char *answer);
   void	geticonic	(wbp w, char *answer);
   int	geticonpos	(wbp w, char *s);
   int	getimstr	(wbp w, int x, int y, int width, int hgt,
   			  struct palentry *ptbl, unsigned char *data);
   int	getimstr24	(wbp w, int xx, int yy, int width, int hgt,
			  unsigned char *d);
   void	getlinestyle	(wbp w, char *answer);
   int	getpixel_init	(wbp w, struct imgmem *imem);
   int	getpixel_term	(wbp w, struct imgmem *imem);
   int	getpixel	(wbp w,int x,int y,long *rv,char *s,struct imgmem *im);
   void	getpointername	(wbp w, char *answer);
   int	getpos		(wbp w);
   int	getvisual	(wbp w, char *answer);
   int	isetbg		(wbp w, int bg);
   int	isetfg		(wbp w, int fg);
   int	lowerWindow	(wbp w);
   int	mutable_color	(wbp w, dptr argv, int ac, int *retval);
   char my_wmap         (wbp w);
   int	nativecolor	(wbp w, char *s, long *r, long *g, long *b);

   #ifndef PresentationManager
      /* Exclude those functions defined as macros */
      int pollevent	(void);
#ifndef MSWindows
      void wflush	(wbp w);
#endif
   #endif				/* PresentationManager */

   int	query_pointer	(wbp w, XPoint *pp);
   int	query_rootpointer (XPoint *pp);
   int	raiseWindow	(wbp w);
   int	readimage	(wbp w, char *filename, int x, int y, int *status);
   int	rebind		(wbp w, wbp w2);
   int	set_mutable	(wbp w, int i, char *s);
   int	setbg		(wbp w, char *s);
   int	setcanvas	(wbp w, char *s);
   void	setclip		(wbp w);
   int	setcursor	(wbp w, int on);
   int	setdisplay	(wbp w, char *s);
   int	setdrawop	(wbp w, char *val);
   int	setfg		(wbp w, char *s);
   int	setfillstyle	(wbp w, char *s);
   int	setfont		(wbp w, char **s);
   int	setgamma	(wbp w, double gamma);
   int	setgeometry	(wbp w, char *geo);
   int	setheight	(wbp w, SHORT new_height);
   int	seticonicstate	(wbp w, char *s);
   int	seticonlabel	(wbp w, char *val);
   int	seticonpos	(wbp w, char *s);
   int	setimage	(wbp w, char *val);
   int  setinputmask	(wbp w, char *val);
   int	setleading	(wbp w, int i);
   int	setlinestyle	(wbp w, char *s);
   int	setlinewidth	(wbp w, LONG linewid);
   int	setpointer	(wbp w, char *val);
   int	setwidth	(wbp w, SHORT new_width);
   int	setwindowlabel	(wbp w, char *val);
   int	strimage	(wbp w, int x, int y, int width, int height,
			   struct palentry *e, unsigned char *s,
			   word len, int on_icon);
   void	toggle_fgbg	(wbp w);
   int	walert		(wbp w, int volume);
   void	warpPointer	(wbp w, int x, int y);
   int	wclose		(wbp w);
#ifndef MSWindows
   void	wflush		(wbp w);
#endif
   int	wgetq		(wbp w, dptr res, int t);
   FILE	*wopen		(char *nm, struct b_list *hp, dptr attr, int n, int *e, int is_3d);
#ifdef Graphics3D
   FILE	*wopengl	(char *nm, struct b_list *hp, dptr attr, int n,int *e);
#endif					/* Graphics3D */
   int	wputc		(int ci, wbp w);
#ifndef MSWindows
   void	wsync		(wbp w);
#endif					/* MSWindows */
   void	xdis		(wbp w, char *s, int n);

   #ifdef ConsoleWindow
      FILE* OpenConsole		(void);
      int   Consolefprintf	(FILE *file, const char *format, ...);
      int   Consoleputc		(int c, FILE *file);
      int   Consolefflush	(FILE *file);
   #endif				/* ConsoleWindow */

   #ifdef MacGraph
      /*
       * Implementation routines specific to Macintosh
       */
      void hidecrsr (wsp ws);
      void showcrsr (wsp ws);
      void UpdateCursorPos(wsp ws, wcp wc);
      void GetEvents (void);
      void DoEvent (EventRecord *eventPtr);
      void DoMouseUp (EventRecord *eventPtr);
      void DoMouseDown (EventRecord *eventPtr);
      void DoGrowWindow (EventRecord *eventPtr, WindowPtr whichWindow);
      void GetLocUpdateRgn (WindowPtr whichWindow, RgnHandle localRgn);
      void DoKey (EventRecord *eventPtr, WindowPtr whichWindow);
      void EventLoop(void);
      void HandleMenuChoice (long menuChoice);
      void HandleAppleChoice (short item);
      void HandleFileChoice (short item);
      void HandleOptionsChoice (short item);
      void DoUpdate (EventRecord *eventPtr);
      void DoActivate (WindowPtr whichWindow, Boolean becomingActive);
      void RedrawWindow (WindowPtr whichWindow);
      const int ParseCmdLineStr (char *s, char *t, char **argv);
      pascal OSErr SetDialogDefaultItem (DialogPtr theDialog, short newItem) =
         { 0x303C, 0x0304, 0xAA68 };
      pascal OSErr SetDialogCancelItem (DialogPtr theDialog, short newItem) =
         { 0x303C, 0x0305, 0xAA68 };
      pascal OSErr SetDialogTracksCursor (DialogPtr theDialog, Boolean tracks) =
         { 0x303C, 0x0306, 0xAA68 };

      void drawarcs(wbinding *wb, XArc *arcs, int narcs);
      void drawlines(wbinding *wb, XPoint *points, int npoints);
      void drawpoints(wbinding *wb, XPoint *points, int npoints);
      void drawrectangles(wbp wb, XRectangle *recs, int nrecs);
      void drawsegments(wbinding *wb, XSegment *segs, int nsegs);
      void fillarcs(wbp wb, XArc *arcs, int narcs);
      void fillpolygon(wbp wb, XPoint *pts, int npts);
   #endif				/* MacGraph */

   #ifdef XWindows
      /*
       * Implementation routines specific to X-Windows
       */
      void	unsetclip		(wbp w);
      void	moveWindow		(wbp w, int x, int y);
      int	moveResizeWindow	(wbp w, int x, int y, int wd, int h);
      int	resetfg			(wbp w);
      int	setfgrgb		(wbp w, int r, int g, int b);
      int	setbgrgb		(wbp w, int r, int g, int b);

      XColor	xcolor			(wbp w, LinearColor clr);
      LinearColor	lcolor		(wbp w, XColor color);
      int	pixmap_open		(wbp w, dptr attribs, int argc);
      int	pixmap_init		(wbp w);
      int	remap			(wbp w, int x, int y);
      int	seticonimage		(wbp w, dptr dp);
      void	makeIcon		(wbp w, int x, int y);
      int	translate_key_event	(XKeyEvent *k1, char *s, KeySym *k2);
      int	handle_misc		(wdp display, wbp w);
      wdp	alc_display		(char *s);
      void	free_display		(wdp wd);
      wfp	alc_font		(wbp w, char **s);
      wfp	tryfont			(wbp w, char *s);
      wclrp	alc_rgb			(wbp w, char *s, unsigned int r,
					   unsigned int g, unsigned int b,
					   int is_iconcolor);
      wclrp	alc_rgb2		(wbp w, char *s, unsigned int r,
					   unsigned int g, unsigned int b);
      wclrp	alc_rgbTrueColor	(wbp w,unsigned long r,
					   unsigned long g, unsigned long b);
      int	alc_centry		(wdp wd);
      wclrp	alc_color		(wbp w, char *s);
      void	copy_colors		(wbp w1, wbp w2);
      void	free_xcolor		(wbp w, unsigned long c);
      void	free_xcolors		(wbp w, int extent);
      int	go_virtual		(wbp w);
      int	resizePixmap		(wbp w, int width, int height);
      void	wflushall		(void);
      void postcursor(wbp);
      void scrubcursor(wbp);
      void mkfont			(char *s, char is_3D);
#ifdef HAVE_XFT
      void drawstrng(wbp w, int x, int y, char *str, int slen);
#endif					/* HAVE_XFT */

   #endif				/* XWindows */

   #ifdef Graphics3D
      void init_opengl(wbp  w);
      int add_3dfont(char *fname, int fsize, char ftype);
      int c_traverse(struct b_list *hp, struct descrip * res, int position);
      char child_window_stuff(wbp w, wbp wp, char child_window);
      int cpp_drawstring3d(double x, double y, double z, char *s, char *f,
			   int t, int size, void *tfont);
      void cube(double length, double x, double y, double z, int gen);
      void cylinder(double radius1, double radius2, double height,
		double x,  double y, double z, int slices, int rings, int gen);
      void disk(double radius1, double radius2, double angle1, double angle2,
	        double x, double y, double z, int slices, int rings, int gen);
      int drawpoly(wbp w, double* v, int num, int type, int dim);
      int drawstrng3d(wbp w, double x, double y, double z, char *s);
      int fileimage(wbp w, char* filename);
      int getlight(int light, char* buf);
      int getmaterials(char* buf);
      void getmeshmode(wbp w, char *answer);
      int gettexcoords(wbp w, char *buf);
      void gettexmode(wbp w, char *abuf, dptr answer);
      int gettexture(wbp w, dptr dp);
      int imagestr(wbp w, char* str);
      int init_3dcontext(wcp wc);
      void makecurrent(wbp w);
      int popmatrix();
      int pushmatrix();
      int pushmatrix_rd(wbp w, dptr f);
      int redraw3D(wbp w);
      int rotate(wbp w, dptr argv, int i, dptr f);
      int scale(wbp w, dptr argv, int i, dptr f);
      int section_length(wbp w);
      int setdim(wbp w, char* s);
      int seteye(wbp w, char *s);
      int seteyedir(wbp w, char *s);
      int seteyepos(wbp w, char *s);
      int seteyeup(wbp w, char *s);
      int setlight(wbp w, char* s, int light);
      int setlinewidth3D(wbp w, LONG linewid);
      int setmaterials(wbp w, char* s);
      int setmeshmode(wbp w, char* s);
      int setrings(wbp w, char *s);
      int setselectionmode(wbp w, char* s);
      int setslices(wbp w, char *s);
      int settexcoords(wbp w, char* s);
      int settexmode(wbp w, char* s);
      int settexture(wbp w, char* str, int len);
      void sphere(double radius, double x, double y, double z,
		  int slices, int rings, int gen);
      wfp srch_3dfont(char *fname, int fsize, char ftype);
      int TexDrawLine(wbp w, int texhandle, int x1, int y1, int x2, int y2);
      int TexDrawPoint(wbp w, int texhandle, int x, int y);
      int TexReadImage(wbp w, int texhandle, int x, int y,struct imgdata *imd);
      int texwindow2D(wbp w, wbp w2d);
      int texwindow3D(wbp w1, wbp w2);
      void torus(double radius1, double radius2, double x,double y, double z,
		 int slices, int rings, int gen);
      int translate(wbp w, dptr argv, int i, dptr f);
      int traversefunctionlist(wbp w);
   #endif					/* Graphics3D */

   #ifdef MSWindows
      /*
       * Implementation routines specific to MS Windows
       */
      int playmedia		(wbp w, char *s);
      char *nativecolordialog	(wbp w,long r,long g, long b,char *s);
      int nativefontdialog	(wbp w, char *buf, int flags, int fheight);
      char *nativeselectdialog	(wbp w,struct b_list *,char *s);
      char *nativefiledialog	(wbp w,char *s1,char *s2,char *s3,int i,int j,int k);
      HFONT mkfont		(char *s, char is_3D);
      int sysTextWidth		(wbp w, char *s, int n);
      int sysFontHeight		(wbp w);
      int mswinsystem		(char *s);
      void UpdateCursorPos	(wsp ws, wcp wc);
      LRESULT_CALLBACK WndProc	(HWND, UINT, WPARAM, LPARAM);
      HDC CreateWinDC		(wbp);
      HDC CreatePixDC		(wbp, HDC);
      HBITMAP loadimage	(wbp wb, char *filename, unsigned int *width,
      			unsigned int *height, int atorigin, int *status);
      void wfreersc();
      int getdepth(wbp w);
      HBITMAP CreateBitmapFromData(char *data);
      int resizePixmap(wbp w, int width, int height);
      int textWidth(wbp w, char *s, int n);
      int	seticonimage		(wbp w, dptr dp);
      int devicecaps(wbp w, int i);
      void fillarcs(wbp wb, XArc *arcs, int narcs);
      void drawarcs(wbp wb, XArc *arcs, int narcs);
      void drawlines(wbinding *wb, XPoint *points, int npoints);
      void drawpoints(wbinding *wb, XPoint *points, int npoints);
      void drawrectangles(wbp wb, XRectangle *recs, int nrecs);
      void fillpolygon(wbp w, XPoint *pts, int npts);
      void drawsegments(wbinding *wb, XSegment *segs, int nsegs);
      void drawstrng(wbinding *wb, int x, int y, char *s, int slen);
      void unsetclip(wbp w);

   #endif				/* MSWindows */

   #ifdef PresentationManager
      /*
       * Implementation routines specific to OS/2 Presentation Manager
       */
      wsp ObtainEvents(wsp ws, SHORT blockflag, ULONG messg, QMSG *msg);
      void InterpThreadStartup(void *args);
      void InterpThreadShutdown(void);
      void DestroyWindow(wsp ws);
      void LoadDefAttrs(wbinding *wb, wsp ws, wcp wc);
      void ResizeBackingBitmap(wsp ws, SHORT x, SHORT y);
      int  moveResizeWindow(wbp w,int x, int y, int width, int height);
      void moveWindow(wbp w, int x, int y);
      int  resizeWindow(wbp w,int width,int height);
      int SetNewBitPattern(wcp wc, PBYTE bits);
      int LoadFont(wbp wb, char *family, LONG attr, ULONG fontsize);
      void FreeIdTable(void);
      void FreeLocalID(LONG id);

      /* -- not needed because of macro definitions
      void SetCharContext(wbp wb, wsp ws, wcp wc);
      void SetAreaContext(wbp wb, wsp ws, wcp wc);
      void SetLineContext(wbp wb, wsp ws, wcp wc);
      void SetImageContext(wbp wb, wsp ws, wcp wc);
         -- */

      void SetClipContext(wbp wb, wsp ws, wcp wc);
      void UnsetContext(wcp wc, void (*f)(wcp, wsp));
      void UCharContext(wcp wc, wsp ws);
      void ULineContext(wcp wc, wsp ws);
      void UAreaContext(wcp wc, wsp ws);
      void UImageContext(wcp wc, wsp ws);
      void UClipContext(wcp wc, wsp ws);
      void UAllContext(wcp wc, wsp ws);
      void drawpoints(wbp wb, XPoint *pts, int npts);
      void drawsegments(wbp wb, XSegment *segs, int nsegs);
      void drawstrng(wbp wb, int x, int y, char *str, int slen);
      void drawarcs(wbp w, XArc *arcs, int narcs);
      void drawlines(wbp wb, XPoint *pts, int npts);
      void drawrectangles(wbp wb, XRectangle *recs, int nrecs);
      int dumpimage(wbp wb, char *filename, int x, int y, int width, int height);
      void fillpolygon(wbp wb, XPoint *pts, int npts);
      HBITMAP loadimage(wbp wb, char *filename, int *width, int *height);
      void InitializeIdTable(void);
      void InitializeColorTable(void);
      void FreeColorTable(void);
      LONG GetColorIndex(char *buf, double gamma);
      void AddLocalIdToWindow(wsp ws, LONG id);
      void ReleaseLocalId(LONG id);
      void ReleaseColor(LONG indx);
      void ColorInitPS(wbp wb);
      void GetColorName(LONG indx, char *buf, int len);
      void EnsureColorAvailable(LONG indx);
      int GetTextWidth(wbp wb, char *text, int len);
      int AddWindowDep(wsp ws, wcp wc);
      int AddContextDep(wsp ws, wcp wc);
      FILE *PMOpenConsole(void);
      void UpdateCursorConfig(wsp ws, wcp wc);
      void UpdateCursorPos(wsp ws, wcp wc);

   #endif				/* PresentationManager */

#endif					/* Graphics */


#ifdef Audio
struct AudioFile * StartAudioTread(char filename[]);
void StopAudioThread(struct AudioFile * Ptr);

struct AudioFile * StartMP3Thread(char filename[]);
struct AudioFile * StartWAVThread(char filename[]);
struct AudioFile * StartOggVorbisThread(char filename[]);
#endif					/* Audio */

/*
 * Prototypes for the run-time system.
 */

struct b_external *alcextrnl	(int n);
#ifdef MultiThread
struct b_record *alcrecd_0	(int nflds,union block *recptr);
struct b_record *alcrecd_1	(int nflds,union block *recptr);
struct b_tvsubs *alcsubs_0	(word len,word pos,dptr var);
struct b_tvsubs *alcsubs_1	(word len,word pos,dptr var);
#else					/* MultiThread */
struct b_record *alcrecd	(int nflds,union block *recptr);
struct b_tvsubs *alcsubs	(word len,word pos,dptr var);
#endif					/* MultiThread */
int	bfunc		(void);
long	ckadd		(long i, long j);
long	ckmul		(long i, long j);
long	cksub		(long i, long j);
void	cmd_line	(int argc, char **argv, dptr rslt);
struct b_coexpr *create	(continuation fnc,struct b_proc *p,int ntmp,int wksz);
int	collect		(int region);
#ifdef CoClean
void coclean(void *o);
#endif
void	cotrace		(struct b_coexpr *ccp, struct b_coexpr *ncp,
			   int swtch_typ, dptr valloc);
int	cvcset		(dptr dp,int * *cs,int *csbuf);
int	cvnum		(dptr dp,union numeric *result);
int	cvreal		(dptr dp,double *r);
#ifdef MultiThread
void	deref_0		(dptr dp1, dptr dp2);
void	deref_1		(dptr dp1, dptr dp2);
#else					/* MultiThread */
void	deref		(dptr dp1, dptr dp2);
#endif					/* MultiThread */
void	envset		(void);
int	eq		(dptr dp1,dptr dp2);
int	fixtrap		(void);
int	get_name	(dptr dp1, dptr dp2);
int	getch		(void);
int	getche		(void);
double	getdbl		(dptr dp);
int	getimage	(dptr dp1, dptr dp2);
int	getstrg		(char *buf, int maxi, struct b_file *fbp);
void	hgrow		(union block *bp);
void	hshrink		(union block *bp);
C_integer iipow		(C_integer n1, C_integer n2);
void	init		(char *name, int *argcp, char *argv[], int trc_init);
int	kbhit		(void);
int	mkreal		(double r,dptr dp);
int	nthcmp		(dptr d1,dptr d2);
void	nxttab		(C_integer *col, dptr *tablst, dptr endlst,
			   C_integer *last, C_integer *interval);
int	order		(dptr dp);
int	printable	(int c);
int	ripow		(double r, C_integer n, dptr rslt);
void	rtos		(double n,dptr dp,char *s);
int	sig_rsm		(void);
struct b_proc *strprc	(dptr s, C_integer arity);
int	subs_asgn	(dptr dest, const dptr src);
int	tvmonitored_asgn(dptr dest, const dptr src);
int	trcmp3		(struct dpair *dp1,struct dpair *dp2);
int	trefcmp		(dptr d1,dptr d2);
int	tvalcmp		(dptr d1,dptr d2);
int	tvcmp4		(struct dpair *dp1,struct dpair *dp2);
int	tvtbl_asgn	(dptr dest, const dptr src);
void	varargs		(dptr argp, int nargs, dptr rslt);

#ifdef MultiThread
   struct b_coexpr *alccoexp (long icodesize, long stacksize);
#else					/* MultiThread */
   struct b_coexpr *alccoexp (void);
#endif					/* MultiThread */

dptr rec_structinate(dptr dp, char *name, int nfields, char *a[]);

#ifdef Messaging
struct MFile* Mopen(URI* puri, dptr attr, int nattr, int shortreq);
int Mclose(struct MFile* mf);
int Mpop_delete(struct MFile* mf, unsigned int msgnum);
void Mstartreading(struct MFile* mf);
#endif					/* Messaging */

#ifdef PosixFns
#if NT
int StartupWinSocket(void);
void stat2rec			(struct _stat *st, dptr dp, struct b_record **rp);
#else					/* NT */
void stat2rec			(struct stat *st, dptr dp, struct b_record **rp);
#endif					/* NT */
dptr rec_structor		(char *s);
dptr rec_structor3d		(char *s);
int sock_connect		(char *s, int udp, int timeout);
int sock_getstrg		(char *buf, int maxi, SOCKET fd);
int getmodefd			(int fd, char *mode);
int getmodenam			(char *path, char *mode);
int get_uid			(char *name);
int get_gid			(char *name);
#if !NT
dptr make_pwd			(struct passwd *pw, dptr result);
dptr make_group			(struct group *pw, dptr result);
#endif					/* NT */
dptr make_host			(struct hostent *pw, dptr result);
dptr make_serv			(struct servent *pw, dptr result);
int sock_listen		(char *s, int udp);
int sock_name			(int sock, char* addr, char* addrbuf, int bufsize);
int sock_send			(char* addr, char* msg, int msglen);
int sock_recv			(int f, struct b_record **rp);
int sock_write			(int f, char *s, int n);
struct descrip register_sig	(int sig, struct descrip handler);
void signal_dispatcher		(int sig);
int get_fd			(struct descrip, unsigned int errmask);
dptr u_read			(int fd, int n, dptr d);
void dup_fds			(dptr d_stdin, dptr d_stdout, dptr d_stderr);
#endif					/* PosixFns */

#if COMPILER

   struct b_refresh *alcrefresh	(int na, int nl, int nt, int wk_sz);
   void	atrace			(void);
   void	ctrace			(void);
   void	failtrace		(void);
   void	initalloc		(void);
   int	invoke			(int n, dptr args, dptr rslt, continuation c);
   void	rtrace			(void);
   void	strace			(void);
   void	tracebk			(struct p_frame *lcl_pfp, dptr argp);
   int	xdisp			(struct p_frame *fp, dptr dp, int n, FILE *f);

#else					/* COMPILER */

#ifdef MultiThread
   struct b_refresh *alcrefresh_0(word *e, int nl, int nt);
   struct b_refresh *alcrefresh_1(word *e, int nl, int nt);
#else					/* MultiThread */
   struct b_refresh *alcrefresh	(word *e, int nl, int nt);
#endif					/* MultiThread */
   void	atrace			(dptr dp);
   void	ctrace			(dptr dp, int nargs, dptr arg);
   void	failtrace		(dptr dp);
   int	invoke			(int nargs, dptr *cargs, int *n);
   void	rtrace			(dptr dp, dptr rval);
   void	strace			(dptr dp, dptr rval);
   void	tracebk			(struct pf_marker *lcl_pfp, dptr argp);
   int	xdisp			(struct pf_marker *fp, dptr dp, int n, FILE *f);

   #define Fargs dptr cargp
   int	Obscan			(int nargs, Fargs);
   int	Ocreate			(word *entryp, Fargs);
   int	Oescan			(int nargs, Fargs);
   int	Ofield			(int nargs, Fargs);
   int	Omkrec			(int nargs, Fargs);
   int	Olimit			(int nargs, Fargs);
   int	Ollist			(int nargs, Fargs);

   #ifdef MultiThread
      void	initalloc	(word codesize, struct progstate *p);
   #else				/* MultiThread */
      void	initalloc	(word codesize);
   #endif				/* MultiThread */

#endif					/* COMPILER */

/* dynamic records */
struct b_proc *dynrecord(dptr s, dptr fields, int n);

#ifdef ISQL
FILE   *isql_open (char *, dptr, dptr, dptr);
int     dbclose(struct ISQLFile *);
int     dbfetch(struct ISQLFile *, dptr);
void    odbcerror               (struct ISQLFile *fp, int errornum);
void    qalloc                  (struct ISQLFile *f, long n); /* query space alloc */
#endif					/* ISQL */

#ifdef Audio
struct AudioFile * StartAudioThread(char filename[]);
void StopAudioThread(struct AudioFile * Ptr);
#endif					/* Audio */

#ifdef DebugHeap
void heaperr(char *msg, union block *p, int t);
#endif					/* DebugHeap */

