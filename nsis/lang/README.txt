This directory contains a file with text strings for the ViAI installer.
It also contains files with translations of the text strings for the ViAI
installer into different languages.

For translators.

If you want to prepare a translation for the ViAI installer, use the file
"english.nsi" as a master file.  See the other translation files in this
directory.
Note that in the definition of the MUI_LANGUAGE macro, the name of the language
to be translated must be the English name of the language.
The name of the file with the translation must match the name of the target
language.
Also, when translating strings, pay attention to some restrictions on the
allowable length of strings.  For example:
 component description field - 117 characters;
 description above the drop-down lists on the .vimrc page - 53 characters;
 drop-down lists on the .vimrc page - 55 characters.
Characters in this case mean characters of the English alphabet.

Once the message translation file is ready, it must be included in the
"gviai.nsi" file.
Find the line "# Include support for other languages:" in the file "gviai.nsi"
and specify the name of the file with your translation, similar to the entries
already there. File names are specified in alphabetical order.

If you do not yet have a translated "LICENSE" file, set the following value:

LicenseLangString page_lic_file 0 "${SRC}\lang\LICENSE.nsis.txt"

Once you have the translation of this file, set the value similarly to what is
done in the other translation files.
The translated file should be located in the "lang" subdirectory of the ViAI
repository.  The name of the file is "LICENSE.xx.txt", where xx is the language
code according to ISO639.

Please also update the file ".github/MAINTAINERS".


There are two ways to test the installer in different languages:

1. Find and uncomment the "!define MUI_LANGDLL_ALWAYSSHOW" line in the
   "gviai.nsi" file and rebuild the installer.
   Now every time you run it, you will see a dialog box with the possibility to
   select the language of the installer.

2. If ViAI is already installed in your system, delete the
   "Installer Language" parameter in the Windows registry under
   "HKEY_CURRENT_USER\Software\ViAI".
   Or you can create a file "NoLangInstallerViAI.reg" with the following content:

	Windows Registry Editor Version 5.00

	[HKEY_CURRENT_USER\Software\ViAI]
	"Installer Language"=-

   and apply it by double-clicking on it.
   After these steps, when you start the installer, a window with the installer
   language selection will also be displayed.


The NsisMultiUser plugin

The ViAI installer uses the NsisMultiUser plugin, but it may lack some
translations.
Please send translations to upstream:
	https://github.com/Drizin/NsisMultiUser
and/or to the fork:
	https://github.com/k-takata/NsisMultiUser
