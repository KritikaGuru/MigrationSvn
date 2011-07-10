/*
 * File: rwinsys.r
 *  Window-system-specific window support routines.
 *  This file simply includes an appropriate r*win.ri file.
 */

void checkpollevent(){
#ifdef Graphics
   while (!kbhit()) { idelay(100); pollevent(); }
#endif					/* Graphics */
}

#ifdef Graphics

#ifdef MacGraph
#include "rmac.ri"
#endif					/* MacGraph */

#ifdef PresentationManager
#include "rpmwin.ri"
#endif					/* PresentationManager */

#ifdef XWindows
#include "rxwin.ri"
#endif					/* XWindows */

#ifdef MSWindows
#include "rmswin.ri"
#else
#endif  				/* MSWindows */

#ifdef Graphics3D
#if HAVE_LIBGL
#include "ropengl.ri"
#endif					/* HAVE_LIBGL */
#if HAVE_D3D
#include "rd3d.ri"
#endif					/* HAVE_D3D */
#endif					/* Graphics3D */

#else					/* Graphics */
#if NT
int main(int argc, char *argv[])
{
   return iconx(argc, argv);
}
#endif					/* NT */
static char junk;		/* avoid empty module */
#endif					/* Graphics */
