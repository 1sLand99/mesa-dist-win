@setlocal ENABLEDELAYEDEXPANSION
@set dxilloc=null
@IF %dxilloc%==null for /f delims^=^ eol^= %%a in ('@call "%devroot%\%projectname%\buildscript\modules\winsdkloc.cmd"') do @IF EXIST "%%a" for /f delims^=^ eol^= %%b in ('dir /b /s "%%a\bin\dxil.dll" 2^>^&1') do @if EXIST "%%b" (
@set dxilwinsdk="%%~b"
@IF "!dxilwinsdk:~-13,3!"=="%abi%" set dxilloc="%%~b"
)
@set "dxilwinsdk="
@echo %dxilloc%