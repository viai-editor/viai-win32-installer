This builds a one-click installer for ViAI for MS Windows using the Nullsoft
Installation System (NSIS), available at http://nsis.sourceforge.net/

The installer is automatically built by the viai-win32-installer CI.
However, if you want to build it locally (e.g. for debugging), follow the
steps below.

Assuming you have already cloned the viai-win32-installer repository into your
local directory, say $WORKDIR.
Run the following commands in GitBash unless otherwise stated.

1. Clone the ViAI repository into $WORKDIR using the git command:

	cd $WORKDIR
	git clone https://github.com/viai-editor/viai.git

2. Clone the NsisMultiUser plugin into $WORKDIR.
   We are using the forked version instead of the original one
   (https://github.com/Drizin/NsisMultiUser).

	git clone https://github.com/k-takata/NsisMultiUser.git

3. Download and unpack the EnVar plugin
   (https://nsis.sourceforge.io/EnVar_plug-in)

	curl -O https://nsis.sourceforge.io/mediawiki/images/7/7f/EnVar_plugin.zip
	unzip EnVar_plugin.zip -d EnVar_plugin

4. Download a zip package from the release page of the viai-win32-installer
   repository.

   For example, download the 1.0.0018 package for x64 and unpack it to
   $WORKDIR/package/viai-package-x64:

	cd $WORKDIR/package
	curl -LO https://github.com/viai-editor/viai-win32-installer/releases/download/v1.0.0018/gviai_1.0.0018_x64.zip
	unzip gviai_1.0.0018_x64.zip -d viai-package-x64

5. Create the license files for the installer package.

	cd $WORKDIR
	./scripts/create_nsis_lic_files.sh ./viai

6. Build the ViAI launcher
   Open a Visual Studio Command Prompt for the target you want to build, then:

	cd %WORKDIR%\viai-launcher
	nmake -f Make_mvc.mak

7. Build the installer
   Now the directory structure should be like this:

	<viai-win32-installer directory> ($WORKDIR)
	    + EnVar_plugin/
	    + NsisMultiUser/
	    + nsis/
	    |	README.txt (This file)
	    |	gviai.nsi
	    |
	    + package/
	    |	viai-package-x64/
	    |	    viai/
	    |		viai10/
	    + viai/
	    |	lang/
	    |	    LICENSE.*.nsis.txt
	    |
	    + viai-launcher/
		gviai.exe
		viai.exe

   Run the following command in a Command Prompt:

	set PKG=..\package\viai-package-x64\viai\viai10
	"%ProgramFiles(x86)%\NSIS\makensis" ^
		/INPUTCHARSET UTF8 ^
		/DVIMBIN=%PKG% ^
		/DVIMRT=%PKG% ^
		/DINCLUDE_LIBGCC=0 ^
		/DWIN64=1 ^
		/DARM64=0 ^
		/DDEBUG ^
		gviai.nsi

   If you build an x86 or arm64 package, set PKG, /DWIN64, and /DARM64
   correctly.

   If /DDEBUG is specified, the installer will be built in debug mode.
   The DebugPrint macro can be used for debug print. E.g.:

	!insertmacro DebugPrint "debug message"

   The debug message can be seen in DebugView (or DebugView++).
   Also, it turns off LZMA compression to build faster.


If you want to build an installer without using a zip package, see the
following scripts in this repository:

	.github/workflow/build-viai.yml
	scripts/prepare_package_dir.bat
