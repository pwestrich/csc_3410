@echo off
cls

set EXE_NAME=fallout_driver
del %EXE_NAME%.exe
del %EXE_NAME%.obj
del %EXE_NAME%.lst
del %EXE_NAME%.ilk
del %EXE_NAME%.pdb

set DRIVE_LETTER=%1:
set PATH=%DRIVE_LETTER%\Assembly\masm;c:\Windows;c:\Windows\system32
set INCLUDE=%DRIVE_LETTER%\Assembly
set LINK_STUFF=%EXE_NAME%.obj io.obj strutils.obj fallout_procs.obj

ml -Zi -c -coff -Fl %EXE_NAME%.asm 
ml -Zi -c -coff -Fl fallout_procs.asm
link /libpath:%DRIVE_LETTER%\Assembly %LINK_STUFF% kernel32.lib /debug /out:%EXE_NAME%.exe /subsystem:console /entry:start

%EXE_NAME%.exe < fallout.txt
