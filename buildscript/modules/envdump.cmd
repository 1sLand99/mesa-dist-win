@setlocal
@IF NOT EXIST "%devroot%\%projectname%\buildinfo\" md "%devroot%\%projectname%\buildinfo"
@call "%devroot%\%projectname%\bin\modules\prompt.cmd" enableenvdump "Do you want to dump build environment information to a text file (y/n):"
@IF /I NOT "%enableenvdump%"=="y" GOTO skipenvdump
@echo Dumping build environment information. This will take a short while...
@echo.
@IF NOT %toolchain%==msvc echo Build environment>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF NOT %toolchain%==msvc echo ----------------->>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF %toolchain%==msvc echo Build environment>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc echo ----------------->>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Dump Windows version
@FOR /F tokens^=2^ delims^=[^ eol^= %%a IN ('ver') DO @set winver=%%a
@set winver=%winver:~0,-1%
@FOR /F tokens^=2^ eol^= %%a IN ("%winver%") DO @set winver=%%a
@FOR /F tokens^=1-3^ delims^=.^ eol^= %%a IN ("%winver%") DO @set winver=%%a.%%b.%%c
@IF NOT %toolchain%==msvc echo Windows %winver%>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF %toolchain%==msvc echo Windows %winver%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Dump Resource Hacker version
@IF %rhstate%==1 SET PATH=%devroot%\resource-hacker\;%PATH%
@IF %rhstate% GTR 0 FOR /F delims^=^ eol^= %%a IN ('where ResourceHacker.exe 2^>nul') do @set rhloc="%%~a"
@IF %rhstate% GTR 0 ResourceHacker.exe -open %rhloc% -action extract -mask VERSIONINFO,, -save "%devroot%\%projectname%\buildscript\assets\temp.rc" -log NUL
@IF %rhstate% GTR 0 FOR /F tokens^=1-2^ eol^= %%a IN ('type "%devroot%\%projectname%\buildscript\assets\temp.rc"') do @IF /I "%%a"=="FILEVERSION" set rhver=%%b
@IF %rhstate% GTR 0 IF NOT %toolchain%==msvc echo Ressource Hacker %rhver:,=.%>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF %rhstate% GTR 0 IF %toolchain%==msvc echo Ressource Hacker %rhver:,=.%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Dump 7-Zip version and compression level
@set sevenzipver=null
@set exitloop=1
@if EXIST "%ProgramFiles%\7-Zip\7z.exe" for /f tokens^=1-2^ eol^= %%a IN ('"%ProgramFiles%\7-Zip\7z.exe"') DO @IF defined exitloop IF /I "%%a"=="7-Zip" (
@set "exitloop="
@set sevenzipver=%%b
)
@IF NOT %toolchain%==msvc IF NOT %sevenzipver%==null echo 7-Zip %sevenzipver% ultra compression>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF %toolchain%==msvc IF NOT %sevenzipver%==null echo 7-Zip %sevenzipver% ultra compression>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get Git version
@IF NOT %gitstate%==0 FOR /F tokens^=3^ eol^= %%a IN ('git --version') do @set gitver=%%a
@IF NOT %gitstate%==0 set "gitver=%gitver:.windows=%"
@IF defined gitver IF NOT %toolchain%==msvc echo Git %gitver%>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF defined gitver IF %toolchain%==msvc echo Git %gitver%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get Vulkan SDK version
@set vksdkcount=0
@for /f delims^=^ eol^= %%a in ('dir /A:D /B "%SystemDrive%\VulkanSDK\" 2^>^&1') do @IF EXIST "%SystemDrive%\VulkanSDK\%%~nxa\" (
@set /a vksdkcount+=1
@set vksdkver=%%~nxa
)
@IF NOT EXIST "%VK_SDK_PATH%" IF NOT EXIST "%VULKAN_SDK%" set vksdkcount=0
@IF %vksdkcount% EQU 1 IF NOT %toolchain%==msvc echo LunarG Vulkan SDK %vksdkver%>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF %vksdkcount% EQU 1 IF %toolchain%==msvc echo LunarG Vulkan SDK %vksdkver%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Dump Visual Studio environment
@IF %toolchain%==msvc echo %msvcname% v%msvcver%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@set wsdkcount=0
@IF %toolchain%==msvc for /f delims^=^ eol^= %%a IN ('REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer /s /d /f "Windows SDK" /e 2^>^&1 ^| find "HKEY_"') DO @for /f delims^=^ eol^= %%b IN ('REG QUERY %%a /s /v DisplayVersion 2^>^&1 ^| find "DisplayVersion"') DO @for /f tokens^=3^ eol^= %%c IN ("%%b") DO @(
@set /a wsdkcount+=1
@set vwsdk=%%c
)
@if %wsdkcount% EQU 1 echo Windows SDK %vwsdk%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@set wdkcount=0
@IF %toolchain%==msvc for /f delims^=^ eol^= %%a IN ('REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer /s /d /f "Windows Driver Kit" /e 2^>^&1 ^| find "HKEY_"') DO @for /f delims^=^ eol^= %%b IN ('REG QUERY %%a /s /v DisplayVersion 2^>^&1 ^| find "DisplayVersion"') DO @for /f tokens^=3^ eol^= %%c IN ("%%b") DO @(
@set /a wdkcount+=1
@set vwdk=%%c
)
@if %wdkcount% EQU 1 echo Windows Driver Kit %vwdk%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@if NOT defined nugetstate set nugetstate=0
@IF %rhstate% GTR 0 IF %nugetstate%==1 SET PATH=%devroot%\nuget\;%PATH%
@IF %rhstate% GTR 0 IF %nugetstate% GTR 0 FOR /F delims^=^ eol^= %%a IN ('where nuget.exe 2^>nul') do @set nugetloc="%%~a"
@IF %rhstate% GTR 0 IF %nugetstate% GTR 0 ResourceHacker.exe -open %nugetloc% -action extract -mask VERSIONINFO,, -save "%devroot%\%projectname%\buildscript\assets\temp.rc" -log NUL
@IF %rhstate% GTR 0 IF %nugetstate% GTR 0 FOR /F tokens^=1-2^ eol^= %%a IN ('type "%devroot%\%projectname%\buildscript\assets\temp.rc"') do @IF /I "%%a"=="FILEVERSION" set nugetver=%%b
@IF defined nugetver IF %toolchain%==msvc echo Nuget Commandline tool %nugetver:,=.%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Dump Python environment
@IF %toolchain%==msvc echo Python %pythonver%>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc echo.>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc echo Python packages>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc echo --------------->>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc FOR /F skip^=2^ delims^=^ eol^= %%a IN ('"%devroot%\%projectname%\buildscript\assets\venv\Scripts\python.exe" -W ignore -m pip list --disable-pip-version-check') do @echo %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc echo.>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get CMake version
@IF %toolchain%==msvc IF "%cmakestate%"=="1" set PATH=%devroot%\cmake\bin\;%PATH%
@IF %toolchain%==msvc IF NOT "%cmakestate%"=="0" IF NOT "%cmakestate%"=="" set exitloop=1
@IF %toolchain%==msvc IF NOT "%cmakestate%"=="0" IF NOT "%cmakestate%"=="" for /f tokens^=3^ eol^= %%a IN ('cmake --version') do @if defined exitloop (
set "exitloop="
echo CMake %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
)

@rem Get Ninja version
@IF %toolchain%==msvc IF "%ninjastate%"=="1" set PATH=%devroot%\ninja\;%PATH%
@IF %toolchain%==msvc IF NOT "%ninjastate%"=="0" IF NOT "%ninjastate%"=="" for /f eol^= %%a IN ('ninja --version') do @echo Ninja %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get LLVM version
@IF %toolchain%==msvc IF EXIST "%devroot%\llvm\build\%hostabi%\bin\llvm-config.exe" FOR /F eol^= %%a IN ('"%devroot%\llvm\build\%hostabi%\bin\llvm-config.exe" --version') do @echo LLVM %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc IF EXIST "%devroot%\llvmold\build\%hostabi%\bin\llvm-config.exe" FOR /F eol^= %%a IN ('"%devroot%\llvmold\build\%hostabi%\bin\llvm-config.exe" --version') do @echo Old LLVM %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get SPIRV Tools version
@IF %toolchain%==msvc IF EXIST "%devroot%\spirv-tools\build\%abi%\bin\" for /f tokens^=1-2^ eol^= %%a IN ('type "%devroot%\spirv-tools\build\%abi%\lib\pkgconfig\SPIRV-Tools.pc"') do @IF /I "%%a"=="Version:" echo SPIRV Tools %%b>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get flex and bison version
@IF %toolchain%==msvc IF %flexstate%==1 set PATH=%flexloc%\;%PATH%
@IF %toolchain%==msvc IF NOT %flexstate%==0 set exitloop=1
@IF %toolchain%==msvc IF NOT %flexstate%==0 for /f delims^=^ eol^= %%a IN ('where changelog.md 2^>nul') do @for /f tokens^=3^ skip^=6^ eol^= %%b IN ('type "%%~a"') do @if defined exitloop (
set "exitloop="
echo Winflexbison package %%b>>"%devroot%\%projectname%\buildinfo\msvc.txt"
)
@IF %toolchain%==msvc IF NOT %flexstate%==0 for /f tokens^=2^ eol^= %%a IN ('win_flex --version 2^>nul') do @echo flex %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc IF NOT %flexstate%==0 for /f tokens^=2^ eol^= %%a IN ('flex --version 2^>nul') do @echo flex %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF %toolchain%==msvc IF NOT %flexstate%==0 set exitloop=1
@IF %toolchain%==msvc IF NOT %flexstate%==0 for /f tokens^=4^ eol^= %%a IN ('win_bison --version 2^>nul') do @if defined exitloop (
set "exitloop="
echo Bison %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
)
@IF %toolchain%==msvc IF NOT %flexstate%==0 set exitloop=1
@IF %toolchain%==msvc IF NOT %flexstate%==0 for /f tokens^=4^ eol^= %%a IN ('bison --version 2^>nul') do @if defined exitloop (
set "exitloop="
echo Bison %%a>>"%devroot%\%projectname%\buildinfo\msvc.txt"
)

@rem Get pkgconf/pkg-config version
@set pkgconfigver=null
@IF %toolchain%==msvc IF %pkgconfigstate% GTR 0 FOR /F eol^= %%a IN ('"%pkgconfigloc%\pkg-config.exe" --version') do @set pkgconfigver=%%a
@IF NOT "%pkgconfigver%"=="null" IF %pkgconfigver:~0,1%==0 set pkgconfigver=pkg-config %pkgconfigver%
@IF NOT "%pkgconfigver%"=="null" IF NOT %pkgconfigver:~0,1%==0 set pkgconfigver=pkgconf %pkgconfigver%
@IF NOT "%pkgconfigver%"=="null" echo %pkgconfigver%>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Get zlib version
@set exitloop=1
@IF %toolchain%==msvc for /f tokens^=2^ delims^=^=^ eol^= %%a IN ('type "%devroot%\%projectname%\buildscript\mesonsubprojects\zlib.wrap"') DO @for /f tokens^=2^ delims^=_^ eol^= %%b IN ("%%a") DO @for /f tokens^=1^ delims^=-^ eol^= %%c IN ("%%b") DO @IF defined exitloop (
echo zlib %%c>>"%devroot%\%projectname%\buildinfo\msvc.txt"
set "exitloop="
)

@rem Get OpenCLonD3D12 ICD version
@if %gitstate% GTR 0 IF EXIST "%devroot%\clon12\" cd "%devroot%\clon12"
@if %gitstate% GTR 0 IF EXIST "%devroot%\clon12\" for /f tokens^=1^-3^ delims^=^-^,^  %%a IN ('git show -s --format^=%%ci') DO @(
@IF %toolchain%==msvc echo OpenCLonD3D12 ICD %%a.%%b.%%c>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF NOT %toolchain%==msvc echo OpenCLonD3D12 ICD %%a.%%b.%%c>>"%devroot%\%projectname%\buildinfo\mingw.txt"
)

@rem Get libva and VA-API versions
@IF %toolchain%==msvc IF EXIST "%devroot%\libva\build\%abi%\lib\pkgconfig\libva-win32.pc" for /f tokens^=1^-2^ delims^=^=^ eol^= %%a IN ('type "%devroot%\libva\build\%abi%\lib\pkgconfig\libva-win32.pc"') DO @(
@if "%%a"=="libva_version" echo libva %%b>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@if "%%a"=="va_api_version" echo VA-API %%b>>"%devroot%\%projectname%\buildinfo\msvc.txt"
)

@rem Get DirectX headers version
@set exitloop=1
@for /f delims^=^ eol^= %%a in ('dir /b /a^:d "%devroot%\mesa\subprojects\DirectX-Header*" 2^>^&1') do @IF EXIST "%devroot%\mesa\subprojects\%%~nxa\CMakeLists.txt" for /f tokens^=1^-2^ eol^= %%b IN ('type "%devroot%\mesa\subprojects\%%~nxa\CMakeLists.txt"') DO @if /I "%%b"=="version" if defined exitloop (
@IF %toolchain%==msvc echo DirectX headers %%c>>"%devroot%\%projectname%\buildinfo\msvc.txt"
@IF NOT %toolchain%==msvc echo DirectX headers %%c>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@set "exitloop="
)

@rem Add zstd to build environment info
@IF %toolchain%==msvc if EXIST "%devroot%\zstd\zstd\%hostabi%\lib\pkgconfig\libzstd.pc" FOR /F tokens^=1-2^ eol^= %%a IN ('type "%devroot%\zstd\zstd\%hostabi%\lib\pkgconfig\libzstd.pc"') DO @IF /I "%%a"=="Version:" echo zstd %%b>>"%devroot%\%projectname%\buildinfo\msvc.txt"

@rem Dump MSYS2 environment
@IF NOT %toolchain%==msvc echo.>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF NOT %toolchain%==msvc echo MSYS2 environment>>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF NOT %toolchain%==msvc echo ----------------->>"%devroot%\%projectname%\buildinfo\mingw.txt"
@IF NOT %toolchain%==msvc %runmsys% /usr/bin/pacman -Q>>"%devroot%\%projectname%\buildinfo\mingw.txt"

@rem Finished environment information dump.
@echo Done.
@IF NOT %toolchain%==msvc echo Environment information has been written to "%devroot%\%projectname%\buildinfo\mingw.txt".
@IF %toolchain%==msvc echo Environment information has been written to "%devroot%\%projectname%\buildinfo\msvc.txt".
@echo.

:skipenvdump
@endlocal