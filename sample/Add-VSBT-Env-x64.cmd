@echo off
setlocal enabledelayedexpansion

REM VSBT PATH 動的追加スクリプト
REM MSVC と Windows SDK を現在のセッションの環境変数に追加します

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "VSBT_BASE=%SCRIPT_DIR%\vsbt"

set "MSVC_BIN=%VSBT_BASE%\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64"
set "SDK_BIN=%VSBT_BASE%\Windows Kits\10\bin\10.0.26100.0\x64"
set "SDK_UCRT_BIN=%VSBT_BASE%\Windows Kits\10\bin\10.0.26100.0\x64\ucrt"
set "DIA_BIN=%VSBT_BASE%\DIA SDK\bin"

set "MSVC_INCLUDE=%VSBT_BASE%\VC\Tools\MSVC\14.44.35207\include"
set "SDK_UCRT_INCLUDE=%VSBT_BASE%\Windows Kits\10\Include\10.0.26100.0\ucrt"
set "SDK_SHARED_INCLUDE=%VSBT_BASE%\Windows Kits\10\Include\10.0.26100.0\shared"
set "SDK_UM_INCLUDE=%VSBT_BASE%\Windows Kits\10\Include\10.0.26100.0\um"
set "SDK_WINRT_INCLUDE=%VSBT_BASE%\Windows Kits\10\Include\10.0.26100.0\winrt"
set "SDK_CPPWINRT_INCLUDE=%VSBT_BASE%\Windows Kits\10\Include\10.0.26100.0\cppwinrt"
set "DIA_INCLUDE=%VSBT_BASE%\DIA SDK\include"

set "MSVC_LIB=%VSBT_BASE%\VC\Tools\MSVC\14.44.35207\lib\x64"
set "SDK_UCRT_LIB=%VSBT_BASE%\Windows Kits\10\Lib\10.0.26100.0\ucrt\x64"
set "SDK_UM_LIB=%VSBT_BASE%\Windows Kits\10\Lib\10.0.26100.0\um\x64"
set "DIA_LIB=%VSBT_BASE%\DIA SDK\lib"

REM MSVC パスの存在確認
if not exist "%MSVC_BIN%" (
    echo Error: MSVC path not found: %MSVC_BIN%
    exit /b 1
)

REM 環境変数を設定 (常に上書き)
set "VSCMD_ARG_HOST_ARCH=x64"
set "VSCMD_ARG_TGT_ARCH=x64"
set "VCToolsVersion=14.44.35207"
set "WindowsSDKVersion=10.0.26100.0"
set "VCToolsInstallDir=%VSBT_BASE%\VC\Tools\MSVC\14.44.35207"
set "WindowsSdkBinPath=%VSBT_BASE%\Windows Kits\10\bin"

set "PATH_CHANGED=0"

REM PATH に追加 (重複チェック)
echo %PATH% | findstr /C:"%MSVC_BIN%" >nul
if %ERRORLEVEL% neq 0 (
    set "PATH=%MSVC_BIN%;%PATH%"
    set "PATH_CHANGED=1"
)

echo %PATH% | findstr /C:"%SDK_BIN%" >nul
if %ERRORLEVEL% neq 0 (
    set "PATH=%SDK_BIN%;%PATH%"
    set "PATH_CHANGED=1"
)

echo %PATH% | findstr /C:"%SDK_UCRT_BIN%" >nul
if %ERRORLEVEL% neq 0 (
    set "PATH=%SDK_UCRT_BIN%;%PATH%"
    set "PATH_CHANGED=1"
)

echo %PATH% | findstr /C:"%DIA_BIN%" >nul
if %ERRORLEVEL% neq 0 (
    set "PATH=%DIA_BIN%;%PATH%"
    set "PATH_CHANGED=1"
)

REM INCLUDE に追加 (常に上書き)
set "INCLUDE=%MSVC_INCLUDE%;%SDK_UCRT_INCLUDE%;%SDK_SHARED_INCLUDE%;%SDK_UM_INCLUDE%;%SDK_WINRT_INCLUDE%;%SDK_CPPWINRT_INCLUDE%;%DIA_INCLUDE%"

REM LIB に追加 (常に上書き)
set "LIB=%MSVC_LIB%;%SDK_UCRT_LIB%;%SDK_UM_LIB%;%DIA_LIB%"

if %PATH_CHANGED%==1 (
    echo VSBT PATH addition completed.
) else (
    echo VSBT PATH already set.
)

endlocal & set "PATH=%PATH%" & set "INCLUDE=%INCLUDE%" & set "LIB=%LIB%" & set "VSCMD_ARG_HOST_ARCH=%VSCMD_ARG_HOST_ARCH%" & set "VSCMD_ARG_TGT_ARCH=%VSCMD_ARG_TGT_ARCH%" & set "VCToolsVersion=%VCToolsVersion%" & set "WindowsSDKVersion=%WindowsSDKVersion%" & set "VCToolsInstallDir=%VCToolsInstallDir%" & set "WindowsSdkBinPath=%WindowsSdkBinPath%"