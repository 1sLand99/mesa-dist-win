@setlocal
@rem Get and build pkgconf as best pkg-config implementation for Mesa3D Meson build.
@if NOT EXIST "%devroot%\pkgconf\" IF %gitstate%==0 echo Couldn't get pkgconf. Falling back to pkg-config...
@if NOT EXIST "%devroot%\pkgconf\" IF %gitstate%==0 echo.
@if NOT EXIST "%devroot%\pkgconf\" IF %gitstate%==0 GOTO missingpkgconf
@cd "%devroot%\"
@if EXIST "%devroot%\pkgconf\.git\" IF %gitstate% GTR 0 (
@echo Updating pkgconf source code...
@cd pkgconf
@for /f tokens^=2^ delims^=/^ eol^= %%a in ('git symbolic-ref --short refs/remotes/origin/HEAD 2^>^&^1') do @git checkout %%a
@git pull --progress --tags --recurse-submodules origin
)
@if NOT EXIST "%devroot%\pkgconf\.git\" IF %gitstate% GTR 0 (
@echo Getting pkgconf source code...
@git clone https://gitea.treehouse.systems/ariadne/pkgconf.git --recurse-submodules pkgconf
@if NOT EXIST "pkgconf\.git\" git clone https://github.com/pkgconf/pkgconf.git --recurse-submodules pkgconf
@cd pkgconf
)
@IF %gitstate% GTR 0 (
@git checkout pkgconf-2.5.1
@echo.
)
@IF EXIST pkgconf\pkg-config.exe if %cimode% EQU 0 set buildpkgconf=n
@IF EXIST pkgconf\pkg-config.exe call "%devroot%\%projectname%\bin\modules\prompt.cmd" buildpkgconf "Do you want to rebuild pkgconf (y/n):"
@IF NOT EXIST pkgconf\pkg-config.exe set buildpkgconf=y
@IF NOT EXIST pkgconf\pkg-config.exe echo Begin pkgconf build...
@IF NOT EXIST pkgconf\pkg-config.exe echo.
@IF /I NOT "%buildpkgconf%"=="y" GOTO missingpkgconf
@call %vsenv% %hostabi%
@cd "%devroot%\pkgconf"
@echo.
@IF EXIST "pkgconf\" RD /S /Q pkgconf
@call "%devroot%\%projectname%\buildscript\modules\useninja.cmd"
@IF /I NOT "%useninja%"=="y" echo Configuring pkgconf build with : %mesonloc% setup pkgconf --backend=vs --buildtype=release
@IF /I "%useninja%"=="y" echo Configuring pkgconf build with : %mesonloc% setup pkgconf --backend=ninja --buildtype=release
@echo.
@IF /I NOT "%useninja%"=="y" %mesonloc% setup pkgconf --backend=vs --buildtype=release
@IF /I "%useninja%"=="y" %mesonloc% setup pkgconf --backend=ninja --buildtype=release
@echo.
@pause
@echo.
@cd pkgconf
@IF /I NOT "%useninja%"=="y" echo Performing pkgconf build with : msbuild pkgconf.sln /m^:%throttle% /v^:m
@IF /I "%useninja%"=="y" echo Performing pkgconf build with : ninja -j %throttle%
@echo.
@IF /I NOT "%useninja%"=="y" call "%devroot%\%projectname%\buildscript\modules\trybuild.cmd" msbuild pkgconf.sln /m^:%throttle% /v^:m
@IF /I "%useninja%"=="y" call "%devroot%\%projectname%\buildscript\modules\trybuild.cmd" ninja -j %throttle%
@echo.
@IF EXIST pkgconf.exe REN pkgconf.exe pkg-config.exe

:missingpkgconf
@endlocal
@cd "%devroot%\"