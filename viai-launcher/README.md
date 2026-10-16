# ViAI launcher

This is a very small program to launch ViAI.

This retrieves the path of (g)viai.exe from the registry settings for GviaiExt:
  - `HKEY_CURRENT_USER\Software\ViAI\Gviai`
  - `HKEY_LOCAL_MACHINE\SOFTWARE\ViAI\Gviai`

The one-click installer will automatically install this by selecting the "ViAI
launchers" option.

If you download a zip package, you can install this manually by copying the
launcher executable files to any directory that is in the PATH environment
variable and setting the registry properly.


## Aliases

If ViAI launcher is copied (or hard-linked) with a different name, it can work
as an alias.

* gviai.exe
  - eviai.exe or egviai.exe -- Easy mode (gviai -y)
  - gviaidiff.exe -- Diff mode (gviai -d)
* viai.exe
  - viaidiff.exe -- Diff mode (viai -d)

The one-click installer automatically creates these hard links.


## Example registry settings

Normally, you don't need to update the registry settings manually. The
one-click installer sets them automatically.
However, if you want to change them manually, see the following examples:

* `example_current_user.reg`
* `example_all_users.reg` (requires admin privileges)


## Build

If you have download the source code, run the following command:

```
nmake -f Make_mvc.mak
```

This will build `gviai.exe` and `viai.exe`.


## Icon

This icon file is a copy of `src/viai.ico` of ViAI.
