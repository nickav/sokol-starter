@echo off

set project_root=%~dp0%
pushd %project_root%
if not exist build (mkdir build)

pushd build

REM Debug Lib
cl /c /D_DEBUG ..\sokol.c /Z7
lib /OUT:sokol_windows_x64_d3d11_debug.lib sokol.obj
del sokol.obj

REM Release Lib
cl /c /O2 /DNDEBUG ..\sokol.c
lib /OUT:sokol_windows_x64_d3d11_release.lib sokol.obj
del sokol.obj

REM D3D11 Debug DLL
cl /D_DEBUG /DIMPL /DSOKOL_DLL ..\sokol.c /Z7 /LDd /MDd /DLL /Fe:sokol_dll_windows_x64_d3d11_debug.dll /link /INCREMENTAL:NO

REM D3D11 Release DLL
cl /D_DEBUG /DIMPL /DSOKOL_DLL ..\sokol.c /LD /MD /DLL /Fe:sokol_dll_windows_x64_d3d11_release.dll /link /INCREMENTAL:NO

popd

popd