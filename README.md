[![Build ViAI](https://github.com/viai-editor/viai-win32-installer/actions/workflows/build-viai.yml/badge.svg)](https://github.com/viai-editor/viai-win32-installer/actions/workflows/build-viai.yml)
[![GitHub All Releases](https://img.shields.io/github/downloads/viai-editor/viai-win32-installer/total)](https://github.com/viai-editor/viai-win32-installer/releases)
[![Latest GitHub Release](https://img.shields.io/github/v/release/viai-editor/viai-win32-installer)](https://github.com/viai-editor/viai-win32-installer/releases/latest)


# ViAI Installer and ViAI Zip-Archives (Win32, Win64, ARM64)

This is a project for building nightly ViAI Windows build snapshots
automatically.  It is based on
[vim-win32-installer](https://github.com/vim/vim-win32-installer).

[Download](https://github.com/viai-editor/viai-win32-installer/releases/latest) and execute the
most recent `gviai_x.y.pppp_aaa.exe` file to install ViAI (where `x.y` is the
release version, `pppp` is the patch number, and `aaa` is the architecture).
The exe files contain the installer while the .zip files contain an archive of each
architecture. To install it, extract the archive and update your
PATH variable. The installer will do that automatically and provide some
additional extensions (e.g. Edit with ViAI menu).
The `gviai..._pdb.7z` file only contains the corresponding pdb files for debugging the binaries.

If you need a dynamic interface to Perl, Python2, Python3, Ruby, <del>TCL,</del> Lua or
Racket/MzScheme, make sure you also install the following. ViAI will work
without it, but some Plugin might need this additional dependency. (e.g.
[Gundo](https://github.com/sjl/gundo.vim) needs a working Python2.4+ installation,
[Command-T](https://github.com/wincent/command-t) needs a working Ruby
installation and [Neocomplete](https://github.com/Shougo/neocomplete.vim) needs
a working Lua installation). This means, those interpreters have to be
installed in addition to ViAI. Without it ViAI won't be able to use that feature!
You can find those interpreters here:

* [Strawberry Perl](https://strawberryperl.com/) 5.38
* <del>[ActiveTcl](https://www.activestate.com/activetcl/downloads) 8.6.6</del> (currently disabled)
* [LuaBinaries](https://luabinaries.sourceforge.net/download.html) 5.4
* [Python 2](https://www.python.org/downloads/) 2.7
* [Python 3](https://www.python.org/downloads/) 3.8 or later
* [Racket](https://download.racket-lang.org/releases/8.17/) 8.17 (BC)
* [RubyInstaller](https://rubyinstaller.org/downloads/) 3.4

Make sure that you install the same architecture (32bit/64bit) for those
libraries that matches your ViAI installation.

For Python 3, ViAI is compiled against Python 3.12 using [Stable
ABI](https://docs.python.org/3.12/c-api/stable.html), and this allows you to
use Python 3.8 or any later version. See also
[`:help python3-stable-abi`](https://vimhelp.org/if_pyth.txt.html#python3-stable-abi)

Additionally the binaries include the new terminal feature for ViAI and
therefore contain the winpty.dll (32bit or 64bit) and the winpty-agent.exe from
the [winpty repository](https://github.com/rprichard/winpty). This feature is
currently considered experimental. Read the help at [:h
terminal.txt](https://vimhelp.org/terminal.txt.html) for more
information.

For supporting better encryption, it comes with the libsodium.dll from the
[libsodium Web site](https://libsodium.org/).
See the help at [:h 'cryptmethod'](https://vimhelp.org/options.txt.html#%27cryptmethod%27)
for more details.

Note: The zip archive might be considered unsecure in Windows, causing Windows
to display a dialog box "These files might be harmful to your computer...". If
you want to disable this warning, you need to "unblock" the zip file. Do that
in the properties dialog of the zip file, first tab General and look for the
security section and click on "Unblock".

See: [ViAI Repository](https://github.com/viai-editor/viai) for the ViAI source.

## Custom Patches
Note: If you want to test some patches, place them in the patch directory with
the extension `.patch`. They will be applied before building ViAI and the binary
will then be tested against the test suite.

## Contributing
Bug reports and feature requests are welcome.  Please open an issue in this
repository.  Pull requests from others are generally not accepted.


# License & Copyright

Most work on vim-win32-installer was done by Ken Takata (@k-takata) and
Christian Brabandt (@chrisbra).

The Vim license applies (see [:h
license](https://vimhelp.org/uganda.txt.html#license)) to all the build
scripts in this repository.  ViAI itself is not included in this repository
and comes with its own license, see the
[ViAI repository](https://github.com/viai-editor/viai).
