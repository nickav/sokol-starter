@echo off

set project_root=%~dp0%

set libs=..\src\third_party\sokol\build\sokol_windows_x64_d3d11_debug.lib
set flags=/Od -Oi -Zo -Z7 -FC -Gm- -GR- /Zc:strictStrings-
set exe=main.exe

pushd %project_root%

if not exist .\src\third_party\sokol\build (call .\src\third_party\sokol\build.bat)

if not exist build (mkdir build)
pushd build

    if not exist ..\src\shaders\triangle.glsl.h (
        ..\tools\sokol-tools-bin\bin\win32\sokol-shdc.exe -i ..\src\shaders\triangle.glsl -o ..\src\shaders\triangle.glsl.h -l glsl430:hlsl5:metal_macos -f sokol
        IF %errorlevel% NEQ 0 (popd && goto end)
    )

    cl -nologo %flags% -DDEBUG=1 /I ..\src ..\src\main.c /link %libs% -subsystem:windows -incremental:no -opt:ref -OUT:%exe%
    .\%exe%

popd

popd
exit /B %errorlevel%