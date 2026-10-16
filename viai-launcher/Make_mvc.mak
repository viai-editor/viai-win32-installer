#
# VIM - Vi IMproved	ViAI launcher
#

all: gviai.exe viai.exe

CFLAGS=/nologo /c /GS- /GF /O2 /W4
LDFLAGS=/nologo /NODEFAULTLIB /MAP
RCFLAGS=/nologo
LIBS=kernel32.lib advapi32.lib user32.lib shlwapi.lib


# GUI
gviai.exe: gviai.obj gviai.res
	link $(LDFLAGS) /subsystem:windows /entry:wWinMainCRTStartup /out:$@ $(LIBS) $**

gviai.obj: viai-launcher.c
	$(CC) $(CFLAGS) /DFEAT_GUI /Fo$@ $**

gviai.res: viai-launcher.rc viai-launcher.manifest viai-launcher.ico
	$(RC) $(RCFLAGS) /DFEAT_GUI /Fo$@ viai-launcher.rc


# Console
viai.exe: viai.obj viai.res
	link $(LDFLAGS) /subsystem:console /entry:wmainCRTStartup /out:$@ $(LIBS) $**

viai.obj: viai-launcher.c
	$(CC) $(CFLAGS) /Fo$@ $**

viai.res: viai-launcher.rc viai-launcher.manifest viai-launcher.ico
	$(RC) $(RCFLAGS) /Fo$@ viai-launcher.rc


clean:
	-del gviai.exe gviai.map gviai.obj gviai.res
	-del viai.exe viai.map viai.obj viai.res
