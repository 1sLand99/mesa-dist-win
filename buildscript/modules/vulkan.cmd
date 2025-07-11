@setlocal
@set vksdkstd=1
@if %cimode% EQU 0 set vksdkselect=0
@IF NOT EXIST "%VK_SDK_PATH%" IF NOT EXIST "%VULKAN_SDK%" set vksdkstd=0

:selectvksdk
@IF %vksdkstd% EQU 1 echo Select Vulkan SDK
@IF %vksdkstd% EQU 1 echo 1. LunarG Vulkan SDK
@IF %vksdkstd% EQU 1 echo 2. MSYS2 MinGW-W64 vulkan-devel
@IF %vksdkstd% EQU 1 call "%devroot%\%projectname%\bin\modules\prompt.cmd" vksdkselect "Enter choice:"
@IF %vksdkstd% EQU 1 IF NOT "%vksdkselect%"=="1" IF NOT "%vksdkselect%"=="2" (
@echo Invalid entry.
@echo.
@GOTO selectvksdk
)
@IF %vksdkstd% EQU 0 set vksdkselect=2
@endlocal&set vksdkselect=%vksdkselect%
