/*
 * File: fwindow.r - Icon graphics interface
 *
 * Contents: Active, Bg, Color, CopyArea, Couple,
 *  DrawArc, DrawCircle, DrawCurve, DrawImage, DrawLine,
 *  DrawSegment, DrawPoint, DrawPolygon, DrawString,
 *  DrawRectangle, DrawTorus, DrawCylinder, DrawDisk, DrawCube, 
 *  DrawSphere,  EraseArea, Event, Fg, FillArc, FillCircle,
 *  FillRectangle, FillPolygon, Font, FreeColor, GotoRC, GotoXY,
 *  NewColor, Pattern, PaletteChars, PaletteColor, PaletteKey,
 *  Pending, PopMatrix, PushMatrix, QueryPointer, ReadImage, Rotate,
 *  Scale, Translate, TextWidth, Texture, Texcoord, Uncouple,
 *  WAttrib, WDefault, WFlush, WSync, WriteImage
 */

#begdef MissingGraphicsFunc(funcname)
"an unavailable graphics function"
function{} funcname()
   runerr(121)
end
#enddef

#begdef MissingGraphicsFunc1(funcname)
"an unavailable graphics function"
function{} funcname(x)
   runerr(121)
end
#enddef

#begdef MissingGraphicsFuncV(funcname)
"an unavailable graphics function"
function{0} funcname(argv[warg])
   runerr(121)
end
#enddef

#ifdef Graphics

/*
 * Global variables.
 *  A poll counter for use in interp.c,
 *  the binding for the console window - FILE * for simplicity,
 *  &col, &row, &x, &y, &interval, timestamp, and modifier keys.
 */
int pollctr;
FILE *ConsoleBinding = NULL;
/*
 * the global buffer used as work space for printing string, etc 
 */
char ConsoleStringBuf[MaxReadStr * 48];
char *ConsoleStringBufPtr = ConsoleStringBuf;
unsigned long ConsoleFlags = 0;			 /* Console flags */



"Active() - produce the next active window"

function{0,1} Active()
   abstract {
      return file
      }
   body {
      wsp ws;
      if (!wstates || !(ws = getactivewindow())) fail;
      return ws->filep;
      }
end


"Alert(w,volume) - Alert the user"

function{1} Alert(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0;
      C_integer volume;
      OptWindow(w);

      if (argc == warg) volume = 0;
      else if (!def:C_integer(argv[warg], 0, volume))
        runerr(101, argv[warg]);
      walert(w, volume);
      ReturnWindow;
      }
end

"Bg(w,s) - background color"

function{0,1} Bg(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      char sbuf1[MaxCvtLen];
      int len;
      tended char *tmp;
      int warg = 0;
      OptWindow(w);

      /*
       * If there is a (non-window) argument we are setting by
       * either a mutable color (negative int) or a string name.
       */
      if (argc - warg > 0) {
	 if (is:integer(argv[warg])) {    /* mutable color or packed RGB */
	    if (isetbg(w, IntVal(argv[warg])) == Failed) fail;
	    }
	 else {
	    if (!cnv:C_string(argv[warg], tmp))
	       runerr(103,argv[warg]);
	    if(setbg(w, tmp) == Failed) fail;
	    }

         }

      /*
       * In any event, this function returns the current background color.
       */
      getbg(w, sbuf1);
      len = strlen(sbuf1);
      Protect(tmp = alcstr(sbuf1, len), runerr(0));
      return string(len, tmp);
      }
end


"Clip(w, x, y, w, h) - set context clip rectangle"

function{1} Clip(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0, r;
      C_integer x, y, width, height;
      wcp wc;
      OptWindow(w);

      wc = w->context;

      if (argc <= warg) {
         wc->clipx = wc->clipy = 0;
         wc->clipw = wc->cliph = -1;
         unsetclip(w);
         }
      else {
         r = rectargs(w, argc, argv, warg, &x, &y, &width, &height);
         if (r >= 0)
            runerr(101, argv[r]);
         wc->clipx = x;
         wc->clipy = y;
         wc->clipw = width;
         wc->cliph = height;
         setclip(w);
         }

      ReturnWindow;
      }
end


"Clone(w, attribs...) - create a new context bound to w's canvas"

function{1} Clone(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w, w2;
      int warg = 0, n;
      tended struct descrip sbuf, sbuf2;
      char answer[128];
      OptWindow(w);

      Protect(w2 = alc_wbinding(), runerr(0));
      w2->window = w->window;
      w2->window->refcount++;

      if (argc>warg && is:file(argv[warg])) {
	 if ((BlkLoc(argv[warg])->file.status & Fs_Window) == 0)
	    runerr(140,argv[warg]);
	 if ((BlkLoc(argv[warg])->file.status & (Fs_Read|Fs_Write)) == 0)
	    runerr(142,argv[warg]);
	 if (ISCLOSED((wbp)BlkLoc(argv[warg])->file.fd))
	    runerr(142,argv[warg]);
	 Protect(w2->context =
		 clone_context((wbp)BlkLoc(argv[warg])->file.fd), runerr(0));
	 warg++;
	 }
      else {
	 Protect(w2->context = clone_context(w), runerr(0));
	 }

      for (n = warg; n < argc; n++) {
	 if (!is:null(argv[n])) {
	    if (!cnv:tmp_string(argv[n], sbuf))
	       runerr(109, argv[n]);
	    switch (wattrib(w2, StrLoc(argv[n]), StrLen(argv[n]), &sbuf2, answer)) {
	    case Failed: fail;
	    case Error: runerr(0, argv[n]);
	       }
	    }
	 }

      Protect(BlkLoc(result) =
	      (union block *)alcfile((FILE *)w2,
				     Fs_Window|Fs_Read|Fs_Write
#ifdef Graphics3D
				      | (w->context->is_3D?Fs_Window3D:0)
#endif					/* Graphics3D */
				   , &emptystr),runerr(0));
      result.dword = D_File;
      return result;
      }
end



"Color(argv[]) - return or set color map entries"

function{0,1} Color(argv[argc])
   abstract {
      return file ++ string
      }
   body {
      wbp w;
      int warg = 0;
      int i, len;
      C_integer n;
      char *colorname, *srcname;
      tended char *tmp;

      OptWindow(w);
      if (argc - warg == 0) runerr(101);

      if (argc - warg == 1) {			/* if this is a query */
         CnvCInteger(argv[warg], n)
         if ((colorname = get_mutable_name(w, n)) == NULL)
            fail;
         len = strlen(colorname);
         Protect(tmp = alcstr(colorname, len), runerr(0));
         return string(len, tmp);
         }

      CheckArgMultiple(2);

      for (i = warg; i < argc; i += 2) {
         CnvCInteger(argv[i], n)
         if ((colorname = get_mutable_name(w, n)) == NULL)
            fail;

         if (is:integer(argv[i+1])) {		/* copy another mutable  */
            if (IntVal(argv[i+1]) >= 0)
               runerr(205, argv[i+1]);		/* must be negative */
            if ((srcname = get_mutable_name(w, IntVal(argv[i+1]))) == NULL)
               fail;
            if (set_mutable(w, n, srcname) == Failed) fail;
            strcpy(colorname, srcname);
            }
   
         else {					/* specified by name */
            tended char *tmp;
            if (!cnv:C_string(argv[i+1],tmp))
               runerr(103,argv[i+1]);
   
            if (set_mutable(w, n, tmp) == Failed) fail;
            strcpy(colorname, tmp);
            }
         }

      ReturnWindow;
      }
end


"ColorValue(w,s) - produce RGB components from string color name"

function{0,1} ColorValue(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      C_integer n;
      int warg = 0, len;
      long r, g, b;
      tended char *s;
      char tmp[24], *t;

      if (is:file(argv[0]) && (BlkLoc(argv[0])->file.status & Fs_Window)) {
         w = (wbp)BlkLoc(argv[0])->file.fd;		/* explicit window */	
         warg = 1;
         }
      else if (is:file(kywd_xwin[XKey_Window]) &&
            (BlkLoc(kywd_xwin[XKey_Window])->file.status & Fs_Window))
         w = (wbp)BlkLoc(kywd_xwin[XKey_Window])->file.fd;	/* &window */
      else
         w = NULL;			/* no window (but proceed anyway) */

      if (!(warg < argc))
         runerr(103);

      if (cnv:C_integer(argv[warg], n)) {
         if (w != NULL && (t = get_mutable_name(w, n)))
            Protect(s = alcstr(t, (word)strlen(t)+1), runerr(306));
         else
            fail;
         }
      else if (!cnv:C_string(argv[warg], s))
         runerr(103,argv[warg]);

      if (parsecolor(w, s, &r, &g, &b) == Succeeded) {
         sprintf(tmp,"%ld,%ld,%ld", r, g, b);
	 len = strlen(tmp);
	 Protect(s = alcstr(tmp,len), runerr(306));
	 return string(len, s);
         }
      fail;
      }
end


"CopyArea(w,w2,x,y,width,height,x2,y2) - copy area"

function{0,1} CopyArea(argv[argc]) /* w,w2,x,y,width,height,x2,y2 */
   abstract {
      return file
      }
   body {
      int warg = 0, n, r;
      C_integer x, y, width, height, x2, y2, width2, height2;
      wbp w, w2;
      OptWindow(w);

      /*
       * 2nd window defaults to value of first window
       */
      if (argc>warg && is:file(argv[warg])) {
	 if ((BlkLoc(argv[warg])->file.status & Fs_Window) == 0)
	    runerr(140,argv[warg]);
	 if ((BlkLoc(argv[warg])->file.status & (Fs_Read|Fs_Write)) == 0)
	    runerr(142,argv[warg]);
	 w2 = (wbp)BlkLoc(argv[warg])->file.fd;
	 if (ISCLOSED(w2))
	    runerr(142,argv[warg]);
	 warg++;
	 }
      else {
	 w2 = w;
	 }

      /*
       * x1, y1, width, and height follow standard conventions.
       */
      r = rectargs(w, argc, argv, warg, &x, &y, &width, &height);
      if (r >= 0)
         runerr(101, argv[r]);

      /*
       * get x2 and y2, ignoring width and height.
       */
      n = argc;
      if (n > warg + 6)
         n = warg + 6;
      r = rectargs(w2, n, argv, warg + 4, &x2, &y2, &width2, &height2);
      if (r >= 0)
         runerr(101, argv[r]);

      if (copyArea(w, w2, x, y, width, height, x2, y2) == Failed)
         fail;
      ReturnWindow;
      }
end

/*
 * Bind the canvas associated with w to the context
 *  associated with w2.  If w2 is omitted, create a new context.
 *  Produces a new window variable.
 */
"Couple(w,w2) - couple canvas to context"

function{0,1} Couple(w,w2)
   abstract {
      return file
      }
   body {
      tended struct descrip sbuf, sbuf2;
      wbp wb, wb_new;
      wsp ws;

      /*
       * make the new binding
       */
      Protect(wb_new = alc_wbinding(), runerr(0));

      /*
       * if w is a file, then we bind to an existing window
       */
      if (is:file(w) && (BlkLoc(w)->file.status & Fs_Window)) {
	 wb = (wbp)(BlkLoc(w)->file.fd);
	 wb_new->window = ws = wb->window;
	 if (is:file(w2) && (BlkLoc(w2)->file.status & Fs_Window)) {
	    /*
	     * Bind an existing window to an existing context,
	     * and up the context's reference count.
	     */
	    if (rebind(wb_new, (wbp)(BlkLoc(w2)->file.fd)) == Failed) fail;
	    wb_new->context->refcount++;
	    }
	 else 
	    runerr(140, w2);

	 /* bump up refcount to ws */
	 ws->refcount++;
	 }
      else
	 runerr(140, w);

      Protect(BlkLoc(result) =
	 (union block *)alcfile((FILE *)wb_new,	Fs_Window|Fs_Read|Fs_Write,
				&emptystr),runerr(0));
      result.dword = D_File;
      return result;
      }
end

/*
 * DrawArc(w, x1, y1, width1, height1, angle11, angle21,...)
 */
"DrawArc(argv[]){1} - draw arc"

function{1} DrawArc(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, r, warg = 0;
      XArc arcs[MAXXOBJS];
      C_integer x, y, width, height;
      double a1, a2;

      OptWindow(w);
      j = 0;
      for (i = warg; i < argc || i == warg; i += 6) {
         if (j == MAXXOBJS) {
            drawarcs(w, arcs, MAXXOBJS);
            j = 0;
            }
         r = rectargs(w, argc, argv, i, &x, &y, &width, &height);
         if (r >= 0)
            runerr(101, argv[r]);

         arcs[j].x = x;
         arcs[j].y = y;
         ARCWIDTH(arcs[j]) = width;
         ARCHEIGHT(arcs[j]) = height;

	 /*
	  * Angle 1 processing.  Computes in radians and 64'ths of a degree,
	  *  bounds checks, and handles wraparound.
	  */
         if (i + 4 >= argc || is:null(argv[i + 4]))
	    a1 = 0.0;
         else {
            if (!cnv:C_double(argv[i + 4], a1))
               runerr(102, argv[i + 4]);
            if (a1 >= 0.0)
               a1 = fmod(a1, 2 * Pi);
            else
               a1 = -fmod(-a1, 2 * Pi);
            }
	 /*
	  * Angle 2 processing
	  */
         if (i + 5 >= argc || is:null(argv[i + 5]))
	    a2 = 2 * Pi;
         else {
            if (!cnv:C_double(argv[i + 5], a2))
               runerr(102, argv[i + 5]);
            if (fabs(a2) > 3 * Pi)
               runerr(101, argv[i + 5]);
            }
         if (fabs(a2) >= 2 * Pi) {
	    a2 = 2 * Pi;
	    }
         else {
            if (a2 < 0.0) {
               a1 += a2;
               a2 = fabs(a2);
               }
            }
         if (a1 < 0.0)
            a1 = 2 * Pi - fmod(fabs(a1), 2 * Pi);
         else
            a1 = fmod(a1, 2 * Pi);
         arcs[j].angle1 = ANGLE(a1);
         arcs[j].angle2 = EXTENT(a2);

         j++;
         }

      drawarcs(w, arcs, j);
      ReturnWindow;
      }
end

/*
 * DrawCircle(w, x1, y1, r1, angle11, angle21, ...)
 */
"DrawCircle(argv[]){1} - draw circle"

function{1} DrawCircle(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0, r;

      OptWindow(w);
      r = docircles(w, argc - warg, argv + warg, 0);
      if (r < 0)
         ReturnWindow;
      else if (r >= argc - warg)
         runerr(146);
      else 
         runerr(102, argv[warg + r]);
      }
end

/*
 * DrawCurve(w,x1,y1,...xN,yN)
 *  Draw a smooth curve through the given points.
 */
"DrawCurve(argv[]){1} - draw curve"

function{1} DrawCurve(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, n, closed = 0, warg = 0;
      C_integer dx, dy, x0, y0, xN, yN;
      XPoint *points;

      OptWindow(w);
      CheckArgMultiple(2);

      dx = w->context->dx;
      dy = w->context->dy;

      Protect(points = (XPoint *)malloc(sizeof(XPoint) * (n+2)), runerr(305));

      if (n > 1) {
	 CnvCInteger(argv[warg], x0)
	 CnvCInteger(argv[warg + 1], y0)
	 CnvCInteger(argv[argc - 2], xN)
	 CnvCInteger(argv[argc - 1], yN)
         if ((x0 == xN) && (y0 == yN)) {
            closed = 1;               /* duplicate the next to last point */
	    CnvCShort(argv[argc-4], points[0].x);
	    CnvCShort(argv[argc-3], points[0].y);
	    points[0].x += w->context->dx;
	    points[0].y += w->context->dy;
            }
         else {                       /* duplicate the first point */
	    CnvCShort(argv[warg], points[0].x);
	    CnvCShort(argv[warg + 1], points[0].y);
	    points[0].x += w->context->dx;
	    points[0].y += w->context->dy;
            }
         for (i = 1; i <= n; i++) {
	    int base = warg + (i-1) * 2;
            CnvCShort(argv[base], points[i].x);
            CnvCShort(argv[base + 1], points[i].y);
	    points[i].x += dx;
	    points[i].y += dy;
            }
         if (closed) {                /* duplicate the second point */
            points[i] = points[2];
            }
         else {                       /* duplicate the last point */
            points[i] = points[i-1];
            }
	 if (n < 3) {
	    drawlines(w, points+1, n);
	    }
	 else {
	    drawCurve(w, points, n+2);
	    }
         }
      free(points);
      ReturnWindow;
      }
end


"DrawImage(w,x,y,s) - draw bitmapped figure"

function{0,1} DrawImage(argv[argc])
   abstract {
      return null++integer
      }
   body {
      wbp w;
      int warg = 0;
      int c, i, width, height, row, p;
      C_integer x, y;
      word nchars;
      unsigned char *s, *t, *z;
      struct descrip d;
      struct palentry *e;
      OptWindow(w);

      /*
       * X or y can be defaulted but s is required.
       * Validate x/y first so that the error message makes more sense.
       */
      if (argc - warg >= 1 && !def:C_integer(argv[warg], -w->context->dx, x))
         runerr(101, argv[warg]);
      if (argc - warg >= 2 && !def:C_integer(argv[warg + 1], -w->context->dy, y))
         runerr(101, argv[warg + 1]);
      if (argc - warg < 3)
         runerr(103);			/* missing s */
      if (!cnv:tmp_string(argv[warg+2], d))
         runerr(103, argv[warg + 2]);

      x += w->context->dx;
      y += w->context->dy;
      /*
       * Extract the Width and skip the following comma.
       */
      s = (unsigned char *)StrLoc(d);
      z = s + StrLen(d);		/* end+1 of string */
      width = 0;
      while (s < z && *s == ' ')	/* skip blanks */
	 s++;
      while (s < z && isdigit(*s))	/* scan number */
         width = 10 * width + *s++ - '0';
      while (s < z && *s == ' ')	/* skip blanks */
	 s++;
      if (width == 0 || *s++ != ',')	/* skip comma */
         fail;
      while (s < z && *s == ' ')	/* skip blanks */
	 s++;
      if (s >= z)			/* if end of string */
	 fail;

      /*
       * Check for a bilevel format.
       */
      if ((c = *s) == '#' || c == '~') {
         s++;
         nchars = 0;
         for (t = s; t < z; t++)
            if (isxdigit(*t))
               nchars++;			/* count hex digits */
            else if (*t != PCH1 && *t != PCH2)
               fail;				/* illegal punctuation */
         if (nchars == 0)
            fail;
         row = (width + 3) / 4;			/* digits per row */
         if (nchars % row != 0)
            fail;
         height = nchars / row;
         if (blimage(w, x, y, width, height, c, s, (word)(z - s)) == Error)
            runerr(305);
         else
            return nulldesc;
         }

      /*
       * Extract the palette name and skip its comma.
       */
      c = *s++;					/* save initial character */
      p = 0;
      while (s < z && isdigit(*s))		/* scan digits */
         p = 10 * p + *s++ - '0';
      while (s < z && *s == ' ')		/* skip blanks */
	 s++;
      if (s >= z || p == 0 || *s++ != ',')	/* skip comma */
         fail;
      if (c == 'g' && p >= 2 && p <= 256)	/* validate grayscale number */
         p = -p;
      else if (c != 'c' || p < 1 || p > 6)	/* validate color number */
         fail;

      /*
       * Scan the image to see which colors are needed.
       */
      e = palsetup(p); 
      if (e == NULL)
         runerr(305);
      for (i = 0; i < 256; i++)
         e[i].used = 0;
      nchars = 0;
      for (t = s; t < z; t++) {
         c = *t; 
         e[c].used = 1;
         if (e[c].valid || e[c].transpt)
            nchars++;			/* valid color, or transparent */
         else if (c != PCH1 && c != PCH2)
            fail;
         }
      if (nchars == 0)
         fail;					/* empty image */
      if (nchars % width != 0)
         fail;					/* not rectangular */

      /*
       * Call platform-dependent code to draw the image.
       */
      height = nchars / width;
      i = strimage(w, x, y, width, height, e, s, (word)(z - s), 0);
      if (i == 0)
         return nulldesc;
      else if (i < 0)
         runerr(305);
      else
         return C_integer i;
      }
end

/*
 * DrawLine(w,x1,y1,...xN,yN)
 */
"DrawLine(argv[]){1} - draw line"

function{1} DrawLine(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, n, warg = 0;
      XPoint points[MAXXOBJS];
      int dx, dy;
      OptWindow(w);

#ifdef Graphics3D
      if (w->context->is_3D){
         double *v, v2[256];  
         struct descrip f, funcname;
         struct b_list *func;
 
         /* create a list to keep track of function information */
         Protect(func = alclist(0, MinListSlots), runerr(0));
         f.dword = D_List;
         f.vword.bptr = (union block *) func; 
         MakeStr("DrawLine", 8, &funcname);
         c_put(&f, &funcname);

	 if (argc-warg > 256) {
	    v = calloc(argc-warg, sizeof (double));
	    if (v == NULL) runerr(305);
	    }
	 else v = v2;

         /* convert arguments to doubles and put them in the list */
         for (i = 0; i<argc-warg; i++){
            if (!cnv:C_double(argv[warg + i], v[i])) {
	       if (v != v2) free(v);
               runerr(102, argv[warg+i]);
	       }
            c_put(&f, &argv[warg+i]);
            }
         c_put(&(w->window->funclist), &f);

         /* draw the lines */
         CheckArgMultiple(w->context->dim);
         drawpoly(w, v, argc-warg, GL_LINE_STRIP, w->context->dim);
         glFlush();
         glXSwapBuffers(w->window->display->display, w->window->win);
	 if (v != v2) free(v);
         return f;
         }
     else 
#endif					/* Graphics3D */
     {
      CheckArgMultiple(2);

      dx = w->context->dx;
      dy = w->context->dy;
      for(i=0, j=0;i<n;i++, j++) {
	 int base = warg + i * 2;
         if (j==MAXXOBJS) {
	    drawlines(w, points, MAXXOBJS);
	    points[0] = points[MAXXOBJS-1];
   	    j = 1;
            }
         CnvCShort(argv[base], points[j].x);
         CnvCShort(argv[base + 1], points[j].y);
	 points[j].x += dx;
	 points[j].y += dy;
         }
      drawlines(w, points, j);
      ReturnWindow;
        }
      }
end

/*
 * DrawPoint(w, x1, y1, ...xN, yN)
 */
"DrawPoint(argv[]){1} - draw point"

function{1} DrawPoint(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, n, warg = 0;
      XPoint points[MAXXOBJS];
      int dx, dy;

      OptWindow(w);
  
#ifdef Graphics3D
      if (w->context->is_3D) {
         double *v, v2[256];   
         struct descrip f, funcname;
         struct b_list *func;  

         /* create a list to store function information */
         Protect(func = alclist(0, MinListSlots), runerr(0)); 
         f.dword = D_List;
         f.vword.bptr = (union block *) func; 
         MakeStr("DrawPoint", 9, &funcname);
         c_put(&f, &funcname);

	 if (argc-warg > 256) {
	    v = calloc(argc-warg, sizeof (double));
	    if (v == NULL) runerr(305);
	    }
	 else v = v2;

         /* convert the arguments and store them in the list */
         for (i = 0; i<argc-warg; i++){
            if (!cnv:C_double(argv[warg + i], v[i])) {
	       if (v != v2) free(v);
               runerr(102, argv[warg+i]);
	       }
            c_put(&f, &argv[warg+i]);
	    }
         c_put(&(w->window->funclist), &f);
         CheckArgMultiple(w->context->dim);
         drawpoly(w, v, argc-warg, GL_POINTS, w->context->dim);
         glFlush();
         glXSwapBuffers(w->window->display->display, w->window->win);
	 if (v != v2) free(v);
         return f;
	 }
      else 
#endif					/* Graphics3D */
     {
     CheckArgMultiple(2);
      dx = w->context->dx;
      dy = w->context->dy;
      for(i=0, j=0; i < n; i++, j++) {
	 int base = warg + i * 2;
         if (j == MAXXOBJS) {
	    drawpoints(w, points, MAXXOBJS);
            j = 0;
            }
         CnvCShort(argv[base], points[j].x);
         CnvCShort(argv[base + 1], points[j].y);
	 points[j].x += dx;
	 points[j].y += dy;
       }
      drawpoints(w, points, j);
      ReturnWindow;

        }
     }
end

/*
 * DrawPolygon(w,x1,y1,...xN,yN)
 */
"DrawPolygon(argv[]){1} - draw polygon"

function{1} DrawPolygon(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, n, base, dx, dy, warg = 0;
      XPoint points[MAXXOBJS];
      OptWindow(w);

#ifdef Graphics3D
      if (w->context->is_3D) {
         double *v, v2[256]; 
         struct descrip f, funcname;
         struct b_list *func;
      
         /* create a list for function information */
         Protect(func = alclist(0, MinListSlots), runerr(0));  
         f.dword = D_List;
         f.vword.bptr = (union block *) func; 
         MakeStr("DrawPolygon", 11, &funcname);
         c_put(&f, &funcname);

	 if (argc-warg > 256) {
	    v = calloc(argc-warg, sizeof (double));
	    if (v == NULL) runerr(305);
	    }
	 else v = v2;

         /* convert the arguments and put them in the list */
         for (i = 0; i<argc-warg; i++){
            if (!cnv:C_double(argv[warg + i], v[i])) {
	       if (v != v2) free(v);
               runerr(102, argv[warg+i]);
	       }
            c_put(&f, &argv[warg+i]);
	    }
         c_put(&(w->window->funclist), &f);
 
         /* draw the polygon */
         CheckArgMultiple(w->context->dim);
	 drawpoly(w, v, argc-warg, GL_LINE_LOOP, w->context->dim);
	 glFlush();
         glXSwapBuffers(w->window->display->display, w->window->win);
	 if (v != v2) free(v);
         return f;
	 }
      else 
#endif					/* Graphics3D */
     {
      CheckArgMultiple(2);

      dx = w->context->dx;
      dy = w->context->dy;

      /*
       * To make a closed polygon, start with the *last* point.
       */
      CnvCShort(argv[argc - 2], points[0].x);
      CnvCShort(argv[argc - 1], points[0].y);
      points[0].x += dx;
      points[0].y += dy;

      /*
       * Now add all points from beginning to end, including last point again.
       */
      for(i = 0, j = 1; i < n; i++, j++) {
         base = warg + i * 2;
         if (j == MAXXOBJS) {
            drawlines(w, points, MAXXOBJS);
            points[0] = points[MAXXOBJS-1];
            j = 1;
            }
         CnvCShort(argv[base], points[j].x);
         CnvCShort(argv[base + 1], points[j].y);
         points[j].x += dx;
         points[j].y += dy;
         }
      drawlines(w, points, j);
      ReturnWindow;
       }
     }
end


/*
 * DrawRectangle(w, x1, y1, width1, height1, ..., xN, yN, widthN,heightN)
 */
"DrawRectangle(argv[]){1} - draw rectangle"

function{1} DrawRectangle(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, r, warg = 0;
      XRectangle recs[MAXXOBJS];
      C_integer x, y, width, height;

      OptWindow(w);
      j = 0;

      for (i = warg; i < argc || i == warg; i += 4) {
         r = rectargs(w, argc, argv, i, &x, &y, &width, &height);
         if (r >= 0)
            runerr(101, argv[r]);
         if (j == MAXXOBJS) {
            drawrectangles(w,recs,MAXXOBJS);
            j = 0;
            }
         RECX(recs[j]) = x;
         RECY(recs[j]) = y;
         RECWIDTH(recs[j]) = width;
         RECHEIGHT(recs[j]) = height;
         j++;
         }

      drawrectangles(w, recs, j);
      ReturnWindow;
      }
end

/*
 * DrawSegment(x11,y11,x12,y12,...,xN1,yN1,xN2,yN2)
 */
"DrawSegment(argv[]){1} - draw line segment"

function{1} DrawSegment(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, n, warg = 0, dx, dy;
      XSegment segs[MAXXOBJS];

      OptWindow(w);

#ifdef Graphics3D
      if (w->context->is_3D) {
         double *v, v2[256];
         struct descrip f, funcname;
         struct b_list *func;

         /* create a list for function information */
         Protect(func = alclist(0, MinListSlots), runerr(0));
         f.dword = D_List;
         f.vword.bptr = (union block *) func; 
         MakeStr("DrawSegment", 11, &funcname);
         c_put(&f, &funcname);

	 if (argc-warg > 256) {
	    v = calloc(argc-warg, sizeof (double));
	    if (v == NULL) runerr(305);
	    }
	 else v = v2;

         /* convert the arguments and save the values in the list */
         for (i = 0; i<argc-warg; i++){
            if (!cnv:C_double(argv[warg + i], v[i])) {
	       if (v != v2) free(v);
               runerr(102, argv[warg+i]);
	       }
            c_put(&f, &argv[warg+i]);
	      }

         /* draw the line segments */
         c_put(&(w->window->funclist), &f);
         CheckArgMultiple(w->context->dim);
	 drawpoly(w, v, argc-warg, GL_LINES, w->context->dim);
	 glFlush();
    	 glXSwapBuffers(w->window->display->display, w->window->win);
	 if (v != v2) free(v);
	 return f;
	 }
       else
#endif					/* Graphics3D */
     {

      CheckArgMultiple(4);

      dx = w->context->dx;
      dy = w->context->dy;
      for(i=0, j=0; i < n; i++, j++) {
	 int base = warg + i * 4;
         if (j == MAXXOBJS) {
	    drawsegments(w, segs, MAXXOBJS);
            j = 0;
            }
         CnvCShort(argv[base], segs[j].x1);
         CnvCShort(argv[base + 1], segs[j].y1);
         CnvCShort(argv[base + 2], segs[j].x2);
         CnvCShort(argv[base + 3], segs[j].y2);
	 segs[j].x1 += dx;
	 segs[j].x2 += dx;
	 segs[j].y1 += dy;
	 segs[j].y2 += dy;
         }
      drawsegments(w, segs, j);
	 }
      ReturnWindow;
      }
end

/*
 * DrawString(w, x1, y1, s1, ..., xN, yN, sN)
 */
"DrawString(argv[]){1} - draw text"

function{1} DrawString(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, n, len, warg = 0;
      char *s;
      int dx, dy;

      OptWindow(w);
      CheckArgMultiple(3);

      for(i=0; i < n; i++) {
         C_integer x, y;
	 int base = warg + i * 3;
         CnvCInteger(argv[base], x);
         CnvCInteger(argv[base + 1], y);
	 x += w->context->dx;
	 y += w->context->dy;
         CnvTmpString(argv[base + 2], argv[base + 2]);
	 s = StrLoc(argv[base + 2]);
	 len = StrLen(argv[base + 2]);
	 drawstrng(w, x, y, s, len);
         }
      ReturnWindow;
      }
end


"EraseArea(w,x,y,width,height) - clear an area of the window"

function{1} EraseArea(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0, i, r;
      C_integer x, y, width, height;
      OptWindow(w);

#ifdef Graphics3D
      if (w->context->is_3D) {
	 /*
	  * allocate a new list for functions
	  */
         Protect(w->window->funclist.vword.bptr = (union block *)alclist(0, MinListSlots), runerr(0));
	 
         glClearColor(RED(w->context->bg)/(GLfloat)256,
               GREEN(w->context->bg)/(GLfloat)256, 
               BLUE(w->context->bg)/(GLfloat)256, 0.0);
         glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);    
         glXSwapBuffers(w->window->display->display, w->window->win);
         ReturnWindow;
	 }
#endif                                /* Graphics3D */

      for (i = warg; i < argc || i == warg; i += 4) {
         r = rectargs(w, argc, argv, i, &x, &y, &width, &height);
         if (r >= 0)
            runerr(101, argv[r]);
         eraseArea(w, x, y, width, height);
         }

      ReturnWindow;
      }
end


"Event(w) - return an event from a window"

function{1} Event(argv[argc])
   abstract {
      return string ++ integer
      }
   body {
      wbp w;
      C_integer i, t;
      tended struct descrip d;
      int warg = 0;
      if (argc>warg && is:file(argv[warg])) {
	 d = argv[warg++];
         }
      else {
	 d = kywd_xwin[XKey_Window];
	 }
      if (is:null(d) || ((BlkLoc(d)->file.status & Fs_Window) == 0))
	 runerr(140,d);
      if ((BlkLoc(d)->file.status & (Fs_Read|Fs_Write)) == 0)
	 runerr(142,d);
      (w) = (wbp)BlkLoc(d)->file.fd;
#ifdef ConsoleWindow
      if ((((FILE*)(w)) != ConsoleBinding) &&
	  ((((FILE*)(w)) == k_input.fd) ||
	   (((FILE*)(w)) == k_output.fd) ||
	   (((FILE*)(w)) == k_errout.fd)))
	 (w) = (wbp)OpenConsole();
#endif					/* ConsoleWindow */

      if (ISCLOSED(w) && BlkLoc(w->window->listp)->list.size == 0)
	 runerr(142,d);
      if (argc - warg < 1)
	 t = -1;
      else
	 CnvCInteger(argv[warg], t)

      d = nulldesc;
      i = wgetevent(w, &d, t);
      if (i == -3) {
         if (t < 0) {
            /* Something's wrong, but what?  */
            runerr(-1);
            }
         fail;
         }
      if (i == 0) {
         if (is:file(kywd_xwin[XKey_Window]) &&
               w == (wbp)BlkLoc(kywd_xwin[XKey_Window])->file.fd)
	    lastEventWin = kywd_xwin[XKey_Window];
	 else
	    lastEventWin = argv[warg-1];
         lastEvFWidth = FWIDTH((wbp)BlkLoc(lastEventWin)->file.fd);
         lastEvLeading = LEADING((wbp)BlkLoc(lastEventWin)->file.fd);
         lastEvAscent = ASCENT((wbp)BlkLoc(lastEventWin)->file.fd);
	 if (is:integer(d) && IntVal(d)==WINDOWCLOSED && 
	     !(w->window->inputmask & WindowClosureMask)) {
	    /* closed, don't accept more I/O on it */
	    BlkLoc(lastEventWin)->file.status &= ~(Fs_Read|Fs_Write);
	    }
	 return d;
	 }
      else if (i == -1)
	 runerr(141);
      else
	 runerr(143);
      }
end


"Fg(w,s) - foreground color"

function{0,1} Fg(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      char sbuf1[MaxCvtLen];
      int len;
      tended char *tmp;
	char *temp;

      int warg = 0;

      OptWindow(w);

      /*
       * If there is a (non-window) argument we are setting by
       *  either a mutable color (negative int) or a string name.
       */
      if (argc - warg > 0) {
	  if (is:integer(argv[warg])) {	/* mutable color or packed RGB */
	    if (isetfg(w, IntVal(argv[warg])) == Failed) fail;
	    }
	  else {
	    if (!cnv:C_string(argv[warg], tmp))
	       runerr(103,argv[warg]);
#ifdef Graphics3D  
	    if (w->context->is_3D) {
             /* set the material properties */
             if(setmaterials(w, tmp) == Failed) fail; 
            }
	    else
#endif
	     if(setfg(w, tmp) == Failed) fail;
 	 }

      }

      /*
       * In any case, this function returns the current foreground color.
       */

      getfg(w, sbuf1);

#ifdef Graphics3D  
      if (w->context->is_3D)
         getmaterials(sbuf1); 
#endif
      len = strlen(sbuf1);
      Protect(tmp = alcstr(sbuf1, len), runerr(0));
      return string(len, tmp);
      }
end

/*
 * FillArc(w, x1, y1, width1, height1, angle11, angle21,...)
 */
"FillArc(argv[]){1} - fill arc"

function{1} FillArc(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, r, warg = 0;
      XArc arcs[MAXXOBJS];
      C_integer x, y, width, height;
      double a1, a2;

      OptWindow(w);
      j = 0;
      for (i = warg; i < argc || i == warg; i += 6) {
         if (j == MAXXOBJS) {
            fillarcs(w, arcs, MAXXOBJS);
            j = 0;
            }
         r = rectargs(w, argc, argv, i, &x, &y, &width, &height);
         if (r >= 0)
            runerr(101, argv[r]);

         arcs[j].x = x;
         arcs[j].y = y;
         ARCWIDTH(arcs[j]) = width;
         ARCHEIGHT(arcs[j]) = height;

         if (i + 4 >= argc || is:null(argv[i + 4])) {
            a1 = 0.0;
	    }
         else {
            if (!cnv:C_double(argv[i + 4], a1))
               runerr(102, argv[i + 4]);
            if (a1 >= 0.0)
               a1 = fmod(a1, 2 * Pi);
            else
               a1 = -fmod(-a1, 2 * Pi);
            }
         if (i + 5 >= argc || is:null(argv[i + 5]))
	    a2 = 2 * Pi;
         else {
            if (!cnv:C_double(argv[i + 5], a2))
               runerr(102, argv[i + 5]);
            if (fabs(a2) > 3 * Pi)
               runerr(101, argv[i + 5]);
            }
         if (fabs(a2) >= 2 * Pi) {
	    a2 = 2 * Pi;
	    }
         else {
            if (a2 < 0.0) {
               a1 += a2;
               a2 = fabs(a2);
               }
            }
         arcs[j].angle2 = EXTENT(a2);
         if (a1 < 0.0)
            a1 = 2 * Pi - fmod(fabs(a1), 2 * Pi);
         else
           a1 = fmod(a1, 2 * Pi);
         arcs[j].angle1 = ANGLE(a1);

         j++;
         }

      fillarcs(w, arcs, j);
      ReturnWindow;
      }
end

/*
 * FillCircle(w, x1, y1, r1, angle11, angle21, ...)
 */
"FillCircle(argv[]){1} - draw filled circle"

function{1} FillCircle(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0, r;

      OptWindow(w);
      r = docircles(w, argc - warg, argv + warg, 1);
      if (r < 0)
         ReturnWindow;
      else if (r >= argc - warg)
         runerr(146);
      else 
         runerr(102, argv[warg + r]);
      }
end

/*
 * FillPolygon(w, x1, y1, ...xN, yN)
 */
"FillPolygon(argv[]){1} - fill polygon"

function{1} FillPolygon(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, n, warg = 0;
      XPoint *points;
      int dx, dy;
      OptWindow(w);

#ifdef Graphics3D
      if (w->context->is_3D) {
         double *v, v2[256];
         struct descrip f, funcname;
         struct b_list *func;
	   
         /* create a list to save function information */
         Protect(func = alclist(0, MinListSlots), runerr(0));
         f.dword = D_List;
         f.vword.bptr = (union block *) func; 
         MakeStr("FillPolygon", 11, &funcname);
         c_put(&f, &funcname);

	 if (argc-warg > 256) {
	    v = calloc(argc-warg, sizeof (double));
	    if (v == NULL) runerr(305);
	    }
	 else v = v2;

         /* convert arguments and put them in the list */
         for(i = 0; i<argc-warg; i++) {
            if (!cnv:C_double(argv[warg + i], v[i])) {
	       if (v != v2) free(v);
               runerr(102, argv[warg+i]);
               }
            c_put(&f, &argv[warg+i]);
	    }
         /* draw polygons */
         c_put(&(w->window->funclist), &f);

         CheckArgMultiple(w->context->dim);
         drawpoly(w, v, argc-warg, GL_POLYGON, w->context->dim);
	 glFlush();
	 glXSwapBuffers(w->window->display->display, w->window->win);
	 if (v != v2) free(v);
	 return f;
	 }
      else 
#endif					/* Graphics3D */
      {
      CheckArgMultiple(2);

      /*
       * Allocate space for all the points in a contiguous array,
       * because a FillPolygon must be performed in a single call.
       */
      n = argc>>1;
      Protect(points = (XPoint *)malloc(sizeof(XPoint) * n), runerr(305));
      dx = w->context->dx;
      dy = w->context->dy;
      for(i=0; i < n; i++) {
	 int base = warg + i * 2;
	 CnvCShort(argv[base], points[i].x);
	 CnvCShort(argv[base + 1], points[i].y);
	 points[i].x += dx;
	 points[i].y += dy;
	 }
      fillpolygon(w, points, n);
      free(points);
      ReturnWindow;
       }
      }

end

/*
 * FillRectangle(w, x1, y1, width1, height1,...,xN, yN, widthN, heightN)
 */
"FillRectangle(argv[]){1} - draw filled rectangle"

function{1} FillRectangle(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int i, j, r, warg = 0;
      XRectangle recs[MAXXOBJS];
      C_integer x, y, width, height;

      OptWindow(w);
      j = 0;

      for (i = warg; i < argc || i == warg; i += 4) {
         r = rectargs(w, argc, argv, i, &x, &y, &width, &height);
         if (r >= 0)
            runerr(101, argv[r]);
         if (j == MAXXOBJS) {
            fillrectangles(w,recs,MAXXOBJS);
            j = 0;
            }
         RECX(recs[j]) = x;
         RECY(recs[j]) = y;
         RECWIDTH(recs[j]) = width;
         RECHEIGHT(recs[j]) = height;
         j++;
         }

      fillrectangles(w, recs, j);
      ReturnWindow;
      }
end



"Font(w,s) - get/set font"

function{0,1} Font(argv[argc])
   abstract {
      return string
      }
   body {
      tended char *tmp;
      int len;
      wbp w;
      int warg = 0;
      char buf[MaxCvtLen];
      OptWindow(w);

      if (warg < argc) {
         if (!cnv:C_string(argv[warg],tmp))
            runerr(103,argv[warg]);
         if (setfont(w,&tmp) == Failed) fail;
         }
      getfntnam(w, buf);
      len = strlen(buf);
      Protect(tmp = alcstr(buf, len), runerr(0));
      return string(len,tmp);
      }
end


"FreeColor(argv[]) - free colors"

function{1} FreeColor(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0;
      int i;
      C_integer n;
      tended char *s;

      OptWindow(w);
      if (argc - warg == 0) runerr(103);

      for (i = warg; i < argc; i++) {
         if (is:integer(argv[i])) {
            CnvCInteger(argv[i], n)
            if (n < 0)
               free_mutable(w, n);
            }
         else {
            if (!cnv:C_string(argv[i], s))
               runerr(103,argv[i]);
            freecolor(w, s);
            }
         }

      ReturnWindow;
      }

end


"GotoRC(w,r,c) - move cursor to a particular text row and column"

function{1} GotoRC(argv[argc])
   abstract {
      return file
      }
   body {
      C_integer r, c;
      wbp w;
      int warg = 0;
      OptWindow(w);

      if (argc - warg < 1)
	 r = 1;
      else
	 CnvCInteger(argv[warg], r)
      if (argc - warg < 2)
	 c = 1;
      else
	 CnvCInteger(argv[warg + 1], c)

      /*
       * turn the cursor off
       */
      hidecrsr(w->window);

      w->window->y = ROWTOY(w, r);
      w->window->x = COLTOX(w, c);
      w->window->x += w->context->dx;
      w->window->y += w->context->dy;

      /*
       * turn it back on at new location
       */
      UpdateCursorPos(w->window, w->context);
      showcrsr(w->window);

      ReturnWindow;
      }
end


"GotoXY(w,x,y) - move cursor to a particular pixel location"

function{1} GotoXY(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      C_integer x, y;
      int warg = 0;
      OptWindow(w);

      if (argc - warg < 1)
	 x = 0;
      else
	 CnvCInteger(argv[warg], x)
      if (argc - warg < 2)
	 y = 0;
      else
	 CnvCInteger(argv[warg + 1], y)

      x += w->context->dx;
      y += w->context->dy;

      hidecrsr(w->window);

      w->window->x = x;
      w->window->y = y;

      UpdateCursorPos(w->window, w->context);
      showcrsr(w->window);

      ReturnWindow;
      }
end


"Lower(w) - lower w to the bottom of the window stack"

function{1} Lower(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0;
      OptWindow(w);
      lowerWindow(w);
      ReturnWindow;
      }
end


"NewColor(w,s) - allocate an entry in the color map"

function{0,1} NewColor(argv[argc])
   abstract {
      return integer
      }
   body {
      wbp w;
      int rv;
      int warg = 0;
      OptWindow(w);

      if (mutable_color(w, argv+warg, argc-warg, &rv) == Failed) fail;
      return C_integer rv;
      }
end



"PaletteChars(w,p) - return the characters forming keys to palette p"

function{0,1} PaletteChars(argv[argc])
   abstract {
      return string
      }
   body {
      int n, warg;
      extern char c1list[], c2list[], c3list[], c4list[];

      if (is:file(argv[0]) && (BlkLoc(argv[0])->file.status & Fs_Window))
         warg = 1;
      else
         warg = 0;		/* window not required */
      if (argc - warg < 1)
         n = 1;
      else
         n = palnum(&argv[warg]);
      switch (n) {
         case -1:  runerr(103, argv[warg]);		/* not a string */
         case  0:  fail;				/* unrecognized */
         case  1:  return string(90, c1list);			/* c1 */
         case  2:  return string(9, c2list);			/* c2 */
         case  3:  return string(31, c3list);			/* c3 */
         case  4:  return string(73, c4list);			/* c4 */
         case  5:  return string(141, (char *)allchars);	/* c5 */
         case  6:  return string(241, (char *)allchars);	/* c6 */
         default:					/* gn */
            if (n >= -64)
               return string(-n, c4list);
            else
               return string(-n, (char *)allchars);
         }
      fail; /* NOTREACHED */ /* avoid spurious rtt warning message */
      }
end


"PaletteColor(w,p,s) - return color of key s in palette p"

function{0,1} PaletteColor(argv[argc])
   abstract {
      return string
      }
   body {
      int p, warg, len;
      char tmp[24], *s;
      struct palentry *e;
      tended struct descrip d;

      if (is:file(argv[0]) && (BlkLoc(argv[0])->file.status & Fs_Window))
         warg = 1;
      else
         warg = 0;			/* window not required */
      if (argc - warg < 2)
         runerr(103);
      p = palnum(&argv[warg]);
      if (p == -1)
         runerr(103, argv[warg]);
      if (p == 0)
         fail;
      if (!cnv:tmp_string(argv[warg + 1], d))
         runerr(103, argv[warg + 1]);
      if (StrLen(d) != 1)
         runerr(205, d);
      e = palsetup(p); 
      if (e == NULL)
         runerr(305);
      e += *StrLoc(d) & 0xFF;
      if (!e->valid)
         fail;
      sprintf(tmp, "%ld,%ld,%ld", e->clr.red, e->clr.green, e->clr.blue);
      len = strlen(tmp);
      Protect(s = alcstr(tmp, len), runerr(306));
      return string(len, s);
      }
end


"PaletteKey(w,p,s) - return key of closest color to s in palette p"

function{0,1} PaletteKey(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      int warg = 0, p;
      C_integer n;
      tended char *s;
      long r, g, b;

      if (is:file(argv[0]) && (BlkLoc(argv[0])->file.status & Fs_Window)) {
         w = (wbp)BlkLoc(argv[0])->file.fd;		/* explicit window */	
         warg = 1;
         }
      else if (is:file(kywd_xwin[XKey_Window]) &&
            (BlkLoc(kywd_xwin[XKey_Window])->file.status & Fs_Window))
         w = (wbp)BlkLoc(kywd_xwin[XKey_Window])->file.fd;	/* &window */
      else
         w = NULL;			/* no window (but proceed anyway) */

      if (argc - warg < 2)
         runerr(103);
      p = palnum(&argv[warg]);
      if (p == -1)
         runerr(103, argv[warg]);
      if (p == 0)
         fail;

      if (cnv:C_integer(argv[warg + 1], n)) {
         if (w == NULL || (s = get_mutable_name(w, n)) == NULL)
            fail;
         }
      else if (!cnv:C_string(argv[warg + 1], s))
         runerr(103, argv[warg + 1]);

      if (parsecolor(w, s, &r, &g, &b) == Succeeded)
         return string(1, rgbkey(p, r / 65535.0, g / 65535.0, b / 65535.0));
      else
         fail;
      }
end


"Pattern(w,s) - sets the context fill pattern by string name"

function{1} Pattern(argv[argc])
   abstract {
      return file
      }
   body {
      int warg = 0;
      wbp w;
      OptWindow(w);

      if (argc - warg == 0)
         runerr(103, nulldesc);

      if (! cnv:string(argv[warg], argv[warg]))
         runerr(103, nulldesc);

      switch (SetPattern(w, StrLoc(argv[warg]), StrLen(argv[warg]))) {
         case Error:
            runerr(0, argv[warg]);
         case Failed:
            fail;
         }

      ReturnWindow;
      }
end


"Pending(w,x[]) - produce a list of events pending on window"

function{0,1} Pending(argv[argc])
   abstract {
      return list
      }
   body {
      wbp w;
      int warg = 0;
      wsp ws;
      int i;
      int isclosed = 0;

      /* not using OptWindow() macro here since Pending() does no I/O */

      if (argc>warg && is:file(argv[warg])) {
         if ((BlkLoc(argv[warg])->file.status & Fs_Window) == 0)
	    runerr(140,argv[warg]);
         if ((BlkLoc(argv[warg])->file.status & Fs_Write) == 0)
	    isclosed = 1;

         w = (wbp)BlkLoc(argv[warg])->file.fd;
#ifdef ConsoleWindow
         if ((((FILE*)(w)) != ConsoleBinding) &&
	     ((((FILE*)(w)) == k_input.fd) || (((FILE*)(w)) == k_output.fd) ||
	      (((FILE*)(w)) == k_errout.fd)))
	   w = (wbp)OpenConsole();
#endif					/* ConsoleWindow */
         if (ISCLOSED(w))
	    isclosed = 1;
         warg++;
         }
      else {
         if (!(is:file(kywd_xwin[XKey_Window]) &&
	      (BlkLoc(kywd_xwin[XKey_Window])->file.status & Fs_Window)))
	    runerr(140,kywd_xwin[XKey_Window]);
	 if ((BlkLoc(kywd_xwin[XKey_Window])->file.status & (Fs_Read|Fs_Write))==0)
	    isclosed = 1;
         (w) = (wbp)BlkLoc(kywd_xwin[XKey_Window])->file.fd;
         if (ISCLOSED(w))
	    isclosed = 1;
         }

      ws = w->window;
      if (isclosed == 0)
	 wsync(w);

      /*
       * put additional arguments to Pending on the pending list in
       * guaranteed consecutive order.
       */
      for (i = warg; i < argc; i++) {
         c_put(&(ws->listp), &argv[i]);
         }

      /*
       * retrieve any events that might be relevant before returning the
       * pending queue.
       */
      switch (pollevent()) {
         case -1: runerr(141);
         case 0: fail;
	 }
      return ws->listp;
      }
end



"Pixel(w,x,y,width,height) - produce the contents of some pixels"

function{3} Pixel(argv[argc])
   abstract {
      return integer ++ string
      }
   body {
      struct imgmem imem;
      C_integer x, y, width, height;
      wbp w;
      int warg = 0, slen, r;
      tended struct descrip lastval;
      char strout[50];
      OptWindow(w);

      r = rectargs(w, argc, argv, warg, &x, &y, &width, &height);
      if (r >= 0)
         runerr(101, argv[r]);

      {
      int i, j;
      long rv;
      wsp ws = w->window;

#ifndef max
#define max(x,y) (((x)<(y))?(y):(x))
#define min(x,y) (((x)>(y))?(y):(x))
#endif

      imem.x = max(x,0);
      imem.y = max(y,0);
      imem.width = min(width, (int)ws->width - imem.x);
      imem.height = min(height, (int)ws->height - imem.y);

      if (getpixel_init(w, &imem) == Failed) fail;

      lastval = emptystr;

      for (j=y; j < y + height; j++) {
         for (i=x; i < x + width; i++) {
            getpixel(w, i, j, &rv, strout, &imem);
	
            slen = strlen(strout);
            if (rv >= 0) {
	       int signal;
               if (slen != StrLen(lastval) ||
                     strncmp(strout, StrLoc(lastval), slen)) {
                  Protect((StrLoc(lastval) = alcstr(strout, slen)), runerr(0));
                  StrLen(lastval) = slen;
                  }
#if COMPILER
               suspend lastval;		/* memory leak on vanquish */
#else					/* COMPILER */
	       /*
		* suspend, but free up imem if vanquished; RTL workaround.
		* Needs implementing under the compiler iconc.
		*/
	       r_args[0] = lastval;
	       if ((signal = interp(G_Fsusp, r_args)) != A_Resume) {
		  tend = r_tend.previous;
		  getpixel_term(w, &imem);
		  VanquishReturn(signal);
		  }
#endif					/* COMPILER */
               }
            else {
#if COMPILER
               suspend C_integer rv;	/* memory leak on vanquish */
#else					/* COMPILER */
	       int signal;
	       /*
		* suspend, but free up imem if vanquished; RTL workaround
		* Needs implementing under the compiler.
		*/
	       r_args[0].dword = D_Integer;
	       r_args[0].vword.integr = rv;
	       if ((signal = interp(G_Fsusp, r_args)) != A_Resume) {
		  tend = r_tend.previous;
		  getpixel_term(w, &imem);
		  VanquishReturn(signal);
		  }
#endif					/* COMPILER */
               }
            }
         }
      getpixel_term(w, &imem);
      fail;
      }
      }
end


"QueryPointer(w) - produce mouse position"

function{0,2} QueryPointer(w)

   declare {
      XPoint xp;
      }
   abstract {
      return integer
      }
   body {
      pollevent();
      if (is:null(w)) {
	 query_rootpointer(&xp);
	 }
      else {
	 if (!is:file(w) || !(BlkLoc(w)->file.status & Fs_Window))
	    runerr(140, w);
	 query_pointer((wbp)BlkLoc(w)->file.fd, &xp);
	 }
      suspend C_integer xp.x;
      suspend C_integer xp.y;
      fail;
      }
end


"Raise(w) - raise w to the top of the window stack"

function{1} Raise(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0;
      OptWindow(w);
      raiseWindow(w);
      ReturnWindow;
      }
end


"ReadImage(w, s, x, y, p) - load image file"

function{0,1} ReadImage(argv[argc])
   abstract {
      return integer
      }
   body {
      wbp w;
      char filename[MaxFileName + 1];
      tended char *tmp;
      int status, warg = 0;
      C_integer x, y;
      int p, r;
      struct imgdata imd;
      OptWindow(w);

      if (argc - warg == 0)
	 runerr(103,nulldesc);
      if (!cnv:C_string(argv[warg], tmp))
	 runerr(103,argv[warg]);

      /*
       * x and y must be integers; they default to the upper left pixel.
       */
      if (argc - warg < 2) x = -w->context->dx;
      else if (!def:C_integer(argv[warg+1], -w->context->dx, x))
         runerr(101, argv[warg+1]);
      if (argc - warg < 3) y = -w->context->dy;
      else if (!def:C_integer(argv[warg+2], -w->context->dy, y))
         runerr(101, argv[warg+2]);

      /*
       * p is an optional palette name.
       */
      if (argc - warg < 4 || is:null(argv[warg+3])) p = 0;
      else {
         p = palnum(&argv[warg+3]);
         if (p == -1)
            runerr(103, argv[warg+3]);
         if (p == 0)
            fail;
         }

      x += w->context->dx;
      y += w->context->dy;
      strncpy(filename, tmp, MaxFileName);   /* copy to loc that won't move*/
      filename[MaxFileName] = '\0';

      /*
       * First try to read as a GIF file.
       * If that doesn't work, try platform-dependent image reading code.
       */
      r = readGIF(filename, p, &imd);
      if (r != Succeeded) r = readBMP(filename, p, &imd);
      if (r == Succeeded) {
         status = strimage(w, x, y, imd.width, imd.height, imd.paltbl,
			   imd.data, (word)imd.width * (word)imd.height, 0);
         if (status < 0)
            r = Error;
         free((pointer)imd.paltbl);
         free((pointer)imd.data);
         }
      else if (r == Failed)
         r = readimage(w, filename, x, y, &status);
      if (r == Error)
         runerr(305);
      if (r == Failed)
         fail;
      if (status == 0)
         return nulldesc;
      else
         return C_integer (word)status;
      }
end



"WSync(w) - synchronize with server"

function{1} WSync(w)
   abstract {
      return file++null
      }
   body {
      wbp _w_;

      if (is:null(w)) {
	 _w_ = NULL;
	 }
      else if (!is:file(w)) runerr(140,w);
      else {
         if (!(BlkLoc(w)->file.status & Fs_Window))
            runerr(140,w);
         _w_ = (wbp)BlkLoc(w)->file.fd;
	 }

      wsync(_w_);
      pollevent();
      return w;
      }
end


"TextWidth(w,s) - compute text pixel width"

function{1} TextWidth(argv[argc])
   abstract {
      return integer
      }
   body {
      wbp w;
      int warg=0;
      C_integer i;
      OptWindow(w);

      if (warg == argc) runerr(103,nulldesc);
      else if (!cnv:tmp_string(argv[warg],argv[warg]))
	 runerr(103,argv[warg]);
       
      i = TEXTWIDTH(w, StrLoc(argv[warg]), StrLen(argv[warg]));
      return C_integer i;
      }
end


"Uncouple(w) - uncouple window"

function{1} Uncouple(w)
   abstract {
      return file
      }
   body {
      wbp _w_;
      if (!is:file(w)) runerr(140,w);
      if ((BlkLoc(w)->file.status & Fs_Window) == 0) runerr(140,w);
      if ((BlkLoc(w)->file.status & (Fs_Read|Fs_Write)) == 0) runerr(142,w);
      _w_ = (wbp)BlkLoc(w)->file.fd;
      BlkLoc(w)->file.status = Fs_Window; /* no longer open for read/write */
      free_binding(_w_);
      return w;
      }
end

"WAttrib(argv[]) - read/write window attributes"

function{*} WAttrib(argv[argc])
   abstract {
      return file++string++integer
      }
   body {
      wbp w, wsave;
      word n;
      tended struct descrip sbuf, sbuf2 = nulldesc;
      char answer[4096];
      int  pass, config = 0;
      int warg = 0;
      OptWindow(w);

      wsave = w;
      /*
       * Loop through the arguments.
       */

      for (pass = 1; pass <= 2; pass++) {
	 w = wsave;
	 if (config && pass == 2) {
	    if (do_config(w, config) == Failed) fail;
	    }
         for (n = warg; n < argc; n++) {
            if (is:file(argv[n])) {/* Current argument is a file */
               /*
                * Switch the current file to the file named by the
                *  current argument providing it is a file.  argv[n]
                *  is made to be a empty string to avoid a special case.
                */
               if (!(BlkLoc(argv[n])->file.status & Fs_Window))
                  runerr(140,argv[n]);
               w = (wbp)BlkLoc(argv[n])->file.fd;
	       if (config && pass == 2) {
		  if (do_config(w, config) == Failed) fail;
		  }
               }
            else {	/* Current argument should be a string */
	       /*
		* In pass 1, a null argument is an error; failed attribute
		*  assignments are turned into null descriptors for pass 2
		*  and are ignored.
		*/
               if (is:null(argv[n])) {
		  if (pass == 2)
		     continue;
		  else runerr(109, argv[n]);
		  }
               /*
                * If its an integer or real, it can't be a valid attribute.
                */
	       if (is:integer(argv[n]) || is:real(argv[n])) {
		  runerr(145, argv[n]);
		  }
               /*
                * Convert the argument to a string
                */
               if (!cnv:tmp_string(argv[n], sbuf)) 
                  runerr(109, argv[n]);
               /*
                * Read/write the attribute
                */
               if (pass == 1) {
            
		  char *tmp_s = StrLoc(sbuf);
		  char *tmp_s2 = StrLoc(sbuf) + StrLen(sbuf); 
		  for ( ; tmp_s < tmp_s2; tmp_s++)
		     if (*tmp_s == '=') break;
		  if (tmp_s < tmp_s2) {
		     /*
		      * pass 1: perform attribute assignments
		      */  


		     switch (wattrib(w, StrLoc(sbuf), StrLen(sbuf),
				     &sbuf2, answer)) {
		     case Failed:
		        /*
			 * Mark the attribute so we don't produce a result
			 */
		        argv[n] = nulldesc;
		        continue;
		     case Error: runerr(0, argv[n]);
               

		     }
		     if (StrLen(sbuf) > 4) {
			if (!strncmp(StrLoc(sbuf), "pos=", 4)) config |= 1;
			if (StrLen(sbuf) > 5) {
			   if (!strncmp(StrLoc(sbuf), "posx=", 5)) config |= 1;
			   if (!strncmp(StrLoc(sbuf), "posy=", 5)) config |= 1;
			   if (!strncmp(StrLoc(sbuf), "rows=", 5)) config |= 2;
			   if (!strncmp(StrLoc(sbuf), "size=", 5)) config |= 2;
			   if (StrLen(sbuf) > 6) {
			      if (!strncmp(StrLoc(sbuf), "width=", 6))
				 config |= 2;
			      if (!strncmp(StrLoc(sbuf), "lines=", 6))
				 config |= 2;
			      if (StrLen(sbuf) > 7) {
				 if (!strncmp(StrLoc(sbuf), "height=", 7))
				    config |= 2;
				 if (!strncmp(StrLoc(sbuf), "resize=", 7))
				    config |= 2;
				 if (StrLen(sbuf) > 8) {
				    if (!strncmp(StrLoc(sbuf), "columns=", 8))
				       config |= 2;
				    if (StrLen(sbuf) > 9) {
				       if (!strncmp(StrLoc(sbuf),
						    "geometry=", 9))
					  config |= 3;
				       }
				    }
				 }
			      }
			   }
			}
		     }
		  }
	       /*
		* pass 2: perform attribute queries, suspend result(s)
		*/
               else if (pass==2) {
		  char *stmp, *stmp2;
		  /*
		   * Turn assignments into queries.
		   */
 		  for( stmp = StrLoc(sbuf), 
 		      stmp2 = stmp + StrLen(sbuf); stmp < stmp2; stmp++)
 		     if (*stmp == '=') break;
 		  if (stmp < stmp2)
		     StrLen(sbuf) = stmp - StrLoc(sbuf);

		  switch (wattrib(w, StrLoc(sbuf), StrLen(sbuf),
				  &sbuf2, answer)) {
		  case Failed: continue;
		  case Error:  runerr(0, argv[n]);
		     }
		  if (is:string(sbuf2)) {
	             char *p=StrLoc(sbuf2);
		     Protect(StrLoc(sbuf2) = alcstr(StrLoc(sbuf2),StrLen(sbuf2)), runerr(0));
                     if (p != answer) free(p);
                     }
                  suspend sbuf2;
                  }
               }
            }
	 }
      fail;
      }
end


"WDefault(w,program,option) - get a default value from the environment"

function{0,1} WDefault(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      int warg = 0;
      long l;
      tended char *prog, *opt;
      char sbuf1[MaxCvtLen];
      OptWindow(w);

      if (argc-warg < 2)
         runerr(103);
      if (!cnv:C_string(argv[warg],prog))
         runerr(103,argv[warg]);
      if (!cnv:C_string(argv[warg+1],opt))
         runerr(103,argv[warg+1]);

      if (getdefault(w, prog, opt, sbuf1) == Failed) fail;
      l = strlen(sbuf1);
      Protect(prog = alcstr(sbuf1,l),runerr(0));
      return string(l,prog);
      }
end


"WFlush(w) - flush all output to window w"

function{1} WFlush(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int warg = 0;
      OptWindow(w);
      wflush(w);
      ReturnWindow;
      }
end


"WriteImage(w,filename,x,y,width,height) - write an image to a file"

function{0,1} WriteImage(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      int r;
      C_integer x, y, width, height, warg = 0;
      tended char *s;
      OptWindow(w);

      if (argc - warg == 0)
         runerr(103, nulldesc);
      else if (!cnv:C_string(argv[warg], s))
         runerr(103, argv[warg]);

      r = rectargs(w, argc, argv, warg + 1, &x, &y, &width, &height);
      if (r >= 0)
         runerr(101, argv[r]);

      /*
       * clip image to window, and fail if zero-sized.
       * (the casts to long are necessary to avoid unsigned comparison.)
       */
      if (x < 0) {
	 width += x;
	 x = 0;
         }
      if (y < 0) {
	 height += y;
	 y = 0;
         }
      if (x + width > (long) w->window->width)
	 width = w->window->width - x;
      if (y + height > (long) w->window->height)
	 height = w->window->height - y;
      if (width <= 0 || height <= 0)
	 fail;

      /*
       * try platform-dependent code first; it will reject the call
       * if the file name s does not specify a platform-dependent format.
       */
      r = dumpimage(w, s, x, y, width, height);
#if HAVE_LIBJPEG
      if ((r == NoCvt) &&
	  (strcmp(s + strlen(s)-4, ".jpg")==0 ||
          (strcmp(s + strlen(s)-4, ".JPG")==0))) {
	 r = writeJPEG(w, s, x, y, width, height);
         }
#endif					/* HAVE_LIBJPEG */
      if (r == NoCvt)
         r = writeBMP(w, s, x, y, width, height);
      if (r == NoCvt)
         r = writeGIF(w, s, x, y, width, height);
      if (r != Succeeded)
         fail;
      ReturnWindow;
      }
end

#ifdef MSWindows

"WinAssociate(ext) - return the application associated with an extension"

function{0,1} WinAssociate(ext)
   if !is:string(ext) then runerr(103, ext)
   abstract {
      return string
      }
   body {
      FILE *f;
      char fname[MAX_PATH];
      char buf[MAX_PATH];
      char *s = getenv("TEMP");
      int l;

      if (!s) strcpy(fname, ".\\");
      else strcpy(fname, s);
      if (fname[strlen(fname)-1] != '\\') strcat(fname, "\\");
      strcat(fname, "t.");
      fname[strlen(fname)+StrLen(ext)] = '\0';
      strncat(fname, StrLoc(ext), StrLen(ext));
      f = fopen(fname, "w");
      fclose(f);
      if ((int)(FindExecutable(fname, NULL, buf)) < 32) {
         unlink(fname);
         fail;
         }
      unlink(fname);
      l = strlen(buf);
      Protect(s = alcstr(buf, l),runerr(0));
      return string(l, s);
      }
end

"WinPlayMedia(w,x[]) - play a multimedia resource"

function{0,1} WinPlayMedia(argv[argc])
   abstract {
      return null
      }
   body {
      wbp w;
      tended char *tmp;
      int warg = 0;
      int i;
      wsp ws;
      word n;
      OptWindow(w);

      ws = w->window;
      for (n = warg; n < argc; n++) {
         if (!cnv:C_string(argv[n], tmp))
	    runerr(103,argv[warg]);
         if (playmedia(w, tmp) == Failed) fail;
         }
      return nulldesc;
      }
end



/*
 * Simple Windows-native pushbutton
 */
"WinButton(w, s, x, y, wd, ht) - install a pushbutton with label s on window w"

function{0,1} WinButton(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      wsp ws;
      int i, ii, i2, r, total = 0;
      C_integer x, y, width, height, warg = 0;
      tended char *s, *s2;
      tended struct descrip d;
      tended struct b_list *hp;
      OptWindow(w);
      ws = w->window;
      if (warg == argc) fail;
      if (!cnv:C_string(argv[warg], s)) runerr(103, argv[warg]);
      warg++;
      /*
       * look for an existing button with this id.
       */
      for(i = 0; i < ws->nChildren; i++) {
         if (!strcmp(s, ws->child[i].id) && ws->child[i].type==CHILD_BUTTON)
            break;
         }
      /*
       * create a new button if none is found
       */
      if (i == ws->nChildren) {
         ws->nChildren++;
         ws->child = realloc(ws->child,
			     ws->nChildren * sizeof(childcontrol));
	 makebutton(ws, ws->child + i, s);
         }

      if (warg >= argc) x = 0;
      else if (!def:C_integer(argv[warg], 0, x))
	 runerr(101, argv[warg]);
      warg++;
      if (warg >= argc) y = 0;
      else if (!def:C_integer(argv[warg], 0, y))
	 runerr(101, argv[warg]);
      warg++;
      /*
       * default width is width of text in system font + 2 chars
       */
      ii = sysTextWidth(w, s, strlen(s)) + 10;
      if (warg >= argc) width = ii;
      else if (!def:C_integer(argv[warg], ii, width))
	 runerr(101, argv[warg]);
      warg++;
      /*
       * default height is height of text in system font * 7/4
       */
      i2 = sysFontHeight(w) * 7 / 4;
      if (warg >= argc) height = i2;
      else if (!def:C_integer(argv[warg], i2, height))
	 runerr(101, argv[warg]);

      movechild(ws->child + i, x, y, width, height);
      ReturnWindow;
      }
end

"WinScrollBar(w, s, i1, i2, i3, x, y, wd, ht) - install a scrollbar"

function{0,1} WinScrollBar(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      wsp ws;
      C_integer x, y, width, height, warg = 0, i1, i2, i3, i, ii;
      tended char *s, *s2;
      tended struct descrip d;
      tended struct b_list *hp;

      OptWindow(w);
      ws = w->window;
      if (warg == argc) fail;
      if (!cnv:C_string(argv[warg], s)) runerr(103, argv[warg]);
      warg++;
      /*
       * look for an existing scrollbar with this id.
       */
      for(i = 0; i < ws->nChildren; i++) {
         if (!strcmp(s, ws->child[i].id) && ws->child[i].type==CHILD_EDIT)
            break;
         }
      /*
       * i1, the min of the scrollbar range, defaults to 0
       */
      if (warg >= argc) i1 = 0;
      else if (!def:C_integer(argv[warg], 0, i1)) runerr(101, argv[warg]);
      warg++;
      /*
       * i2, the max of the scrollbar range, defaults to 100
       */
      if (warg >= argc) i2 = 100;
      else if (!def:C_integer(argv[warg], 100, i2)) runerr(101, argv[warg]);
      warg++;
      /*
       * create a new scrollbar at end of array if none was found
       */
      if (i == ws->nChildren) {
         ws->nChildren++;
         ws->child = realloc(ws->child, ws->nChildren * sizeof(childcontrol));
	 makescrollbar(ws, ws->child + i, s, i1, i2);
         }
      /*
       * i3, the interval, defaults to 10
       */
      if (warg >= argc) i3 = 10;
      else if (!def:C_integer(argv[warg], 10, i3))
	 runerr(101, argv[warg]);
      warg++;
      /*
       * x defaults to the right edge of the window - system scrollbar width
       */
      ii = ws->width - sysScrollWidth();
      if (warg >= argc) x = ii;
      else if (!def:C_integer(argv[warg], ii, x))
	 runerr(101, argv[warg]);
      warg++;
      /*
       * y defaults to 0
       */
      if (warg >= argc) y = 0;
      else if (!def:C_integer(argv[warg], 0, y))
	 runerr(101, argv[warg]);
      warg++;
      /*
       * width defaults to system scrollbar width
       */
      ii = sysScrollWidth();
      if (warg >= argc) width = ii;
      else if (!def:C_integer(argv[warg], ii, width))
	 runerr(101, argv[warg]);
      warg++;
      /*
       * height defaults to height of the client window
       */
      if (warg >= argc) height = ws->height;
      else if (!def:C_integer(argv[warg], ws->height, height))
	 runerr(101, argv[warg]);

      movechild(ws->child + i, x, y, width, height);
      ReturnWindow;
      }
end

/*
 * Simple Windows-native menu bar
 */
"WinMenuBar(w,L1,L2,...) - install a set of top-level menus"

function{0,1} WinMenuBar(argv[argc])
   abstract {
      return file
      }
   body {
      wbp w;
      wsp ws;
      int i, total = 0;
      C_integer x, y, warg = 0;
      tended char *s;
      tended struct descrip d;
      OptWindow(w);
      ws = w->window;

      if (warg == argc) fail;
      for (i = warg; i < argc; i++) {
         if (!is:list(argv[i])) runerr(108, argv[i]);
         total += BlkLoc(argv[i])->list.size;
	 }
      /*
       * free up memory for the old menu map
       */
      if (ws->nmMapElems) {
         for (i=0; i<ws->nmMapElems; i++) free(ws->menuMap[i]);
         free(ws->menuMap);
         }
      ws->menuMap = (char **)calloc(total, sizeof(char *));

      if (nativemenubar(w, total, argc, argv, warg, &d) == Error)
        runerr(103, d);
      ReturnWindow;
      }
end

/*
 * Windows-native editor
 */
"WinEditRegion(w, s, s2, x, y, wd, ht) = install an edit box with label s"

function{0, 1} WinEditRegion(argv[argc])
   abstract {
      return file ++ string
      }
   body {
      wbp w;
      wsp ws;
      tended char *s, *s2;
      C_integer i, x, y, width, height, warg = 0;
      OptWindow(w);
      ws = w->window;
      if (warg == argc) fail;
      if (!cnv:C_string(argv[warg], s))
	 runerr(103, argv[warg]);
      warg++;
      /*
       * look for an existing edit region with this id.
       */
      for(i = 0; i < ws->nChildren; i++) {
         if (!strcmp(s, ws->child[i].id) && ws->child[i].type==CHILD_EDIT)
            break;
         }
      /*
       * create a new edit region if none is found
       */
      if (i == ws->nChildren) {
         ws->nChildren++;
         ws->child = realloc(ws->child, ws->nChildren * sizeof(childcontrol));
	 makeeditregion(w, ws->child + i, s);
         }
      /*
       * Invoked with no value, return the current value of an existing
       * edit region (entire buffer is one gigantic string).
       */
      else if (warg == argc) {
         geteditregion(ws->child + i, &result);
	 return result;
         }
      /*
       * Assign a value (s2 string contents) or perform editing command
       */
      if (is:null(argv[warg])) s2 = NULL;
      else if (!cnv:C_string(argv[warg], s2)) runerr(103, argv[warg]);
      warg++;

      if (warg >= argc) x = 0;
      else if (!def:C_integer(argv[warg], 0, x)) runerr(101, argv[warg]);
      warg++;
      if (warg >= argc) y = 0;
      else if (!def:C_integer(argv[warg], 0, y)) runerr(101, argv[warg]);
      warg++;
      if (warg >= argc) width = ws->width - x;
      else if (!def:C_integer(argv[warg], ws->width -x, width))
         runerr(101, argv[warg]);
      warg++;
      if (warg >= argc) height = ws->height - y;
      else if (!def:C_integer(argv[warg], ws->height - y, height))
         runerr(101, argv[warg]);

      if (s2 && !strcmp("!clear", s2)) {
         cleareditregion(ws->child + i);
         s2 = NULL;
         }
      else if (s2 && !strcmp("!copy", s2)) {
         copyeditregion(ws->child + i);
         s2 = NULL;
         }
      else if (s2 && !strcmp("!cut", s2)) {
         cuteditregion(ws->child + i);
         s2 = NULL;
         }
      else if (s2 && !strcmp("!paste", s2)) {
         pasteeditregion(ws->child + i);
         s2 = NULL;
         }
      else if (s2 && !strcmp("!undo", s2)) {
         if (undoeditregion(ws->child + i) == Failed) fail;
         s2 = NULL;
         }
      else if (s2 && !strncmp("!modified=", s2, 10)) {
         setmodifiededitregion(ws->child + i, atoi(s2+10));
         s2 = NULL;
         }
      else if (s2 && !strcmp("!modified", s2)) {
         if (modifiededitregion(ws->child + i) == Failed) fail;
         s2 = NULL;
         }
      else if (s2 && !strncmp("!font=", s2, 6)) {
	 if (setchildfont(ws->child + i, s2 + 6) == Succeeded) {
            ReturnWindow;
	    }
	 else fail;
         }
      else if (s2 && !strcmp("!setsel", s2)) {
	 setchildselection(ws, ws->child + i, x, y);
         ReturnWindow;
         }
      else if (s2 && !strcmp("!getsel", s2)) {
	 getchildselection(ws, ws->child + i, &x, &y);
	 suspend C_integer x + 1;
	 if (x != y) suspend C_integer y + 1;
         fail;
         }

      if (s2) {
         seteditregion(ws->child + i, s2);
	 }
      movechild(ws->child + i, x, y, width, height);
      setfocusonchild(ws, ws->child + i, width, height);
      ReturnWindow;
      }
end


/*
 * common dialog functions
 */

"WinColorDialog(w,s) - choose a color for a window's context"

function{0,1} WinColorDialog(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      C_integer x, y, width, height, warg = 0;
      long r, g, b;
      tended char *s;
      char buf[64], *tmp = buf;
      OptWindow(w);

      if (warg < argc) {
         if (is:null(argv[warg])) s = "white";
	 else if (!cnv:C_string(argv[warg], s)) runerr(103, argv[warg]);
         }
      else s = "white";
      if (parsecolor(w, s, &r, &g, &b) == Failed) fail;

      if (nativecolordialog(w, r, g, b, buf) == NULL) fail;
      StrLoc(result) = alcstr(buf, strlen(buf));
      StrLen(result) = strlen(buf);
      return result;
      }
end

"WinFontDialog(w,s) - choose a font for a window's context"

function{0,1} WinFontDialog(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      int r;
      C_integer x, y, width, height, warg = 0, fheight;
      int flags;
      tended char *s;
      char buf[64], *tmp = buf;
      OptWindow(w);

      if (warg < argc) {
         if (is:null(argv[warg])) s = "fixed";
	 else if (!cnv:C_string(argv[warg], s)) runerr(103, argv[warg]);
         }
      else s = "fixed";

      parsefont(s, buf, &flags, &fheight);

      if (nativefontdialog(w, buf, flags, fheight) == Failed) fail;
      StrLoc(result) = alcstr(buf, strlen(buf));
      StrLen(result) = strlen(buf);
      return result;
      }
end


"WinOpenDialog(w,s1,s2,i,s3,j) - choose a file to open"

function{0,1} WinOpenDialog(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      int len, slen;
      C_integer i, j, x, y, width, height, warg = 0;
      char buf2[64], buf3[256], chReplace;
      char *tmpstr;
      tended char *s1, *s2, *s3;
      OptWindow(w);

      if (warg >= argc || is:null(argv[warg])) {
         s1 = "Open:";
         }
      else if (!cnv:C_string(argv[warg], s1)) {
         runerr(103, argv[warg]);
         }
      warg++;

      if (warg >= argc || is:null(argv[warg])) {
         s2 = "";
         }
      else if (!cnv:C_string(argv[warg], s2)) {
         runerr(103, argv[warg]);
         }
      warg++;

      if (warg >= argc) {
         i = 50;
         }
      else if (!def:C_integer(argv[warg], 50, i)) {
         runerr(101, argv[warg]);
         }
      warg++;

      if (warg >= argc || is:null(argv[warg])) {
         strcpy(buf3,"All Files(*.*)|*.*|");
         s3 = buf3;
         }
      else if (!cnv:C_string(argv[warg], s3)) {
         runerr(103, argv[warg]);
         }
      else {
         strncpy(buf3, s3, 255);
	 buf3[255] = '\0';
	 s3 = buf3;
         }
      chReplace = s3[strlen(s3)-1];
      slen = strlen(s3);
      for(j=0; j < slen; j++)
         if(s3[j] == chReplace) s3[j] = '\0';
      warg++;

      if (warg >= argc) {
         j = 1;
         }
      else if (!def:C_integer(argv[warg], 1, j)) {
         runerr(101, argv[warg]);
         }
      warg++;

      if ((tmpstr = nativefiledialog(w, s1, s2, s3, i, j, 0)) == NULL) fail;
      len = strlen(tmpstr);
      StrLoc(result) = alcstr(tmpstr, len);
      StrLen(result) = len;
      return result;
      }
end


"WinSelectDialog(w, s1, buttons) - select from a set of choices"

function{0,1} WinSelectDialog(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      C_integer i, j, warg = 0, len;
      tended char *s1;
      char *s2 = NULL, *tmpstr;
      tended struct descrip d;
      tended struct b_list *hp;
      int lsize;
      OptWindow(w);

      /*
       * look for list of text for the message.  concatenate text strings.
       */
      if (warg == argc)
         fail;
      if (!is:list(argv[warg])) runerr(108, argv[warg]);
      hp  = (struct b_list *)BlkLoc(argv[warg]);
      lsize = hp->size;
      for(i=0; i < lsize; i++) {
         c_get(hp, &d);
         if (!cnv:C_string(d, s1)) runerr(103, d);
         len += strlen(s1)+2;
	 if (s2) {
	    s2 = realloc(s2, len);
	    if (!s2) fail;
            strcat(s2, "\r\n");
	    strcat(s2, s1);
	    }
	 else s2 = salloc(s1);
         c_put(&(argv[warg]), &d);
	 }
      warg++;

      if (warg >= argc) {
         hp = NULL;
         }
      else {
         if (!is:list(argv[warg])) runerr(108, argv[warg]);
         hp  = (struct b_list *)BlkLoc(argv[warg]);
         lsize = hp->size;
         for(i=0; i < lsize; i++) {
            c_get(hp, &d);
            if (!cnv:C_string(d, s1)) runerr(103, d);
            c_put(&(argv[warg]), &d);
            }
         }
      tmpstr = nativeselectdialog(w, hp, s2);
      if (tmpstr == NULL) fail;
      free(s2);
      len = strlen(tmpstr);
      StrLoc(result) = alcstr(tmpstr, len);
      StrLen(result) = len;
      return result;
      }
end

"WinSaveDialog(w,s1,s2,i,s3,j) - choose a file to save"

function{0,1} WinSaveDialog(argv[argc])
   abstract {
      return string
      }
   body {
      wbp w;
      int len;
      C_integer i, j, warg = 0, slen;
      char buf3[256], chReplace;
      tended char *tmpstr;
      tended char *s1, *s2, *s3;
      OptWindow(w);

      if (warg >= argc || is:null(argv[warg])) {
         s1 = "Save:";
         }
      else if (!cnv:C_string(argv[warg], s1)) {
         runerr(103, argv[warg]);
         }
      warg++;

      if (warg >= argc || is:null(argv[warg])) {
         s2 = "";
         }
      else if (!cnv:C_string(argv[warg], s2)) {
         runerr(103, argv[warg]);
         }
      warg++;

      if (warg >= argc) {
         i = 50;
         }
      else if (!def:C_integer(argv[warg], 50, i)) {
         runerr(101, argv[warg]);
         }
      warg++;

      if (warg >= argc || is:null(argv[warg])) {
         strcpy(buf3,"All Files(*.*)|*.*|");
         s3 = buf3;
         }
      else if (!cnv:C_string(argv[warg], s3)) {
         runerr(103, argv[warg]);
         }
      else {
         strcpy(buf3, s3);
	 s3 = buf3;
         }
      chReplace = s3[strlen(s3)-1];
      slen = strlen(s3);
      for(j=0; j < slen; j++)
         if(s3[j] == chReplace) s3[j] = '\0';
      warg++;

      if (warg >= argc) {
         j = 1;
         }
      else if (!def:C_integer(argv[warg], 1, j)) {
         runerr(101, argv[warg]);
         }
      warg++;
      if ((tmpstr = nativefiledialog(w, s1, s2, s3, i, j, 1)) == NULL) fail;
      len = strlen(tmpstr);
      StrLoc(result) = alcstr(tmpstr, len);
      StrLen(result) = len;
      return result;
      }
end
#else
MissingGraphicsFunc1(WinAssociate)
MissingGraphicsFuncV(WinPlayMedia)
MissingGraphicsFuncV(WinButton)
MissingGraphicsFuncV(WinScrollBar)
MissingGraphicsFuncV(WinMenuBar)
MissingGraphicsFuncV(WinEditRegion)
MissingGraphicsFuncV(WinColorDialog)
MissingGraphicsFuncV(WinFontDialog)
MissingGraphicsFuncV(WinOpenDialog)
MissingGraphicsFuncV(WinSelectDialog)
MissingGraphicsFuncV(WinSaveDialog)
#endif					/* MSWindows */


#else					/* Graphics */

MissingGraphicsFunc(Active)
MissingGraphicsFuncV(Alert)
MissingGraphicsFuncV(Bg)
MissingGraphicsFuncV(Clip)
MissingGraphicsFuncV(Clone)
MissingGraphicsFuncV(Color)
MissingGraphicsFuncV(ColorValue)
MissingGraphicsFuncV(CopyArea)
MissingGraphicsFuncV(Couple)
MissingGraphicsFuncV(DrawArc)
MissingGraphicsFuncV(DrawCircle)
MissingGraphicsFuncV(DrawCurve)
MissingGraphicsFuncV(DrawImage)
MissingGraphicsFuncV(DrawLine)
MissingGraphicsFuncV(DrawPoint)
MissingGraphicsFuncV(DrawPolygon)
MissingGraphicsFuncV(DrawRectangle)
MissingGraphicsFuncV(DrawSegment)
MissingGraphicsFuncV(DrawString)
MissingGraphicsFuncV(EraseArea)
MissingGraphicsFuncV(Event)
MissingGraphicsFuncV(Fg)
MissingGraphicsFuncV(FillArc)
MissingGraphicsFuncV(FillCircle)
MissingGraphicsFuncV(FillPolygon)
MissingGraphicsFuncV(FillRectangle)
MissingGraphicsFuncV(Font)
MissingGraphicsFuncV(FreeColor)
MissingGraphicsFuncV(GotoRC)
MissingGraphicsFuncV(GotoXY)
MissingGraphicsFuncV(Lower)
MissingGraphicsFuncV(NewColor)
MissingGraphicsFuncV(PaletteChars)
MissingGraphicsFuncV(PaletteColor)
MissingGraphicsFuncV(PaletteKey)
MissingGraphicsFuncV(Pattern)
MissingGraphicsFuncV(Pending)
MissingGraphicsFuncV(Pixel)
MissingGraphicsFunc1(QueryPointer)
MissingGraphicsFuncV(Raise)
MissingGraphicsFuncV(ReadImage)
MissingGraphicsFuncV(TextWidth)
MissingGraphicsFunc1(Uncouple)
MissingGraphicsFuncV(WAttrib)
MissingGraphicsFuncV(WDefault)
MissingGraphicsFuncV(WFlush)
MissingGraphicsFuncV(WriteImage)
MissingGraphicsFunc1(WSync)
MissingGraphicsFunc1(WinAssociate)
MissingGraphicsFuncV(WinPlayMedia)
MissingGraphicsFuncV(WinButton)
MissingGraphicsFuncV(WinScrollBar)
MissingGraphicsFuncV(WinMenuBar)
MissingGraphicsFuncV(WinEditRegion)
MissingGraphicsFuncV(WinColorDialog)
MissingGraphicsFuncV(WinFontDialog)
MissingGraphicsFuncV(WinOpenDialog)
MissingGraphicsFuncV(WinSelectDialog)
MissingGraphicsFuncV(WinSaveDialog)

#endif					/* Graphics */


#if defined(Graphics) && defined(Graphics3D)

/*
 * DrawTorus(w,x,y,z,radius1,radius2,...)
 *
 */
"DrawTorus(argv[]) - draw a torus"

function{1} DrawTorus(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int n, i, j, warg = 0, nfields;
      double r1, r2, x, y, z;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;

      OptWindow(w);
      CheckArgMultiple(5);
	
      /* tori are not allowed in a 2-dim space */
      if (w->context->dim == 2) 
         runerr(150);

      if (!constr && !(constr = rec_structor3d("gl_torus")))
	 syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      for (i = warg; i < argc; i += 5) {

	 /* convert parameters and draw torus*/
         if (!cnv:C_double(argv[i], x))    runerr(102, argv[i]);  
         if (!cnv:C_double(argv[i+1], y))  runerr(102, argv[i+1]);
         if (!cnv:C_double(argv[i+2], z))  runerr(102, argv[i+2]);
         if (!cnv:C_double(argv[i+3], r1)) runerr(102, argv[i+3]);
         if (!cnv:C_double(argv[i+4], r2)) runerr(102, argv[i+4]);
	 torus(r1, r2, x, y, z, (w->context->texmode ? w->context->autogen:0));

	 /* create a record of the graphical object */	   
	 Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
	 f.dword = D_Record;
	 f.vword.bptr = (union block *)rp;
         MakeStr("DrawTorus", 9, &(rp->fields[0])); /* r.name */
         for(j = i; j < i + 5; j++)
	    rp->fields[1 + j-i] = argv[j];
         c_put(&(w->window->funclist), &f);
         }
   
	/* Since we are using double buffers, swap */
      glXSwapBuffers(w->window->display->display, w->window->win);
      return f;
   }
end

/*
 * DrawCube(w,x,y,z,length,...)
 *
 */
"DrawCube(argv[]){1} - draw a cube"

function{1} DrawCube(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int n, i, j, warg = 0, nfields;
      double l, x, y, z;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;

      OptWindow(w);		
      CheckArgMultiple(4);

      /* Cubes are not 2-dim objects */
      if (w->context->dim == 2) 
	 runerr(150);	

      if (!constr)
	 if (!(constr = rec_structor3d("gl_cube")))
	    syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      for(i = warg; i < argc; i += 4) {
 
	 /* convert parameters and draw a cube */
         if (!cnv:C_double(argv[i], x))	  runerr(102, argv[i]);
         if (!cnv:C_double(argv[i+1], y)) runerr(102, argv[i+1]);
         if (!cnv:C_double(argv[i+2], z)) runerr(102, argv[i+2]);
         if (!cnv:C_double(argv[i+3], l)) runerr(102, argv[i+3]);  
	 cube(l, x, y, z, (w->context->texmode?w->context->autogen:0));
        
	 /*
	  * create a record of the graphical object and its parameters
	  */
	 Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
	 f.dword = D_Record;
	 f.vword.bptr = (union block *)rp;
         MakeStr("DrawCube", 8, &(rp->fields[0]));
         for(j = i; j < i + 4; j++)
            rp->fields[1 + j - i] = argv[j];
         c_put(&(w->window->funclist), &f);
         }

      /* swap buffers, since we are double buffered */
      glXSwapBuffers(w->window->display->display, w->window->win);
      return f;
      }
end


/*
 * DrawSphere(w,x,y,z,radius,...)
 *
 */
"DrawSphere(argv[]){1} - draw a sphere"

function{1} DrawSphere(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, n, i, j, nfields;
      double r, x, y, z;
      tended struct b_record *rp;
      struct descrip f;
      static dptr constr;

      OptWindow(w);
      CheckArgMultiple(4);

      /* sphere cannot be drawn in a 2-dim scene */
      if (w->context->dim == 2) runerr(150);

      if (!constr)
	 if (!(constr = rec_structor3d("gl_sphere")))
	    syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      for(i = warg; i < argc; i += 4) {

	 /* convert parameters and draw a sphere */
	 if (!cnv:C_double(argv[i], x))    runerr(102, argv[i]);
	 if (!cnv:C_double(argv[i+1], y))  runerr(102, argv[i+1]);
	 if (!cnv:C_double(argv[i+2], z))  runerr(102, argv[i+2]);
	 if (!cnv:C_double(argv[i+3], r))  runerr(102, argv[i+3]); 
	 sphere(r, x, y, z, (w->context->texmode?w->context->autogen:0));

	 /* create a record of the graphical object */
	 Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
	 f.dword = D_Record;
	 f.vword.bptr = (union block *)rp;
	 MakeStr("DrawSphere", 10, &(rp->fields[0])); /* r.name */

	 /* put parameter in the list for the function */
	 rp->fields[1] = argv[i];
	 rp->fields[2] = argv[i+1];
	 rp->fields[3] = argv[i+2];
	 rp->fields[4] = argv[i+3];
	 c_put(&(w->window->funclist), &f);
	 }

	/* swap buffers */
	glXSwapBuffers(w->window->display->display, w->window->win);
	return f;
    }
end


/*
 * DrawCylinder(w,x,y,z,height,radius1,radius2,...)
 *
 */
"DrawCylinder(argv[]){1} - draw a cylinder"

function{1} DrawCylinder(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, n, i, j, nfields;
      double r1, r2, h, x, y, z;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;

      OptWindow(w);
      CheckArgMultiple(6);

      /* cylinders cannot be used in a 2-dim scene */
      if (w->context->dim == 2) runerr(150);

      if (!constr)
	 if (!(constr = rec_structor3d("gl_cylinder")))
	    syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      for(i = warg; i < argc; i += 6) {

	 /* convert parameters and draw a cylinder */
	 if (!cnv:C_double(argv[i], x))    runerr(102, argv[i]);
         if (!cnv:C_double(argv[i+1], y))  runerr(102, argv[i+1]);
         if (!cnv:C_double(argv[i+2], z))  runerr(102, argv[i+2]);
	 if (!cnv:C_double(argv[i+3], h))  runerr(102, argv[i+3]);  
	 if (!cnv:C_double(argv[i+4], r1)) runerr(102, argv[i+4]);
	 if (!cnv:C_double(argv[i+5], r2)) runerr(102, argv[i+5]);
	 cylinder(r1, r2, h,x,y,z,(w->context->texmode?w->context->autogen:0));

	 /* create a record of the graphical object */
	 Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
         f.dword = D_Record;
         f.vword.bptr = (union block *) rp;
         MakeStr("DrawCylinder", 12, &(rp->fields[0])); /* r.name */

	   /* put parameters in the list */
         for(j = i; j < i + 6; j++)
	    rp->fields[1 + j - i] = argv[j];
         c_put(&(w->window->funclist), &f);
         }

      /* swap buffers */
      glXSwapBuffers(w->window->display->display, w->window->win);
      return f;
   }
end


/*
 * DrawDisk(w,x,y,z,radius1,radius2,...)
 *
 */

"DrawDisk(argv[]){1} - draw a disk"

function{1} DrawDisk(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, n, j, i, nfields;
      double r1, r2, a1, a2, x, y, z;
      struct descrip f;
      static dptr constr;
      tended struct b_record *rp;

      OptWindow(w);

      if (!constr)
	 if (!(constr = rec_structor3d("gl_disk")))
	    syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      for (i = warg; i < argc; i += 7) {
	 if (argc-warg <= i+3)
	    runerr(146);

	 /* create a record of the graphical object */
	 Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
	 f.dword = D_Record;
	 f.vword.bptr = (union block *)rp;
	 MakeStr("DrawDisk", 8, &(rp->fields[0])); /* r.name */

	 if (!cnv:C_double(argv[i], x))   runerr(102, argv[i]);
	 if (!cnv:C_double(argv[i+1], y)) runerr(102, argv[i+1]);
	 if (!cnv:C_double(argv[i+2], z)) runerr(102, argv[i+2]);
	 if (!cnv:C_double(argv[i+3], r1)) runerr(102, argv[i+3]);
	 if (!cnv:C_double(argv[i+4], r2)) runerr(102, argv[i+4]);
	 rp->fields[1] = argv[i];
	 rp->fields[2] = argv[i+1];
	 rp->fields[3] = argv[i+2];
	 rp->fields[4] = argv[i+3];
	 rp->fields[5] = argv[i+4];

	 if (i+5 >= argc) {
	    a1 = 0.0;
	    rp->fields[6] = zerodesc;
	    }
	 else {
	    if (!cnv:C_double(argv[i+5],a1)) runerr(102, argv[i+5]);
	    rp->fields[6] = argv[i+5];
	    }

	 if (i+6 >= argc) {
	    a2 = 360;
            MakeInt(360, &(rp->fields[7])); 
	    }
	 else {
	    if (!cnv:C_double(argv[i+6], a2)) runerr(102, argv[i+6]);
	    rp->fields[7] = argv[i+6];
	    }

	 disk(r1, r2, a1, a2, x, y, z,
	      (w->context->texmode ? w->context->autogen : 0));
         c_put(&(w->window->funclist), &f);
        }

      glXSwapBuffers(w->window->display->display, w->window->win);
      return f;
      }
end


/*
 * Eye(w,px,py,pz,dx,dy,dz,ux,uy,yz) - get/set eye attributes
 *
 */

"Eye(argv[]){1} - get/set eye attributes"

function{1} Eye(argv[argc])
    abstract{ return record }
    body {
      wbp w;
      wcp wc;
      int warg = 0, n, i=0, len;
      double x;
      char abuf[128];

      OptWindow(w);
      wc = w->context;

      while (warg+i < argc && i < 9) {
	 if (!is:null(argv[warg+i]))
	    if (!cnv:C_double(argv[warg+i], x))
               runerr(102, argv[warg+i]);
	 switch (i) {
	 case 0: wc->eyeposx = x; break;
	 case 1: wc->eyeposy = x; break;
	 case 2: wc->eyeposz = x; break;
	 case 3: wc->eyedirx = x; break;
	 case 4: wc->eyediry = x; break;
	 case 5: wc->eyedirz = x; break;
	 case 6: wc->eyeupx = x; break;
	 case 7: wc->eyeupy = x; break;
	 case 8: wc->eyeupz = x; break;
	    }
	 i++;
	 }

      if (warg < argc) redraw3D(w);

      sprintf(abuf,"%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f",
	      wc->eyeposx, wc->eyeposy, wc->eyeposz, wc->eyedirx,
	      wc->eyediry, wc->eyedirz, wc->eyeupx, wc->eyeupy, wc->eyeupz);
      len = strlen(abuf);
      StrLoc(result) = alcstr(abuf, len);
      StrLen(result) = len;
      return result;
      }
end

/*
 * Rotate(w,angle,x,y,z,...)
 *
 */

"Rotate(argv[]){1} - rotates objects"

function{1} Rotate(argv[argc])
    abstract{ return record }
    body {
      wbp w;
      int warg = 0, n, i, j, nfields;
      double x, y, z, angle;
      struct descrip f;
      tended struct b_record *rp;

      OptWindow(w);
      CheckArgMultiple(4);

      for(i = warg; i < argc-warg; i = i+4) {
	 if (j = rotate(w, argv, i, &f)) {
	    if (j == 1) runerr(0);
	    else runerr(102, argv[-j-1]);
	    }
         }
      return f;
    }
end


/*
 * Translate(w,x,y,z,...)
 *
 */
"Translate(argv[]){1} - translates objects"

function{1} Translate(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, i, j, n;
      struct descrip f;
      static dptr constr;

      OptWindow(w);
      CheckArgMultiple(3);

      for(i = warg; i < argc-warg; i = i+3) {
	 if (j = translate(w, argv, i, &f)) {
	    if (j == 1) runerr(0);
	    else runerr(102, argv[-j-1]);
	    }
         }
      return f;
   }
end


/*
 * Scale(w,x,y,z,...)
 *
 */

"Scale(argv[]){1} - scales objects"

function{1} Scale(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, n, i, j;
      double x, y, z;
      struct descrip f = nulldesc;

      OptWindow(w);
      CheckArgMultiple(3);

      for(i = warg; i < argc-warg; i = i+3) {
	 if (j=scale(w, argv, i, &f)) {
	    if (j == 1) runerr(0);
	    else runerr(102, argv[-j-1]);
	    }
	 }
      return f;
      }
end

/*
 * PopMatrix(w)
 *
 */
"PopMatrix(argv[]){1} - pop the matrix stack"

function{1} PopMatrix(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, n, nfields, npops, i;
      struct descrip f;  
      tended struct b_record *rp;
      static dptr constr;

      OptWindow(w);

      if (argc == warg) npops = 1;
      else if (!def:C_integer(argv[warg], 1, npops))
	 runerr(101, argv[warg]);

      if (!constr)
	 if (!(constr = rec_structor3d("gl_popmatrix")))
	    syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      for (i=0; i<npops; i++) {

	 /* pop matrix from the matrix stack, if possible */
	 if (popmatrix() == Failed)
	    runerr(151);

	 /*
	  * create a record of the graphical object and its parameters
	  */
	 Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
	 f.dword = D_Record;
	 f.vword.bptr = (union block *)rp;
	 MakeStr("PopMatrix", 9, &(rp->fields[0]));
	 c_put(&(w->window->funclist), &f);	
	 }
      return f;
      }  
end


/*
 * PushMatrix(w)
 *
 */

"PushMatrix(argv[]){1} - push a copy of the top matrix onto the matrix stack"

function{1} PushMatrix(argv[argc])
   abstract{ return record }
   body {
      wbp w;
      int warg = 0, n, nfields;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;
 
      OptWindow(w);

      if (!constr && !(constr = rec_structor3d("gl_pushmatrix")))
	 syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      /* push a copy of the top matrix, if possible */
      if (pushmatrix() == 0)
	 runerr(151);

      /*
       * create a record of the graphical object
       */
      Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
      f.dword = D_Record;
      f.vword.bptr = (union block *)rp;
      MakeStr("PushMatrix", 10 ,&(rp->fields[0]));
      c_put(&(w->window->funclist), &f);	
      return f;
      }
end
    

"PushTranslate(argv[]){1} - push a copy of the top matrix onto the matrix stack and apply translations"

function{2} PushTranslate(argv[argc])
abstract { return record }
body {
      wbp w;
      int warg = 0, i, j, n;
      struct descrip f, f2;
 
      OptWindow(w);
      CheckArgMultiple(3);

      if (j = pushmatrix_rd(w, &f)) {
	 if (j == 151) runerr(j);
	 else if (j == -1) runerr(0);
	 }

      for(i = warg; i < argc-warg; i = i+3) {
	 if (j = translate(w, argv, i, &f2)) {
	    if (j == 1) runerr(0);
	    else runerr(102, argv[-j-1]);
	    }
         }

      suspend f;
      return f2;
      }
end


"PushRotate(argv[]){1} - push a copy of the top matrix onto the matrix stack and apply rotations"

function{2} PushRotate(argv[argc])
abstract { return record }
body {
      wbp w;
      int warg = 0, i, j, n;
      struct descrip f, f2;
 
      OptWindow(w);
      CheckArgMultiple(4);

      if (j = pushmatrix_rd(w, &f)) {
	 if (j == 151) runerr(j);
	 else if (j == -1) runerr(0);
	 }

      for(i = warg; i < argc-warg; i = i+4) {
	 if (j = rotate(w, argv, i, &f2)) {
	    if (j == 1) runerr(0);
	    else runerr(102, argv[-j-1]);
	    }
         }

      suspend f;
      return f2;
      }
end


"PushScale(argv[]){1} - push a copy of the top matrix onto the matrix stack and apply scales"

function{2} PushScale(argv[argc])
abstract { return record }
body {
      wbp w;
      int warg = 0, i, j, n;
      struct descrip f, f2;
 
      OptWindow(w);
      CheckArgMultiple(3);

      if (j = pushmatrix_rd(w, &f)) {
	 if (j == 151) runerr(j);
	 else if (j == -1) runerr(0);
	 }

      for(i = warg; i < argc-warg; i = i+3) {
	 if (j = scale(w, argv, i, &f2)) {
	    if (j == 1) runerr(0);
	    else runerr(102, argv[-j-1]);
	    }
         }

      suspend f;
      return f2;
      }
end

/*
 * IdentityMatrix(w)
 */
"IdentityMatrix(argv[]){1} - change the top matrix to the identity"

function{1} IdentityMatrix(argv[argc])
   abstract { return record }
   body {
      wbp w;
      int warg = 0, n, nfields;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;

      OptWindow(w);

      if (!constr)
	 if (!(constr = rec_structor3d("gl_identity")))
	    syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      /*
       * create a record of the graphical object and its parameters
       */
      Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
      f.dword = D_Record;
      f.vword.bptr = (union block *)rp;
      MakeStr("LoadIdentity", 12, &(rp->fields[0]));
      c_put(&(w->window->funclist), &f);

      /* load identity matrix */
      glLoadIdentity();
      return f;
   }
end


/*
 * MatrixMode(w, s)
 *
 */
"MatrixMode(argv[]){1} - use the matrix stack specified by s"

function{1} MatrixMode(argv[argc])
   abstract { return record }
   body {
      wbp w; 
      int warg = 0, n, nfields;
      tended char* temp;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;
            
      OptWindow(w);
  	
      if (!constr & !(constr = rec_structor3d("gl_matrixmode")))
	 syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      /*
       * create a record of the graphical object and its parameters
       */
      Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
      f.dword = D_Record;
      f.vword.bptr = (union block *)rp;
      MakeStr("MatrixMode", 10, &(rp->fields[0]));

      /* convert parameter */	
      if (!cnv:C_string(argv[warg],temp)) runerr(103,argv[warg]); 

      /* check the value of s and switch matrix stacks */
      if (!strcmp("modelview", temp))
	 glMatrixMode(GL_MODELVIEW);	
      else if (!strcmp("projection", temp))
	 glMatrixMode(GL_PROJECTION);
      else 
         runerr(152, argv[warg]);

      /* put parameter in the list */
      rp->fields[1] = argv[warg];
      c_put(&(w->window->funclist), &f);
      return f;
      }
end

/* 
 * Texture (w, s) or Texture (w1, w2) 
 * 
 */

"Texture(argv[]){1} - apply the texture defined by the string s or use the window w2 as a texture "

function{1} Texture(argv[argc])
   abstract{ return record }
   body {
      wbp w, w2;
      wcp wc;
      int warg = 0, nfields;
      unsigned char *s;
      char filename[MaxFileName + 1];
      tended char* tmp;
      struct descrip f;
      tended struct b_record *rp;
      static dptr constr;

      OptWindow(w);
      wc = w->context;
      if (argc - warg < 1)/* missing texture source */
         runerr(103);	

      if (!constr && !(constr = rec_structor3d("gl_texture")))
	 syserr("failed to create opengl record constructor");
      nfields = (int) ((struct b_proc *)BlkLoc(*constr))->nfields;

      /*
       * create a record of the graphical object and its parameters
       */
      Protect(rp = alcrecd(nfields, BlkLoc(*constr)), runerr(0));
      f.dword = D_Record;
      f.vword.bptr = (union block *)rp;
      MakeStr("Texture", 7, &(rp->fields[0])); 

      /*
       * to redraw a texture we must know the texture name assigned by opengl
       * This name is stored in w->context->texName[w->context->ntexture]. so
       * we put w->context->ntexture in the list.
       */
      MakeInt(wc->ntextures, &(rp->fields[1]));
      c_put(&(w->window->funclist), &f);
      glBindTexture(GL_TEXTURE_2D, wc->texName[wc->ntextures]);
      wc->curtexture = wc->ntextures;
      wc->ntextures++;
      if (wc->ntextures > wc->nalced) {
         wc->nalced *= 2;
         wc->texName = realloc(wc->texName, wc->nalced * sizeof(GLuint));
         glGenTextures(wc->nalced / 2, wc->texName + wc->nalced / 2);
         }
  
      /* check if the source is another window */
      if (argc>warg && is:file(argv[warg])) {
	 if ((BlkLoc(argv[warg])->file.status & Fs_Window) == 0)
	    runerr(140,argv[warg]);
	 if ((BlkLoc(argv[warg])->file.status & (Fs_Read|Fs_Write)) == 0)
	    runerr(142,argv[warg]);
	 w2 = (wbp)BlkLoc(argv[warg])->file.fd;
	 if (ISCLOSED(w2))
	    runerr(142,argv[warg]);

	 /* convert the window into a texture */
         if (w2->context->is_3D)
            texwindow3D(w, w2);
         else
            texwindow2D(w2); 
         return f;
	 }

      /* otherwise it must be a string */
      if (!cnv:C_string(argv[warg], tmp)) runerr(103, argv[warg]);
      s = tmp;
      while(isspace(*s)) s++;
      while(isdigit(*s)) s++;
      while(isspace(*s)) s++; 

      if (*s == ',') { /* must be an image string */
	 if (imagestr(w, tmp) != Succeeded)
	    runerr(153, argv[warg]);
	 }
      else {  /* it is a file name */
	 strncpy(filename, tmp, MaxFileName);
	 filename[MaxFileName] = '\0';
	 if (fileimage(w, filename) != Succeeded)
	    runerr(153, argv[warg]);
	 }
      return f; 
      }
end


/* 
 * Texcoord (w, s) or Texture (w, L) 
 */

"Texcoord(argv[]){1} - set texture coordinate to those defined by the string s or the list L "

function{1} Texcoord(argv[argc])
   abstract { return list }
   body {
      wbp w;
      wcp wc;
      int i, warg = 0;
      char filename[MaxFileName + 1];
      tended char* tmp;
      tended struct descrip f, funcname, mode, val;
      tended struct b_list *func, *coords;

      OptWindow(w);

      wc = w->context;
      if (argc-warg < 1) /* missing the texture coordinates */
	 runerr(103);

      /* create a list */ 
      Protect(func = alclist(0, MinListSlots), runerr(0));
      f.dword = D_List; 
      f.vword.bptr = (union block*) func; 
      MakeStr("Texcoord", 8, &funcname); 
      c_put(&f, &funcname);
     
      /* check if the argument is a list */
      if (argv[argc-warg].dword == D_List) {
         if (glIsEnabled(GL_TEXTURE_GEN_S))
            glDisable(GL_TEXTURE_GEN_S);
         if (glIsEnabled(GL_TEXTURE_GEN_T))
            glDisable(GL_TEXTURE_GEN_T); 
         mode = zerodesc;
         c_put(&f, &mode);
         wc->autogen = 0; 
         wc->numtexcoords = 0;
         coords = (struct b_list*) argv[argc-warg].vword.bptr;
	 if (coords->size > MAXTEXCOORDS) fail;
         for (i = 0; i < coords->size; i++) {
            c_traverse(coords, &val, i); 
            if (!cnv:C_double(val, wc->texcoords[i]))
               runerr(102, val);
            c_put(&f, &val);
            wc->numtexcoords++;
	    }
	 }
      else {
	 if (argc-warg == 1) { /* probably "auto" */
	    if (!cnv:C_string(argv[warg], tmp))
	       runerr(103, argv[warg]); 
	    if (!strcmp(tmp, "auto")){
	       wc->autogen = 1;
	       wc->numtexcoords = 0;
	       if (!glIsEnabled(GL_TEXTURE_GEN_S))
		  glEnable(GL_TEXTURE_GEN_S);
	       if (!glIsEnabled(GL_TEXTURE_GEN_T))
		  glEnable(GL_TEXTURE_GEN_T); 
	       mode = onedesc;
	       c_put(&f, &mode);
	       }
	    else fail;
	    }
	 /* the arguments are texture coordinates */
	 else {
	    if (glIsEnabled(GL_TEXTURE_GEN_S))
	       glDisable(GL_TEXTURE_GEN_S);
	    if (glIsEnabled(GL_TEXTURE_GEN_T))
	       glDisable(GL_TEXTURE_GEN_T); 
	    mode = zerodesc;
	    c_put(&f, &mode);
	    wc->autogen = 0; 
	    wc->numtexcoords = 0;
	    if (argc - warg > MAXTEXCOORDS) fail;
	    for (i = warg; i < argc; i++) {
	       if (!cnv:C_double(argv[i], wc->texcoords[wc->numtexcoords++]))
		  runerr(102, argv[i]);
	       c_put(&f, &argv[i]);
	       }
	    }
	 }
      /* there must be an even number of arguments */
      if (wc->numtexcoords % 2  != 0) {
	 runerr(154);
         }
      c_put(&(w->window->funclist), &f);
      return f; 
      }
end

/* 
 * Refresh(w) 
 */

"Refresh(argv[]){1} - redraws the window"

function{1} Refresh(argv[argc])
   abstract{ return file }
   body {
      wbp w;
      int i, warg = 0;
      OptWindow(w);

      redraw3D(w);
      ReturnWindow; 

   }
end

/* 
 * WindowContents(w) 
 * 
 */

"WindowContents(argv[]){1} - returns an Icon list of lists, which contains all objects drawn on window"

function{1} WindowContents(argv[argc])
   abstract{ return list }
   body {
      wbp w;
      int i, warg = 0;
      OptWindow(w);

      
      return w->window->funclist; 

   }
end

#else					/* Graphics3D */
MissingGraphicsFuncV(DrawTorus)
MissingGraphicsFuncV(DrawCube)
MissingGraphicsFuncV(DrawSphere)
MissingGraphicsFuncV(DrawCylinder)
MissingGraphicsFuncV(DrawDisk)
MissingGraphicsFuncV(Eye)
MissingGraphicsFuncV(PushMatrix)
MissingGraphicsFuncV(PushRotate)
MissingGraphicsFuncV(PushScale)
MissingGraphicsFuncV(PushTranslate)
MissingGraphicsFuncV(PopMatrix)
MissingGraphicsFuncV(IdentityMatrix)
MissingGraphicsFuncV(MatrixMode)
MissingGraphicsFuncV(Scale)
MissingGraphicsFuncV(Rotate)
MissingGraphicsFuncV(Translate)
MissingGraphicsFuncV(Texture)
MissingGraphicsFuncV(Texcoord)
MissingGraphicsFuncV(Refresh)
MissingGraphicsFuncV(WindowContents)
#endif					/* Graphics3D */
