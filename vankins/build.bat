@echo off
cls

set EXE_NAME=vankins
del %EXE_NAME%.exe
del %EXE_NAME%.obj
del %EXE_NAME%.lst
del %EXE_NAME%.ilk
del %EXE_NAME%.pdb

set DRIVE_LETTER=%1:
set PATH=%DRIVE_LETTER%\Assembly\masm;c:\Windows;c:\Windows\system32
set INCLUDE=%DRIVE_LETTER%\Assembly

ml -Zi -c -coff -Fl %EXE_NAME%.asm
link /libpath:%DRIVE_LETTER%\Assembly %EXE_NAME%.obj io.obj kernel32.lib /debug /out:%EXE_NAME%.exe /subsystem:console /entry:start

%EXE_NAME%.exe < vankins_in.txt
