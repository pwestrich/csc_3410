@echo off
cls

set EXE_NAME=newton
del %EXE_NAME%.exe
del %EXE_NAME%.obj
del %EXE_NAME%.lst
del %EXE_NAME%.ilk
del %EXE_NAME%.pdb

set DRIVE_LETTER=%1:
set PATH=%DRIVE_LETTER%\Assembly\masm;c:\Windows;c:\Windows\system32
set INCLUDE=%DRIVE_LETTER%\Assembly
set LINK_STUFF=interpolate_driver.obj interpolate.obj atofproc.obj compare_floats.obj ftoaproc.obj interpolate_sort.obj 

ml -Zi -c -coff -Fl interpolate_driver.asm
ml -Zi -c -coff -Fl interpolate.asm 
link /libpath:%DRIVE_LETTER%\Assembly %LINK_STUFF% io.obj kernel32.lib /debug /out:%EXE_NAME%.exe /subsystem:console /entry:start

%EXE_NAME%.exe < points.txt