mkdir ..\..\..\bin
copy makefile.top ..\..\..\makefile
copy DEFINE.H ..\..\..\src\h
copy PATH.H ..\..\..\src\h
copy auto.h ..\..\..\src\h
copy autogdbm.h ..\..\..\src\gdbm\autoconf.h
copy RSWITCH.C ..\..\..\src\common
rem copy RSWITCH.ASM ..\..\..\src\common
copy ICONT.LNK ..\..\..\src\icont
copy ICONX.LNK ..\..\..\src\runtime
echo CONSOLE=NTConsole >..\..\..\src\common\makefile
type MAKEFILE.CMN >>..\..\..\src\common\makefile
copy MAKEFILE.RTT ..\..\..\src\rtt\makefile
echo ICONX=iconx >..\..\..\src\runtime\makefile
type MAKEFILE.RUN >>..\..\..\src\runtime\makefile
echo ICONT=icont >..\..\..\src\icont\makefile
echo CONSOLE=NTConsole >>..\..\..\src\icont\makefile
type MAKEFILE.T >>..\..\..\src\icont\makefile
copy makefile.dbm ..\..\..\src\gdbm\makefile
echo ICONT=..\..\bin\icont >..\..\..\ipl\lib\makefile
type makefile.ipl >> ..\..\..\ipl\lib\makefile
echo ICONT=..\..\bin\icont >..\..\..\uni\unicon\makefile
echo COPY=copy >>..\..\..\uni\unicon\makefile
echo RM=-del >> ..\..\..\uni\unicon\makefile
echo EXE=.exe >> ..\..\..\uni\unicon\makefile
echo BINDIR=..\..\bin >> ..\..\..\uni\unicon\makefile
echo UNICON=..\unicon\unicon >> ..\..\..\uni\unicon\makefile
type makefile.uni >>..\..\..\uni\unicon\makefile
echo RM=-del > ..\..\..\uni\ivib\makefile
echo EXE=.exe >> ..\..\..\uni\ivib\makefile
echo BINDIR=..\..\bin >> ..\..\..\uni\ivib\makefile
echo UNICON=..\unicon\unicon -G >> ..\..\..\uni\ivib\makefile
echo COPY=copy >> ..\..\..\uni\ivib\makefile
echo MAKE=nmake >> ..\..\..\uni\ivib\makefile
echo IVIB2=ivib2win >> ..\..\..\uni\ivib\makefile
type makefile.ivb >>..\..\..\uni\ivib\makefile
echo RM=-del > ..\..\..\uni\lib\makefile
echo EXE=.exe >> ..\..\..\uni\lib\makefile
echo BINDIR=..\..\bin >> ..\..\..\uni\lib\makefile
echo UNICON=..\unicon\unicon >> ..\..\..\uni\lib\makefile
type ..\..\unix\Config\unilib.mak >>..\..\..\uni\lib\makefile
del ..\..\..\src\icont\*.obj 2> nul
del ..\..\..\src\common\*.obj 2> nul
del ..\..\..\src\runtime\*.obj 2> nul
copy RTT.LNK ..\..\..\src\rtt
type makefile.ide > ..\..\..\uni\ide\makefile
