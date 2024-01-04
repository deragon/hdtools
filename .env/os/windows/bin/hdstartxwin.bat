REM ─ Copyright Notice ───────────────────────────────────────────────────
REM
REM Copyright 2000-2024 Hans Deragon - AGPL 3.0 licence.
REM
REM Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
REM released under the GNU Affero General public Picense which can be found at:
REM
REM     https://www.gnu.org/licenses/agpl-3.0.en.html
REM
REM ─────────────────────────────────────────────────── Copyright Notice ─

@echo off
SET DISPLAY=127.0.0.1:0.0

SET CYGWIN_ROOT=\cygwin
SET PATH=.;%CYGWIN_ROOT%\bin;%CYGWIN_ROOT%\usr\X11R6\bin;%PATH%

REM
REM Cleanup after last run.
REM

if not exist %CYGWIN_ROOT%\tmp\.X11-unix\X0 goto CLEANUP-FINISH
attrib -s %CYGWIN_ROOT%\tmp\.X11-unix\X0
del %CYGWIN_ROOT%\tmp\.X11-unix\X0

:CLEANUP-FINISH
if exist %CYGWIN_ROOT%\tmp\.X11-unix rmdir %CYGWIN_ROOT%\tmp\.X11-unix

REM
REM Startup the X Server, the twm window manager, and an xterm.
REM 
REM Notice that the window manager and the xterm will wait for
REM the server to finish starting before trying to connect; the
REM error "Cannot Open Display: 127.0.0.1:0.0" is not due to the
REM clients attempting to connect before the server has started, rather
REM that error is due to a bug in some versions of cygwin1.dll.  Upgrade
REM to the latest cygwin1.dll if you get the "Cannot Open Display" error.
REM See the Cygwin/XFree86 FAQ for more information:
REM http://xfree86.cygwin.com/docs/faq/
REM
REM The error "Fatal server error: could not open default font 'fixed'" is
REM caused by using a DOS mode mount for the mount that the Cygwin/XFree86
REM fonts are accessed through.  See the Cygwin/XFree86 FAQ for more 
REM information:
REM http://xfree86.cygwin.com/docs/faq/cygwin-xfree-faq.html#q-error-font-eof
REM

if "%OS%" == "Windows_NT" goto OS_NT

REM Windows 95/98/Me
echo startxwin.bat - Starting on Windows 95/98/Me

goto STARTUP

:OS_NT

REM Windows NT/2000/XP
echo startxwin.bat - Starting on Windows NT/2000/XP

:STARTUP


REM
REM Startup the programs
REM 

REM Startup the X Server.

start XWin :0 -query world

xmodmap ~/env/xmodmap.us_intl
