# -*- coding: utf-8 -*-
# NSIS file to create a self-installing exe for ViAI.
# It requires NSIS version 3.0 or later.
# Last Change:	2026-06-19
#

Unicode true  ; !include defaults to UTF-8 after Unicode True since 3.0 Alpha 2

# WARNING: if you make changes to this script, look out for $0 to be valid,
# because uninstall deletes most files in $0.

!ifndef PLUG_ENVAR
  !define PLUG_ENVAR  ..\EnVar_plugin
!endif
!ifndef PLUG_NSISMULTIUSER
  !define PLUG_NSISMULTIUSER  ..\NsisMultiUser
!endif
!addplugindir /x86-unicode "${PLUG_ENVAR}\Plugins\x86-unicode"
!addplugindir /x86-unicode "${PLUG_NSISMULTIUSER}\Plugins\x86-unicode"
!addincludedir "${PLUG_NSISMULTIUSER}\Include"

# Top directory of the ViAI repository
!ifndef SRC
  !define SRC "..\viai"
!endif

# Location of gviai.exe, viai.exe, etc.
!ifndef VIMBIN
  !define VIMBIN "${SRC}\src"
!endif

# Location of runtime files and GviaiExt*/*
!ifndef VIMRT
  !define VIMRT "${SRC}\runtime"
!endif

# Location of extra tools: diff.exe, winpty{32|64}.dll, winpty-agent.exe, etc.
!ifndef VIMTOOLS
  !define VIMTOOLS "${VIMBIN}"
!endif

# Location of viai-launcher
!ifndef VIMLAUNCHER
  !define VIMLAUNCHER "..\viai-launcher"
!endif

# If you have UPX, use the switch /DHAVE_UPX=1 on the command line makensis.exe.
# This property will be set to 1. Get it at https://upx.github.io/
!ifndef HAVE_UPX
  !define HAVE_UPX 0
!endif

# if you want to create a 64-bit installer, use the switch /DWIN64=1 on
# the command line makensis.exe. This property will be set to 1.
!ifndef WIN64
  !define WIN64 0
!endif

# if you want to create the installer for ARM64, use the /DARM64=1 on
# the command line makensis.exe. This property will be set to 1.
!ifndef ARM64
  !define ARM64 0
!else
  !if ${ARM64} > 0
    !if ${WIN64} < 1
      !define /redef WIN64 1
    !endif
  !endif
!endif

# if you don't want to include libgcc_s_sjlj-1.dll in the package, use the
# switch /DINCLUDE_LIBGCC=0 on the command line makensis.exe.
!ifndef INCLUDE_LIBGCC
  !define INCLUDE_LIBGCC 1
!endif

# Get version numbers
!getdllversion "${VIMBIN}\gviai.exe" VimVer_
!echo "ViAI version MAJOR=${VimVer_1} MINOR=${VimVer_2} PATCHLEVEL=${VimVer_3}"

!ifndef VER_MAJOR
  !define VER_MAJOR  ${VimVer_1}
!endif
!ifndef VER_MINOR
  !define VER_MINOR  ${VimVer_2}
!endif
!ifndef PATCHLEVEL
  !define PATCHLEVEL ${VimVer_3}
!endif

# ----------- No configurable settings below this line -----------

##########################################################
# Installer Attributes, Including headers, Plugins and etc.

CRCCheck force

!ifndef DEBUG
  # Disable these when debugging. They are slow.
  SetCompressor /SOLID lzma
  SetCompressorDictSize 64
  SetDatablockOptimize on
!endif

!ifdef DEBUG
  !macro DebugPrint str
    System::Call "kernel32::OutputDebugString(t `${str}`) v"
  !macroend
!else
  !macro DebugPrint str
  !macroend
!endif

!if ${HAVE_UPX}
  !packhdr temp.dat "upx.exe --best --compress-icons=1 temp.dat"
!endif

ManifestDPIAware true
# https://github.com/NSIS-Dev/nsis/blob/691211035c2aaaebe8fbca48ee02d4de93594a52/Docs/src/attributes.but#L292
ManifestDPIAwareness "PerMonitorV2,System"
ManifestSupportedOS \
    {35138b9a-5d96-4fbd-8e2d-a2440225f93a} /* WinNT 6.1 (7) */ \
    {4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38} /* WinNT 6.2 (8) */ \
    {1f676c76-80e1-4239-95bb-83d0f6d0da78} /* WinNT 6.3 (8.1) */ \
    {8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a} /* WinNT 10/11 */

!if ${WIN64}
  !define BIT 64
  !if ${ARM64}
    !define PLATFORM  "ARM64"
  !else
    !define PLATFORM  "x64"
  !endif
!else
  !define BIT 32
  !define PLATFORM  "x86"
!endif

!define PRODUCT_NAME	"ViAI"
!define VERSION_SHORT	"${VER_MAJOR}.${VER_MINOR}"
!define VERSION		"${VER_MAJOR}.${VER_MINOR}.${PATCHLEVEL}"
!define PRODUCT_AND_VER	"${PRODUCT_NAME} ${VERSION_SHORT}"
!define PRODUCT_FULL	"${PRODUCT_NAME} ${VERSION_SHORT} (${PLATFORM})"
!define PROGEXE		"gviai.exe"
!define COMPANY_NAME	"The ViAI Project"
!define PRODUCT_REG_KEY	"Software\${PRODUCT_NAME}"
!define INSTDIR_REG_VALNAME   "path"
!define INSTMODE_REG_VALNAME  "mode"
!define INSTLANG_REG_VALNAME  "Installer Language"
!define UNINST_REG_KEY	      "Software\Microsoft\Windows\CurrentVersion\Uninstall"
!define UNINST_REG_KEY_NAME   "${PRODUCT_NAME}"
!define UNINST_REG_KEY_VIM    "${UNINST_REG_KEY}\${UNINST_REG_KEY_NAME}"
!define GVIMEXT_CLSID	      "{F191A2A2-D786-484E-A3F4-8A75FDD9AC00}"
!define VIMRUNTIME_DIR_NAME   "runtime"	  # "vim${VER_MAJOR}${VER_MINOR}"
!define UNINSTALL_FILENAME    "uninstall-gui.exe"

; NsisMultiUser optional defines
!define MULTIUSER_INSTALLMODE_ALLOW_BOTH_INSTALLATIONS 1
!define MULTIUSER_INSTALLMODE_ALLOW_ELEVATION 1
!define MULTIUSER_INSTALLMODE_ALLOW_ELEVATION_IF_SILENT 1 ; required for silent-mode allusers-uninstall to work, when using the workaround for Windows elevation bug
!define MULTIUSER_INSTALLMODE_DEFAULT_ALLUSERS 1
!if ${WIN64}
  !define MULTIUSER_INSTALLMODE_64_BIT 1
!endif
!define MULTIUSER_INSTALLMODE_DISPLAYNAME "${PRODUCT_FULL}"
!define MULTIUSER_INSTALLMODE_UNINSTALL_REGISTRY_KEY "${UNINST_REG_KEY_NAME}"
!define MULTIUSER_INSTALLMODE_NO_HELP_DIALOG 1	# Use our own cmdline help

Name "${PRODUCT_FULL}"
OutFile gviai${VER_MAJOR}${VER_MINOR}.exe
BrandingText "ViAI - Vim Advanced Integrated"

# Types of installs we can perform:
InstType $(str_type_typical)
InstType $(str_type_minimal)
InstType $(str_type_full)

SilentInstall normal

##########################################################
# Version resources

VIFileVersion ${VER_MAJOR}.${VER_MINOR}.${PATCHLEVEL}.0
VIProductVersion ${VER_MAJOR}.${VER_MINOR}.${PATCHLEVEL}.0
VIAddVersionKey /LANG=0 "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=0 "CompanyName" "${COMPANY_NAME}"
VIAddVersionKey /LANG=0 "LegalTrademarks" "ViAI"
VIAddVersionKey /LANG=0 "LegalCopyright"  "Copyright (C) 1996"
VIAddVersionKey /LANG=0 "FileDescription" "ViAI - Vim Advanced Integrated"
VIAddVersionKey /LANG=0 "ProductVersion"  "${VER_MAJOR}.${VER_MINOR}.${PATCHLEVEL}.0"
VIAddVersionKey /LANG=0 "FileVersion"	  "${VER_MAJOR}.${VER_MINOR}.${PATCHLEVEL}.0"

##########################################################
# including headers

!include "UAC.nsh"
!include "NsisMultiUser.nsh"
!include "Library.nsh"		; for DLL install
!include "LogicLib.nsh"
!include "MUI2.nsh"		; new user interface
!include "nsDialogs.nsh"
!include "Sections.nsh"		; for section control
!include "x64.nsh"
!include "FileFunc.nsh"

#!include .\auxiliary.nsh	; helper file; Conflicts with NsisMultiUser. Include later.

##########################################################
# MUI2 settings

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

!define MUI_ICON   "icons\in_viai_32bpp.ico"
!define MUI_UNICON "icons\un_viai_32bpp.ico"

# Show all languages, despite user's codepage:
!define MUI_LANGDLL_ALLLANGUAGES
# Always show dialog choice language
#!define MUI_LANGDLL_ALWAYSSHOW
!define MUI_LANGDLL_REGISTRY_ROOT	"SHCTX"
!define MUI_LANGDLL_REGISTRY_KEY	"${PRODUCT_REG_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME  "${INSTLANG_REG_VALNAME}"

!define MUI_WELCOMEFINISHPAGE_BITMAP	"icons\in_welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP	"icons\un_welcome.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP		"icons\in_header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP	"icons\un_header.bmp"

!define MUI_WELCOMEFINISHPAGE_BITMAP_STRETCH	"AspectFitHeight"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP_STRETCH	"AspectFitHeight"
!define MUI_HEADERIMAGE_BITMAP_STRETCH		"AspectFitHeight"
!define MUI_HEADERIMAGE_UNBITMAP_STRETCH	"AspectFitHeight"

!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_TEXT		$(str_show_readme)
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION	LaunchApplication


# Installer pages:
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageWelcomeLicensePre
!insertmacro MUI_PAGE_WELCOME

!define MUI_PAGE_CUSTOMFUNCTION_PRE PageWelcomeLicensePre
!insertmacro MUI_PAGE_LICENSE $(page_lic_file)

!insertmacro MULTIUSER_PAGE_INSTALLMODE

!define MUI_PAGE_CUSTOMFUNCTION_PRE PageComponentsPre
!insertmacro MUI_PAGE_COMPONENTS

Page custom SetCustom ValidateCustom

!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages:
!insertmacro MULTIUSER_UNPAGE_INSTALLMODE
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_UNPAGE_FINISH

!include .\auxiliary.nsh	; helper file; must be after MULTIUSER_PAGE_INSTALLMODE

##########################################################
# Languages Files

!insertmacro MUI_RESERVEFILE_LANGDLL
!include "lang\english.nsi"

# Include support for other languages:
!include "lang\danish.nsi"
!include "lang\dutch.nsi"
!include "lang\french.nsi"
!include "lang\german.nsi"
!include "lang\greek.nsi"
!include "lang\italian.nsi"
!include "lang\japanese.nsi"
!include "lang\portuguesebr.nsi"
!include "lang\russian.nsi"
!include "lang\serbian.nsi"
!include "lang\simpchinese.nsi"
!include "lang\swedish.nsi"
!include "lang\tradchinese.nsi"
!include "lang\turkish.nsi"

!insertmacro MULTIUSER_LANGUAGE_INIT

##########################################################
# Global variables
Var vim_dialog
Var vim_nsd_compat
Var vim_nsd_keymap
Var vim_nsd_mouse
Var vim_compat_stat
Var vim_keymap_stat
Var vim_mouse_stat
Var settings_loaded

##########################################################
# Reserve files
#ReserveFile ${VIMBIN}\install.exe

##########################################################
# Functions

# Find uninstaller of old versions of ViAI.
# return: uninstall command. If not found, it will be empty.
Function FindOldUninstaller
  Push $0
  Push $R0
  Push $R1
  Push $R2

  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}

  ClearErrors
  StrCpy $0 ""   ; uninstaller path
  StrCpy $R0 0   ; Sub-key index
  StrCpy $R1 ""  ; Sub-key
  ${Do}
    # Enumerate the sub-key:
    EnumRegKey $R1 SHCTX ${UNINST_REG_KEY} $R0

    # Stop if no more sub-key:
    ${If} ${Errors}
    ${OrIf} $R1 == ""
      ${ExitDo}
    ${EndIf}

    # Move to the next sub-key:
    IntOp $R0 $R0 + 1

    # Check if the key is ViAI uninstall key or not:
    StrCpy $R2 $R1 5
    ${If} $R1 S!= "ViAI"
    ${AndIf} $R2 S!= "ViAI "  # Installed by install.exe
      ${Continue}
    ${EndIf}

    # Verifies required sub-keys:
    ReadRegStr $R2 SHCTX "${UNINST_REG_KEY}\$R1" "DisplayName"
    ${If} ${Errors}
    ${OrIf} $R2 == ""
      ${Continue}
    ${EndIf}

    ReadRegStr $R2 SHCTX "${UNINST_REG_KEY}\$R1" "UninstallString"
    ${If} ${Errors}
    ${OrIf} $R2 == ""
      ${Continue}
    ${EndIf}

    # Found
    StrCpy $0 $R2
    ${ExitDo}

  ${Loop}

  ${If} ${RunningX64}
    SetRegView lastused
  ${EndIf}

  Pop $R2
  Pop $R1
  Pop $R0
  Exch $0  ; put $0 on top of stack, restore $0 to original value
FunctionEnd

Function LaunchApplication
  SetOutPath $INSTDIR

  ; The installer might exit too soon before the application starts and it
  ; loses the right to be the foreground window and starts in the background
  ; however, if there's no active window when the application starts, it will
  ; become the active window, so we hide the installer
  HideWindow
  ${If} ${UAC_IsInnerInstance}
    ; The installer will show itself again quickly before closing (w/o Taskbar
    ; button), we move it offscreen
    !define SWP_NOSIZE 0x0001
    !define SWP_NOZORDER 0x0004
    System::Call "User32::SetWindowPos(i, i, i, i, i, i, i) b ($HWNDPARENT, 0, -1000, -1000, 0, 0, ${SWP_NOZORDER}|${SWP_NOSIZE})"
  ${EndIf}

  !insertmacro UAC_AsUser_ExecShell "" "$INSTDIR\${PROGEXE}" '-c "help viai"' "" ""
FunctionEnd

##########################################################
# Installer Functions and Sections

${StrLoc}

# Uninstall old version
Section "$(str_section_old_ver)" id_section_old_ver
  SectionIn 1 2 3 RO

  DetailPrint "$(str_msg_uninstalling)"
  SetDetailsPrint listonly  # Keep the above message while waiting for uninstallation
  ${Do}
    call FindOldUninstaller
    Pop $3
    ${If} $3 == ""
      ${ExitDo}
    ${Else}
      StrCpy $4 $3 1
      ${If} $4 == '"'
	# Split uninstaller path ($3) and params ($4)
	StrCpy $4 $3 "" 1	  # Cut the first '"'
	${StrLoc} $5 $4 '"' ">"   # Find the next '"'
	StrCpy $3 $4 $5		  # Extract inside quotes
	IntOp $5 $5 + 1
	StrCpy $4 $4 "" $5
      ${Else}
	StrCpy $4 ""
      ${EndIf}

      # Copy the uninstaller to a tempfile and run with the _?= option.
      # This is required to wait for the uninstaller to finish.
      GetTempFileName $5
      CopyFiles $3 "$5.exe"
      Delete $5
      ${GetParent} $3 $6
      ExecWait '"$5.exe" $4 /S _?=$6'
      Delete "$5.exe"

      # TODO: Check if the old version is still remaining.
      # If remaining, should we show a warning and run the uninstaller again?

      ${ExitDo}  ; Just ignore for now.
    ${EndIf}
  ${Loop}
  SetDetailsPrint lastused

  # We may have been put to the background when uninstall did something.
  # -- If the user activates another window while running the uninstaller,
  #    bringing the installer window to front might be unexpected.
  #BringToFront
SectionEnd

##########################################################
# GViAI and runtime files
Section "$(str_section_exe)" id_section_exe
  SectionIn 1 2 3 RO

  # User variables:
  # $0 - holds the directory the runtime files are installed to
  StrCpy $0 "$INSTDIR\${VIMRUNTIME_DIR_NAME}"

  # Binary files
  SetOutPath $INSTDIR
  File ${VIMBIN}\gviai.exe
  !if /FileExists "${VIMBIN}\viai${BIT}.dll"
    File ${VIMBIN}\viai${BIT}.dll
  !endif
  File ${VIMBIN}\viairun.exe
  File ${VIMBIN}\tee.exe
  File ${VIMBIN}\xxd.exe

  # Create hard links
  ReadEnvStr $3 "COMSPEC"
  nsExec::Exec '"$3" /c mklink /h gviaidiff.exe gviai.exe'
  Pop $4
  nsExec::Exec '"$3" /c mklink /h eviai.exe gviai.exe'
  Pop $4

  !if /FileExists "${VIMTOOLS}\diff.exe"
    File ${VIMTOOLS}\diff.exe
  !endif
  !if /FileExists "${VIMTOOLS}\winpty${BIT}.dll"
    File ${VIMTOOLS}\winpty${BIT}.dll
  !endif
  !if /FileExists "${VIMTOOLS}\winpty-agent.exe"
    File ${VIMTOOLS}\winpty-agent.exe
  !endif
  !if /FileExists "${VIMTOOLS}\libsodium.dll"
    File ${VIMTOOLS}\libsodium.dll
  !endif

  !if /FileExists "${SRC}\LICENSE"
    File /oname=LICENSE.txt ${SRC}\LICENSE
  !else
    File /oname=LICENSE.txt ${SRC}\LICENSE.txt
  !endif
  File /oname=LICENSE-APACHE.txt ${SRC}\LICENSE-APACHE
  File ${SRC}\uninstall.txt

  # Runtime files
  SetOutPath $0
  File ${VIMRT}\*.vim

  SetOutPath $0\colors
  File /r ${VIMRT}\colors\*.*

  SetOutPath $0\compiler
  File ${VIMRT}\compiler\*.*

  SetOutPath $0\doc
  File /x uganda.nsis.txt ${VIMRT}\doc\*.txt
  File ${VIMRT}\doc\tags

  SetOutPath $0\ftplugin
  File ${VIMRT}\ftplugin\*.*

  SetOutPath $0\indent
  File ${VIMRT}\indent\README.txt
  File ${VIMRT}\indent\*.vim

  SetOutPath $0\keymap
  File ${VIMRT}\keymap\README.txt
  File ${VIMRT}\keymap\*.vim

  SetOutPath $0\macros
  File /r /x *.info ${VIMRT}\macros\*.*

  SetOutPath $0\pack
  File /r ${VIMRT}\pack\*.*

  SetOutPath $0\plugin
  File ${VIMRT}\plugin\*.*

  SetOutPath $0\autoload
  File /r ${VIMRT}\autoload\*.*

  SetOutPath $0\import\dist
  File ${VIMRT}\import\dist\*.*

  SetOutPath $0\bitmaps
  File ${VIMBIN}\viai.ico

  SetOutPath $0\syntax
  File /r /x testdir /x generator /x Makefile ${VIMRT}\syntax\*.*

  SetOutPath $0\spell
  File ${VIMRT}\spell\*.txt
  File ${VIMRT}\spell\*.vim
  File ${VIMRT}\spell\*.spl
  File ${VIMRT}\spell\*.sug

  SetOutPath $0\tools
  File ${VIMRT}\tools\*.*

  SetOutPath $0\tutor
  File /r /x *.info ${VIMRT}\tutor\*.*

  # OLE
  ${If} $MultiUser.InstallMode == "AllUsers"
    ExecShellWait "" "$INSTDIR\gviai.exe" "-silent -register" SW_HIDE
  ${EndIf}
SectionEnd

##########################################################
# Console version
Section "$(str_section_console)" id_section_console
  SectionIn 1 3

  SetOutPath $INSTDIR
  File ${VIMBIN}\viai.exe

  # Create hard links
  ReadEnvStr $3 "COMSPEC"
  nsExec::Exec '"$3" /c mklink /h viaidiff.exe viai.exe'
  Pop $4
SectionEnd

##########################################################
# Command line support
SectionGroup $(str_group_cmdline) id_group_cmdline
  # ViAI launcher
  Section "$(str_section_launcher)" id_section_launcher
    SectionIn 3

    ReadEnvStr $5 "SystemRoot"  ; Normally "C:\WINDOWS"
    SetOutPath $5
    File ${VIMLAUNCHER}\gviai.exe

    # Create hard links
    ReadEnvStr $3 "COMSPEC"
    nsExec::Exec '"$3" /c mklink /h gviaidiff.exe gviai.exe'
    Pop $4
    nsExec::Exec '"$3" /c mklink /h eviai.exe gviai.exe'
    Pop $4

    ${If} ${SectionIsSelected} ${id_section_console}
      File ${VIMLAUNCHER}\viai.exe

      # Create hard links
      nsExec::Exec '"$3" /c mklink /h viaidiff.exe viai.exe'
      Pop $4
    ${EndIf}

    # Register the path in case the editwith menu is not installed.
    ${If} ${RunningX64}
      SetRegView 64
      WriteRegStr SHCTX "Software\ViAI\Gviai" "path" "$INSTDIR\${PROGEXE}"
      SetRegView lastused
    ${EndIf}
    !if ! ${ARM64}
      SetRegView 32
      WriteRegStr SHCTX "Software\ViAI\Gviai" "path" "$INSTDIR\${PROGEXE}"
      SetRegView lastused
    !endif
  SectionEnd

  # Add to PATH
  Section "$(str_section_addpath)" id_section_addpath
    SectionIn 3

    ${If} $MultiUser.InstallMode == "AllUsers"
      EnVar::SetHKLM
    ${Else}
      EnVar::SetHKCU
    ${EndIf}
    EnVar::AddValue "PATH" $INSTDIR
  SectionEnd
SectionGroupEnd

##########################################################
# Icons
SectionGroup $(str_group_icons) id_group_icons
  # Desktop icons
  Section "$(str_section_desktop)" id_section_desktop
    SectionIn 1 3

    SetOutPath "%HOMEDRIVE%%HOMEPATH%"	; Set workdir for the shortcuts
    CreateShortCut "$DESKTOP\GViAI ${VERSION_SHORT}.lnk"		  "$INSTDIR\gviai.exe"
    CreateShortCut "$DESKTOP\GViAI Easy ${VERSION_SHORT}.lnk"	  "$INSTDIR\gviai.exe" "-y"
    CreateShortCut "$DESKTOP\GViAI Read only ${VERSION_SHORT}.lnk" "$INSTDIR\gviai.exe" "-R"
  SectionEnd

  # Start Menu
  Section "$(str_section_start_menu)" id_section_startmenu
    SectionIn 1 3

    CreateDirectory "$SMPROGRAMS\${PRODUCT_AND_VER}"

    SetOutPath "%HOMEDRIVE%%HOMEPATH%"	; Set workdir for the shortcuts
    ${If} ${SectionIsSelected} ${id_section_console}
      CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\ViAI.lnk"		"$INSTDIR\viai.exe"
      CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\ViAI Read only.lnk" "$INSTDIR\viai.exe" "-R"
      CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\ViAI Diff.lnk"	"$INSTDIR\viai.exe" "-d"
    ${EndIf}
    CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\GViAI.lnk"		"$INSTDIR\gviai.exe"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\GViAI Easy.lnk"	"$INSTDIR\gviai.exe" "-y"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\GViAI Read only.lnk"	"$INSTDIR\gviai.exe" "-R"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\GViAI Diff.lnk"	"$INSTDIR\gviai.exe" "-d"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\Help.lnk"		"$INSTDIR\gviai.exe" "-c h"

    SetOutPath $0   ; Set workdir for the shortcuts
    CreateShortCut "$SMPROGRAMS\${PRODUCT_AND_VER}\Uninstall.lnk"	"$INSTDIR\uninstall-gui.exe"

    WriteINIStr "$SMPROGRAMS\${PRODUCT_AND_VER}\ViAI Online.url" "InternetShortcut" "URL" \
	"https://github.com/viai-editor/viai"
  SectionEnd
SectionGroupEnd

##########################################################
# ViAI context menu
Section "$(str_section_edit_with)" id_section_editwith
  SectionIn 1 3

  ${If} ${RunningX64}
    # Install 64-bit gviaiext.dll into the GviaiExt64 directory.
    SetOutPath $0\GviaiExt64
    ClearErrors
    !define LIBRARY_SHELL_EXTENSION
    !define LIBRARY_X64
    !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	"${VIMRT}\GviaiExt64\gviaiext.dll" "$0\GviaiExt64\gviaiext.dll" "$0"
    !undef LIBRARY_X64
    !undef LIBRARY_SHELL_EXTENSION
  ${EndIf}

  !if ! ${ARM64}
    # Install 32-bit gviaiext.dll into the GviaiExt32 directory.
    SetOutPath $0\GviaiExt32
    ClearErrors
    !define LIBRARY_SHELL_EXTENSION
    !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	"${VIMRT}\GviaiExt32\gviaiext.dll" "$0\GviaiExt32\gviaiext.dll" "$0"
    !undef LIBRARY_SHELL_EXTENSION
  !endif

  # We don't have a separate entry for the "Open With..." menu, assume
  # the user wants either both or none.

  # Register servers
  ${If} ${RunningX64}
    SetRegView 64
    WriteRegStr SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}" "" "ViAI Shell Extension"
    WriteRegStr SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}\InProcServer32" "" "$0\GviaiExt64\gviaiext.dll"
    WriteRegStr SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}\InProcServer32" "ThreadingModel" "Apartment"
    SetRegView lastused
  ${EndIf}
  !if ! ${ARM64}
    SetRegView 32
    WriteRegStr SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}" "" "ViAI Shell Extension"
    WriteRegStr SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}\InProcServer32" "" "$0\GviaiExt32\gviaiext.dll"
    WriteRegStr SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}\InProcServer32" "ThreadingModel" "Apartment"
    SetRegView lastused
  !endif

  # Register context menu
  ${If} ${RunningX64}
    SetRegView 64
    WriteRegStr SHCTX "Software\Classes\*\shellex\ContextMenuHandlers\gviai" "" "${GVIMEXT_CLSID}"
    WriteRegStr SHCTX "Software\ViAI\Gviai" "path" "$INSTDIR\${PROGEXE}"
    SetRegView lastused
  ${EndIf}
  !if ! ${ARM64}
    SetRegView 32
    WriteRegStr SHCTX "Software\Classes\*\shellex\ContextMenuHandlers\gviai" "" "${GVIMEXT_CLSID}"
    WriteRegStr SHCTX "Software\ViAI\Gviai" "path" "$INSTDIR\${PROGEXE}"
    SetRegView lastused
  !endif

  # Register openwith
  ${If} ${RunningX64}
    SetRegView 64
    WriteRegStr SHCTX "Software\Classes\Applications\gviai.exe\shell\edit\command" "" '"$INSTDIR\${PROGEXE}" "%1"'
    WriteRegStr SHCTX "Software\Classes\.htm\OpenWithList\gviai.exe" "" ""
    WriteRegStr SHCTX "Software\Classes\.vim\OpenWithList\gviai.exe" "" ""
    WriteRegStr SHCTX "Software\Classes\*\OpenWithList\gviai.exe" "" ""
    SetRegView lastused
  ${EndIf}
  !if ! ${ARM64}
    SetRegView 32
    WriteRegStr SHCTX "Software\Classes\Applications\gviai.exe\shell\edit\command" "" '"$INSTDIR\${PROGEXE}" "%1"'
    WriteRegStr SHCTX "Software\Classes\.htm\OpenWithList\gviai.exe" "" ""
    WriteRegStr SHCTX "Software\Classes\.vim\OpenWithList\gviai.exe" "" ""
    WriteRegStr SHCTX "Software\Classes\*\OpenWithList\gviai.exe" "" ""
    SetRegView lastused
  !endif
SectionEnd

##########################################################
# Create _vimrc
Section "$(str_section_vim_rc)" id_section_vimrc
  SectionIn 1 3

  !insertmacro MULTIUSER_GetCurrentUserString $5
  WriteRegStr SHCTX "${UNINST_REG_KEY_VIM}$5" "vim_compat"   "$vim_compat_stat"
  WriteRegStr SHCTX "${UNINST_REG_KEY_VIM}$5" "vim_keyremap" "$vim_keymap_stat"
  WriteRegStr SHCTX "${UNINST_REG_KEY_VIM}$5" "vim_mouse"    "$vim_mouse_stat"

  ${IfNot} ${FileExists} $INSTDIR/_vimrc
  ${AndIfNot} ${FileExists} $INSTDIR/.vimrc
    ClearErrors
    FileOpen $3 $INSTDIR\_vimrc w
    ${IfNot} ${Errors}
      ${If} $vim_compat_stat == "vi"
        FileWrite $3 `" Vi compatible$\n`
        FileWrite $3 `set compatible$\n`
      ${ElseIf} $vim_compat_stat == "vim"
        FileWrite $3 `" Vim's default befavior$\n`
        FileWrite $3 `if &compatible$\n`
        FileWrite $3 `  set compatible$\n`
        FileWrite $3 `endif$\n`
      ${ElseIf} $vim_compat_stat == "defaults"
        FileWrite $3 `" Vim with some enhancements$\n`
        FileWrite $3 `source $$VIMRUNTIME/defaults.vim$\n`
      ${Else}
        FileWrite $3 `" Vim with all enhancements$\n`
        FileWrite $3 `source $$VIMRUNTIME/vimrc_example.vim$\n`
      ${EndIf}

      ${If} $vim_keymap_stat == "default"
	#
      ${Else}
        FileWrite $3 `$\n`
        FileWrite $3 `" Remap a few keys for Windows behavior$\n`
        FileWrite $3 `source $$VIMRUNTIME/mswin.vim$\n`
      ${EndIf}

      ${If} $vim_mouse_stat == "default"
	#
      ${ElseIf} $vim_mouse_stat == "windows"
        FileWrite $3 `$\n`
        FileWrite $3 `" Mouse behavior (the Windows way)$\n`
        FileWrite $3 `behave mswin$\n`
      ${Else}
        FileWrite $3 `$\n`
        FileWrite $3 `" Mouse behavior (the Unix way)$\n`
        FileWrite $3 `behave xterm$\n`
      ${EndIf}

      FileWrite $3 `$\n`
      FileWrite $3 `" Use the internal diff if available.$\n`
      FileWrite $3 `" Otherwise use the special 'diffexpr' for Windows.$\n`
      FileWrite $3 `if &diffopt !~# 'internal'$\n`
      FileWrite $3 `  set diffexpr=MyDiff()$\n`
      FileWrite $3 `endif$\n`
      FileWrite $3 `function MyDiff()$\n`
      FileWrite $3 `  let opt = '-a --binary '$\n`
      FileWrite $3 `  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif$\n`
      FileWrite $3 `  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif$\n`
      FileWrite $3 `  let arg1 = v:fname_in$\n`
      FileWrite $3 `  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif$\n`
      FileWrite $3 `  let arg1 = substitute(arg1, '!', '\!', 'g')$\n`
      FileWrite $3 `  let arg2 = v:fname_new$\n`
      FileWrite $3 `  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif$\n`
      FileWrite $3 `  let arg2 = substitute(arg2, '!', '\!', 'g')$\n`
      FileWrite $3 `  let arg3 = v:fname_out$\n`
      FileWrite $3 `  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif$\n`
      FileWrite $3 `  let arg3 = substitute(arg3, '!', '\!', 'g')$\n`
      FileWrite $3 `  if $$VIM =~ ' '$\n`
      FileWrite $3 `    if &sh =~ '\<cmd'$\n`
      FileWrite $3 `      if empty(&shellxquote)$\n`
      FileWrite $3 `        let l:shxq_sav = ''$\n`
      FileWrite $3 `        set shellxquote&$\n`
      FileWrite $3 `      endif$\n`
      FileWrite $3 `      let cmd = '"' . $$VIM . '\diff"'$\n`
      FileWrite $3 `    else$\n`
      FileWrite $3 `      let cmd = substitute($$VIM, ' ', '" ', '') . '\diff"'$\n`
      FileWrite $3 `    endif$\n`
      FileWrite $3 `  else$\n`
      FileWrite $3 `    let cmd = $$VIM . '\diff'$\n`
      FileWrite $3 `  endif$\n`
      FileWrite $3 `  let cmd = substitute(cmd, '!', '\!', 'g')$\n`
      FileWrite $3 `  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3$\n`
      FileWrite $3 `  if exists('l:shxq_sav')$\n`
      FileWrite $3 `    let &shellxquote=l:shxq_sav$\n`
      FileWrite $3 `  endif$\n`
      FileWrite $3 `endfunction$\n`

      FileClose $3
    ${EndIf}
  ${EndIf}
SectionEnd

##########################################################
# Create plugin dirs
${StrTok}

!define PLUG_DIR_LIST "colors compiler doc ftdetect ftplugin indent keymap plugin syntax"

# Create plugin directories
# param: $R0 = target directory, $R1 = name of the plugin directory
Function CreatePluginDirs
  Push $3
  Push $5

  CreateDirectory $R0\$R1

  StrCpy $3 0	  ; index
  ${Do}
    ${StrTok} $5 "${PLUG_DIR_LIST}" " " $3 "1"
    ${If} $5 == ""
      ${ExitDo}
    ${EndIf}
    CreateDirectory $R0\$R1\$5
    IntOp $3 $3 + 1
  ${Loop}

  Pop $5
  Pop $3
FunctionEnd

SectionGroup $(str_group_plugin) id_group_plugin
  # Create plugin dir in $HOME
  Section "$(str_section_plugin_home)" id_section_pluginhome
    SectionIn 1 3

    ReadEnvStr $3 "COMSPEC"
    Call GetHomeDir
    Pop $R0
    StrCpy $R1 "viaifiles"
    !insertmacro UAC_AsUser_Call Function CreatePluginDirs ${UAC_SYNCREGISTERS}
  SectionEnd

  # Create plugin dir shared with Vim in $HOME
  Section /o "$(str_section_plugin_home_vim)" id_section_pluginhomevim
    ReadEnvStr $3 "COMSPEC"
    Call GetHomeDir
    Pop $R0
    StrCpy $R1 "vimfiles"
    !insertmacro UAC_AsUser_Call Function CreatePluginDirs ${UAC_SYNCREGISTERS}
  SectionEnd

  # Create plugin dir in $VIM
  Section "$(str_section_plugin_vim)" id_section_pluginvim
    SectionIn 3

    StrCpy $R0 $INSTDIR
    StrCpy $R1 "vimfiles"
    Call CreatePluginDirs
  SectionEnd
SectionGroupEnd

##########################################################
# Native Language Support
Section "$(str_section_nls)" id_section_nls
  SectionIn 1 3

  SetOutPath $INSTDIR\lang
  !if /FileExists "${SRC}\lang\README.*.txt"
    File ${SRC}\lang\README.*.txt
  !endif
  !if /FileExists "${SRC}\lang\LICENSE.??.txt"
    File ${SRC}\lang\LICENSE.??.txt
  !endif
  !if /FileExists "${SRC}\lang\LICENSE.??_??.txt"
    File ${SRC}\lang\LICENSE.??_??.txt
  !endif

  SetOutPath $0\lang
  File /r /x Makefile ${VIMRT}\lang\*.*

  SetOutPath $INSTDIR
  !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
      "${VIMBIN}\libintl-8.dll" "$INSTDIR\libintl-8.dll" "$INSTDIR"
  !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
      "${VIMBIN}\libiconv-2.dll" "$INSTDIR\libiconv-2.dll" "$INSTDIR"
  # Install libgcc_s_sjlj-1.dll only if it is needed.
  !if ${INCLUDE_LIBGCC}
    !if /FileExists "${VIMBIN}\libgcc_s_sjlj-1.dll"
      !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "${VIMBIN}\libgcc_s_sjlj-1.dll" \
	  "$INSTDIR\libgcc_s_sjlj-1.dll" "$INSTDIR"
    !endif
  !endif

  SetOutPath $0
  ${If} ${SectionIsSelected} ${id_section_editwith}
    ${If} ${RunningX64}
      # Install DLLs for 64-bit gviaiext.dll into the GviaiExt64 directory.
      SetOutPath $0\GviaiExt64
      ClearErrors
      !define LIBRARY_X64
      !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "${VIMRT}\GviaiExt64\libintl-8.dll" \
	  "$0\GviaiExt64\libintl-8.dll" "$0\GviaiExt64"
      !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "${VIMRT}\GviaiExt64\libiconv-2.dll" \
	  "$0\GviaiExt64\libiconv-2.dll" "$0\GviaiExt64"
      !undef LIBRARY_X64
    ${EndIf}

    !if ! ${ARM64}
      # Install DLLs for 32-bit gviaiext.dll into the GviaiExt32 directory.
      SetOutPath $0\GviaiExt32
      ClearErrors
      !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "${VIMRT}\GviaiExt32\libintl-8.dll" \
	  "$0\GviaiExt32\libintl-8.dll" "$0\GviaiExt32"
      !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "${VIMRT}\GviaiExt32\libiconv-2.dll" \
	  "$0\GviaiExt32\libiconv-2.dll" "$0\GviaiExt32"
      # Install libgcc_s_sjlj-1.dll only if it is needed.
      !if ${INCLUDE_LIBGCC}
	!if /FileExists "${VIMRT}\GviaiExt32\libgcc_s_sjlj-1.dll"
	    !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
		"${VIMRT}\GviaiExt32\libgcc_s_sjlj-1.dll" \
		"$0\GviaiExt32\libgcc_s_sjlj-1.dll" "$0\GviaiExt32"
	!endif
      !endif
    !endif
  ${EndIf}
SectionEnd

##########################################################
# Post installation
Section -post
  # Get estimated install size
  SectionGetSize ${id_section_exe} $3
  ${If} ${SectionIsSelected} ${id_section_console}
    SectionGetSize ${id_section_console} $4
    IntOp $3 $3 + $4
  ${EndIf}
  ${If} ${SectionIsSelected} ${id_section_launcher}
    SectionGetSize ${id_section_launcher} $4
    IntOp $3 $3 + $4
  ${EndIf}
  ${If} ${SectionIsSelected} ${id_section_editwith}
    SectionGetSize ${id_section_editwith} $4
    IntOp $3 $3 + $4
  ${EndIf}
  ${If} ${SectionIsSelected} ${id_section_nls}
    SectionGetSize ${id_section_nls} $4
    IntOp $3 $3 + $4
  ${EndIf}

  WriteUninstaller ${UNINSTALL_FILENAME}

  # Register uninstall information
  !insertmacro MULTIUSER_RegistryAddInstallInfo
  # Add some settings
  !insertmacro MULTIUSER_GetCurrentUserString $5
  WriteRegDWORD SHCTX "${UNINST_REG_KEY_VIM}$5" "EstimatedSize" $3
  WriteRegDWORD SHCTX "${UNINST_REG_KEY_VIM}$5" "AllowSilent" 1

  # Store the selections to the registry.
  !insertmacro SaveSectionSelection $5 ${id_section_console}    "select_console"
  !insertmacro SaveSectionSelection $5 ${id_section_launcher}   "select_launcher"
  !insertmacro SaveSectionSelection $5 ${id_section_addpath}    "select_addpath"
  !insertmacro SaveSectionSelection $5 ${id_section_desktop}    "select_desktop"
  !insertmacro SaveSectionSelection $5 ${id_section_startmenu}  "select_startmenu"
  !insertmacro SaveSectionSelection $5 ${id_section_editwith}   "select_editwith"
  !insertmacro SaveSectionSelection $5 ${id_section_vimrc}      "select_vimrc"
  !insertmacro SaveSectionSelection $5 ${id_section_pluginhome} "select_pluginhome"
  !insertmacro SaveSectionSelection $5 ${id_section_pluginhomevim} "select_pluginhomevim"
  !insertmacro SaveSectionSelection $5 ${id_section_pluginvim}  "select_pluginvim"
  !insertmacro SaveSectionSelection $5 ${id_section_nls}        "select_nls"

  #BringToFront
SectionEnd

##########################################################
# Load the section selections from the registry and the command line
Function LoadSelections
  !insertmacro MULTIUSER_GetCurrentUserString $5
  # Load the selections from the registry (if any).
  !insertmacro LoadSectionSelection $5 ${id_section_console}    "select_console"
  !insertmacro LoadSectionSelection $5 ${id_section_launcher}   "select_launcher"
  !insertmacro LoadSectionSelection $5 ${id_section_addpath}    "select_addpath"
  !insertmacro LoadSectionSelection $5 ${id_section_desktop}    "select_desktop"
  !insertmacro LoadSectionSelection $5 ${id_section_startmenu}  "select_startmenu"
  !insertmacro LoadSectionSelection $5 ${id_section_editwith}   "select_editwith"
  !insertmacro LoadSectionSelection $5 ${id_section_vimrc}      "select_vimrc"
  !insertmacro LoadSectionSelection $5 ${id_section_pluginhome} "select_pluginhome"
  !insertmacro LoadSectionSelection $5 ${id_section_pluginhomevim} "select_pluginhomevim"
  !insertmacro LoadSectionSelection $5 ${id_section_pluginvim}  "select_pluginvim"
  !insertmacro LoadSectionSelection $5 ${id_section_nls}        "select_nls"
  # Load the default _vimrc settings from the registry (if any).
  !insertmacro LoadDefaultVimrc $5 $vim_compat_stat "vim_compat"   "all"
  !insertmacro LoadDefaultVimrc $5 $vim_keymap_stat "vim_keyremap" "default"
  !insertmacro LoadDefaultVimrc $5 $vim_mouse_stat  "vim_mouse"    "default"

  # Parse command line
  ${GetParameters} $5
  !insertmacro ParseCmdSectionSelection $5 "/console="	  ${id_section_console}
  !insertmacro ParseCmdSectionSelection $5 "/launcher="	  ${id_section_launcher}
  !insertmacro ParseCmdSectionSelection $5 "/addpath="	  ${id_section_addpath}
  !insertmacro ParseCmdSectionSelection $5 "/desktop="	  ${id_section_desktop}
  !insertmacro ParseCmdSectionSelection $5 "/startmenu="  ${id_section_startmenu}
  !insertmacro ParseCmdSectionSelection $5 "/editwith="	  ${id_section_editwith}
  !insertmacro ParseCmdSectionSelection $5 "/vimrc="	  ${id_section_vimrc}
  !insertmacro ParseCmdSectionSelection $5 "/pluginhome=" ${id_section_pluginhome}
  !insertmacro ParseCmdSectionSelection $5 "/pluginhomevim=" ${id_section_pluginhomevim}
  !insertmacro ParseCmdSectionSelection $5 "/pluginvim="  ${id_section_pluginvim}
  !insertmacro ParseCmdSectionSelection $5 "/nls="	  ${id_section_nls}
  !insertmacro ParseCmdVimrc $5 "/compat=" $vim_compat_stat
  !insertmacro ParseCmdVimrc $5 "/keymap=" $vim_keymap_stat
  !insertmacro ParseCmdVimrc $5 "/mouse="  $vim_mouse_stat
  ClearErrors
FunctionEnd

##########################################################
# Callback functions

Function .onInit
  # Process /? parameter
  ${GetParameters} $R0
  ${GetOptions} $R0 "/?" $R1
  ${IfNot} ${Errors}
    ReadEnvStr $3 "SystemRoot"  ; Normally "C:\WINDOWS"
    MessageBox MB_ICONINFORMATION \
      "Usage:$\r$\n\
      $\r$\n\
      /allusers$\t- (un)install for all users (*1)$\r$\n\
      /currentuser - (un)install for current user only (*2)$\r$\n\
      /uninstall$\t- run uninstaller, requires *1 or *2$\r$\n\
      /S$\t- silent mode, requires *1 or *2$\r$\n\
      /D=path$\t- set install directory, must be last parameter, w/o quotes$\r$\n\
      /?$\t- display this message$\r$\n\
      $\r$\n\
      Component selection:$\r$\n\
      /console={1,0}$\tinstall viai.exe$\r$\n\
      /launcher={1,0}$\tinstall ViAI launcher to $3$\r$\n\
      /addpath={1,0}$\tadd the ViAI directory to PATH$\r$\n\
      /desktop={1,0}$\tcreate desktop icons$\r$\n\
      /startmenu={1,0}$\tcreate startmenu icons$\r$\n\
      /editwith={1,0}$\tinstall editwith menu$\r$\n\
      /vimrc={1,0}$\tcreate _vimrc$\r$\n\
      /pluginhome={1,0}$\tcreate plugin dirs in home dir$\r$\n\
      /pluginhomevim={1,0}  create plugin dirs shared with Vim in home dir$\r$\n\
      /pluginvim={1,0}$\tcreate plugin dirs in ViAI dir$\r$\n\
      /nls={1,0}$\t$\tinstall multilingual support$\r$\n\
      /compat={vi,vim,defaults,all}$\tVi compatibility$\r$\n\
      /keymap={default,windows}$\tkey mappings$\r$\n\
      /mouse={default,windows,xterm}  mouse behavior"
    SetErrorLevel 0
    Quit
  ${endif}

  !insertmacro MULTIUSER_INIT

  ${IfNot} ${UAC_IsInnerInstance}
    # Select a language (or read from the registry).
    !insertmacro MUI_LANGDLL_DISPLAY
  ${EndIf}

  # Load the selections for silent mode
  Call LoadSelections

  StrCpy $settings_loaded 0
FunctionEnd

Function .onInstSuccess
FunctionEnd

Function .onInstFailed
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(str_msg_install_fail)" /SD IDOK
FunctionEnd

Function PageWelcomeLicensePre
  ${If} $InstallShowPagesBeforeComponents = 0
    Abort ; don't display the Welcome and License pages
  ${EndIf}
FunctionEnd

Function PageComponentsPre
  ${If} $MultiUser.InstallMode == "CurrentUser"
    # Unselect and hide ViAI launcher
    !insertmacro UnselectSection ${id_section_launcher}
    SectionSetInstTypes ${id_section_launcher} 0
    SectionSetText ${id_section_launcher} ""

    # Unselect and hide creating plugin directories in the vim directory
    !insertmacro UnselectSection ${id_section_pluginvim}
    SectionSetInstTypes ${id_section_pluginvim} 0
    SectionSetText ${id_section_pluginvim} ""
  ${EndIf}

  ${If} $settings_loaded = 0
    # Check old versions after the installation mode is selected.
    call FindOldUninstaller
    Pop $3
    ${If} $3 == ""
      # No old versions of ViAI found. Unselect and hide the section.
      !insertmacro UnselectSection ${id_section_old_ver}
      SectionSetInstTypes ${id_section_old_ver} 0
      SectionSetText ${id_section_old_ver} ""
    ${Else}
      #!insertmacro SelectSection ${id_section_old_ver}
      #SectionSetInstTypes ${id_section_old_ver} 7
      #SectionSetText ${id_section_old_ver} $(str_desc_old_ver)
    ${EndIf}

    # Load the selections for interactive mode
    Call LoadSelections

    StrCpy $settings_loaded 1
  ${EndIf}
FunctionEnd

##########################################################
Function SetCustom
  # Display the _vimrc setting dialog using nsDialogs.

  # Check if a _vimrc should be created
  ${IfNot} ${SectionIsSelected} ${id_section_vimrc}
    Abort
  ${EndIf}

  !insertmacro MUI_HEADER_TEXT $(str_vimrc_page_title) $(str_vimrc_page_subtitle)

  nsDialogs::Create 1018
  Pop $vim_dialog

  ${If} $vim_dialog == error
    Abort
  ${EndIf}

  GetFunctionAddress $3 ValidateCustom
  nsDialogs::OnBack $3

  # 1st group - Compatibility
  ${NSD_CreateGroupBox} 0u 0u 296u 44u $(str_msg_compat_title)
  Pop $3

  ${NSD_CreateLabel} 16u 14u 269u 10u $(str_msg_compat_desc)
  Pop $3
  ${NSD_CreateDropList} 42u 26u 237u 13u ""
  Pop $vim_nsd_compat
  ${NSD_CB_AddString} $vim_nsd_compat $(str_msg_compat_vi)
  ${NSD_CB_AddString} $vim_nsd_compat $(str_msg_compat_vim)
  ${NSD_CB_AddString} $vim_nsd_compat $(str_msg_compat_defaults)
  ${NSD_CB_AddString} $vim_nsd_compat $(str_msg_compat_all)

  ${If} $vim_compat_stat == "defaults"
    StrCpy $4 2
  ${ElseIf} $vim_compat_stat == "vim"
    StrCpy $4 1
  ${ElseIf} $vim_compat_stat == "vi"
    StrCpy $4 0
  ${Else} ; default
    StrCpy $4 3
  ${EndIf}
  ${NSD_CB_SetSelectionIndex} $vim_nsd_compat $4

  # 2nd group - Key remapping
  ${NSD_CreateGroupBox} 0u 48u 296u 44u $(str_msg_keymap_title)
  Pop $3

  ${NSD_CreateLabel} 16u 62u 269u 10u $(str_msg_keymap_desc)
  Pop $3
  ${NSD_CreateDropList} 42u 74u 236u 13u ""
  Pop $vim_nsd_keymap
  ${NSD_CB_AddString} $vim_nsd_keymap $(str_msg_keymap_default)
  ${NSD_CB_AddString} $vim_nsd_keymap $(str_msg_keymap_windows)

  ${If} $vim_keymap_stat == "windows"
    StrCpy $4 1
  ${Else} ; default
    StrCpy $4 0
  ${EndIf}
  ${NSD_CB_SetSelectionIndex} $vim_nsd_keymap $4

  # 3rd group - Mouse behavior
  ${NSD_CreateGroupBox} 0u 95u 296u 44u $(str_msg_mouse_title)
  Pop $3

  ${NSD_CreateLabel} 16u 108u 269u 10u $(str_msg_mouse_desc)
  Pop $3
  ${NSD_CreateDropList} 42u 121u 237u 13u ""
  Pop $vim_nsd_mouse
  ${NSD_CB_AddString} $vim_nsd_mouse $(str_msg_mouse_default)
  ${NSD_CB_AddString} $vim_nsd_mouse $(str_msg_mouse_windows)
  ${NSD_CB_AddString} $vim_nsd_mouse $(str_msg_mouse_unix)

  ${If} $vim_mouse_stat == "xterm"
    StrCpy $4 2
  ${ElseIf} $vim_mouse_stat == "windows"
    StrCpy $4 1
  ${Else} ; default
    StrCpy $4 0
  ${EndIf}
  ${NSD_CB_SetSelectionIndex} $vim_nsd_mouse $4

  nsDialogs::Show
FunctionEnd

Function ValidateCustom
  ${NSD_CB_GetSelectionIndex} $vim_nsd_compat $3
  ${If} $3 = 0
    StrCpy $vim_compat_stat "vi"
  ${ElseIf} $3 = 1
    StrCpy $vim_compat_stat "vim"
  ${ElseIf} $3 = 2
    StrCpy $vim_compat_stat "defaults"
  ${Else}
    StrCpy $vim_compat_stat "all"
  ${EndIf}

  ${NSD_CB_GetSelectionIndex} $vim_nsd_keymap $3
  ${If} $3 = 0
    StrCpy $vim_keymap_stat "default"
  ${Else}
    StrCpy $vim_keymap_stat "windows"
  ${EndIf}

  ${NSD_CB_GetSelectionIndex} $vim_nsd_mouse $3
  ${If} $3 = 0
    StrCpy $vim_mouse_stat "default"
  ${ElseIf} $3 = 1
    StrCpy $vim_mouse_stat "windows"
  ${Else}
    StrCpy $vim_mouse_stat "xterm"
  ${EndIf}
FunctionEnd

##########################################################
# Description for Installer Sections

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver}     $(str_desc_old_ver)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_exe}	      $(str_desc_exe)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_console}     $(str_desc_console)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_group_cmdline}	      $(str_desc_cmdline)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_launcher}    $(str_desc_launcher)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_addpath}     $(str_desc_addpath)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_group_icons}	      $(str_desc_icons)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_desktop}     $(str_desc_desktop)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_startmenu}   $(str_desc_start_menu)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_editwith}    $(str_desc_edit_with)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_vimrc}	      $(str_desc_vim_rc)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_group_plugin}	      $(str_desc_plugin)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_pluginhome}  $(str_desc_plugin_home)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_pluginhomevim} $(str_desc_plugin_home_vim)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_pluginvim}   $(str_desc_plugin_vim)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_section_nls}	      $(str_desc_nls)
!insertmacro MUI_FUNCTION_DESCRIPTION_END


##########################################################
# Uninstaller Functions and Sections

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
  # Get the language from the registry.
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

Section "un.$(str_unsection_register)" id_unsection_register
  SectionIn RO

  # Apparently $INSTDIR is set to the directory where the uninstaller is
  # created.  Thus the "vim91" directory is included in it.
  # -- It is not true in NsisMultiUser.
  #StrCpy $0 "$INSTDIR"
  StrCpy $0 "$INSTDIR\${VIMRUNTIME_DIR_NAME}"

  # delete the context menu entry and batch files
  DetailPrint "$(str_msg_unregistering)"

  ${If} ${RunningX64}
    SetRegView 64
    DeleteRegKey SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}"
    DeleteRegKey SHCTX "Software\Classes\*\shellex\ContextMenuHandlers\gviai"
    DeleteRegKey SHCTX "Software\ViAI"
    DeleteRegKey SHCTX "Software\Classes\Applications\gviai.exe"
    DeleteRegKey SHCTX "Software\Classes\.htm\OpenWithList\gviai.exe"
    DeleteRegKey SHCTX "Software\Classes\.vim\OpenWithList\gviai.exe"
    DeleteRegKey SHCTX "Software\Classes\*\OpenWithList\gviai.exe"
    SetRegView lastused
  ${EndIf}
  !if ! ${ARM64}
    SetRegView 32
    DeleteRegKey SHCTX "Software\Classes\CLSID\${GVIMEXT_CLSID}"
    DeleteRegKey SHCTX "Software\Classes\*\shellex\ContextMenuHandlers\gviai"
    DeleteRegKey SHCTX "Software\ViAI"
    DeleteRegKey SHCTX "Software\Classes\Applications\gviai.exe"
    DeleteRegKey SHCTX "Software\Classes\.htm\OpenWithList\gviai.exe"
    DeleteRegKey SHCTX "Software\Classes\.vim\OpenWithList\gviai.exe"
    DeleteRegKey SHCTX "Software\Classes\*\OpenWithList\gviai.exe"
    SetRegView lastused
  !endif

  # Delete the installer language setting.
  DeleteRegKey ${MUI_LANGDLL_REGISTRY_ROOT} ${MUI_LANGDLL_REGISTRY_KEY}

  # Delete shortcuts
  RMDir /r "$SMPROGRAMS\${PRODUCT_AND_VER}"
  Delete "$DESKTOP\GViAI ${VERSION_SHORT}.lnk"
  Delete "$DESKTOP\GViAI Easy ${VERSION_SHORT}.lnk"
  Delete "$DESKTOP\GViAI Read only ${VERSION_SHORT}.lnk"

  # Delete from PATH
  ${If} $MultiUser.InstallMode == "AllUsers"
    EnVar::SetHKLM
  ${Else}
    EnVar::SetHKCU
  ${EndIf}
  EnVar::DeleteValue "PATH" $INSTDIR

  # Delete uninstall key
  #DeleteRegKey SHCTX "${UNINST_REG_KEY_VIM}"
  !insertmacro MULTIUSER_RegistryRemoveInstallInfo
SectionEnd

Section "un.$(str_unsection_exe)" id_unsection_exe
  #StrCpy $0 "$INSTDIR"
  StrCpy $0 "$INSTDIR\${VIMRUNTIME_DIR_NAME}"

  # OLE
  ${If} $MultiUser.InstallMode == "AllUsers"
    ExecShellWait "" "$INSTDIR\gviai.exe" "-silent -unregister" SW_HIDE
  ${EndIf}

  # Delete gettext and iconv DLLs
  ${If} ${FileExists} "$INSTDIR\libiconv-2.dll"
    !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	"$INSTDIR\libiconv-2.dll"
  ${EndIf}
  ${If} ${FileExists} "$INSTDIR\libintl-8.dll"
    !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	"$INSTDIR\libintl-8.dll"
  ${EndIf}
  ${If} ${FileExists} "$INSTDIR\libgcc_s_sjlj-1.dll"
    !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	"$INSTDIR\libgcc_s_sjlj-1.dll"
  ${EndIf}

  # Delete other DLLs
  Delete /REBOOTOK $INSTDIR\*.dll

  # Delete 64-bit GviaiExt
  ${If} ${RunningX64}
    !define LIBRARY_X64
    ${If} ${FileExists} "$0\GviaiExt64\gviaiext.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt64\gviaiext.dll"
    ${EndIf}
    ${If} ${FileExists} "$0\GviaiExt64\libiconv-2.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt64\libiconv-2.dll"
    ${EndIf}
    ${If} ${FileExists} "$0\GviaiExt64\libintl-8.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt64\libintl-8.dll"
    ${EndIf}
    ${If} ${FileExists} "$0\GviaiExt64\libwinpthread-1.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt64\libwinpthread-1.dll"
    ${EndIf}
    !undef LIBRARY_X64
    RMDir /r $0\GviaiExt64
  ${EndIf}

  # Delete 32-bit GviaiExt
  !if ! ${ARM64}
    ${If} ${FileExists} "$0\GviaiExt32\gviaiext.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt32\gviaiext.dll"
    ${EndIf}
    ${If} ${FileExists} "$0\GviaiExt32\libiconv-2.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt32\libiconv-2.dll"
    ${EndIf}
    ${If} ${FileExists} "$0\GviaiExt32\libintl-8.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt32\libintl-8.dll"
    ${EndIf}
    ${If} ${FileExists} "$0\GviaiExt32\libgcc_s_sjlj-1.dll"
      !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
	  "$0\GviaiExt32\libgcc_s_sjlj-1.dll"
    ${EndIf}
    RMDir /r $0\GviaiExt32
  !endif

  ClearErrors
  # Remove everything but *.dll files.  Avoids that
  # a lot remains when gviaiext.dll cannot be deleted.
  RMDir /r $0\autoload
  RMDir /r $0\colors
  RMDir /r $0\compiler
  RMDir /r $0\doc
  RMDir /r $0\ftplugin
  RMDir /r $0\import
  RMDir /r $0\indent
  RMDir /r $0\macros
  RMDir /r $0\pack
  RMDir /r $0\plugin
  RMDir /r $0\spell
  RMDir /r $0\syntax
  RMDir /r $0\tools
  RMDir /r $0\tutor
  RMDir /r $0\lang
  RMDir /r $0\keymap
  RMDir /r $0\bitmaps
  Delete $0\*.exe
  Delete $0\*.bat
  Delete $0\*.vim
  Delete $0\*.txt

  RMDir /r $INSTDIR\lang
  Delete $INSTDIR\*.exe
  Delete $INSTDIR\LICENSE.txt
  Delete $INSTDIR\LICENSE-APACHE.txt
  Delete $INSTDIR\uninstall.txt

  ${If} ${Errors}
    MessageBox MB_OK|MB_ICONEXCLAMATION $(str_msg_rm_exe_fail) /SD IDOK
  ${EndIf}

  # ViAI launcher
  ReadEnvStr $3 "SystemRoot"  ; Normally "C:\WINDOWS"
  Delete $3\gviai.exe
  Delete $3\gviaidiff.exe
  Delete $3\eviai.exe
  Delete $3\viai.exe
  Delete $3\viaidiff.exe

  # No error message if the "vim92" directory can't be removed, the
  # gviaiext.dll may still be there.
  RMDir $0
SectionEnd

# Remove the plugin directory "name" under the specified directory.
!macro RemoveVimfiles dir name
  ${If} ${FileExists} ${dir}\_viaiinfo
    Delete ${dir}\_viaiinfo
  ${EndIf}
  ${If} ${DirExists} ${dir}\${name}
    RMDir ${dir}\${name}\colors
    RMDir ${dir}\${name}\compiler
    RMDir ${dir}\${name}\doc
    RMDir ${dir}\${name}\ftdetect
    RMDir ${dir}\${name}\ftplugin
    RMDir ${dir}\${name}\indent
    RMDir ${dir}\${name}\keymap
    RMDir ${dir}\${name}\plugin
    RMDir ${dir}\${name}\syntax
    ${If} ${FileExists} ${dir}\${name}\.netrwhist*
      Delete ${dir}\${name}\.netrwhist*
    ${EndIf}
    RMDir ${dir}\${name}
  ${EndIf}
!macroend

SectionGroup "un.$(str_ungroup_plugin)" id_ungroup_plugin
  Section /o "un.$(str_unsection_plugin_home)" id_unsection_plugin_home
    # get the home dir
    Call un.GetHomeDir
    Pop $0

    ${If} $0 != ""
      !insertmacro RemoveVimfiles $0 viaifiles
    ${EndIf}
  SectionEnd

  Section "un.$(str_unsection_plugin_vim)" id_unsection_plugin_vim
    # if a plugin dir was created at installation remove it
    !insertmacro RemoveVimfiles $INSTDIR vimfiles
  SectionEnd
SectionGroupEnd

Section "un.$(str_unsection_rootdir)" id_unsection_rootdir
  ${IfNot} ${Silent}
    Delete $INSTDIR\_vimrc
  ${Endif}
  RMDir $INSTDIR
SectionEnd

##########################################################
# Description for Uninstaller Sections

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_register}	$(str_desc_unregister)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_exe}		$(str_desc_rm_exe)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_ungroup_plugin}	$(str_desc_rm_plugin)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_plugin_home}	$(str_desc_rm_plugin_home)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_plugin_vim}	$(str_desc_rm_plugin_vim)
  !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_rootdir}	$(str_desc_rm_rootdir)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

# vi:set ts=8 sw=2 sts=2 tw=100 wm=0 ft=nsis:
