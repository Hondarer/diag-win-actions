# VSBT PATH 動的追加スクリプト (PowerShell) - GitHub Actions 専用
# MSVC と Windows SDK を現在のセッションの環境変数に追加します

# GitHub Actions 環境の Visual Studio インストールパスを取得
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsInstallPath = & $vswhere -latest -property installationPath
$vsbtBase = $vsInstallPath

$msvcBin = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64"
$sdkBin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.26100.0\x64"
$sdkUcrtBin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.26100.0\x64\ucrt"
$diaBin = Join-Path $vsbtBase "DIA SDK\bin"

$msvcInclude = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207\include"
$sdkUcrtInclude = "${env:ProgramFiles(x86)}\Windows Kits\10\Include\10.0.26100.0\ucrt"
$sdkSharedInclude = "${env:ProgramFiles(x86)}\Windows Kits\10\Include\10.0.26100.0\shared"
$sdkUmInclude = "${env:ProgramFiles(x86)}\Windows Kits\10\Include\10.0.26100.0\um"
$sdkWinrtInclude = "${env:ProgramFiles(x86)}\Windows Kits\10\Include\10.0.26100.0\winrt"
$sdkCppWinrtInclude = "${env:ProgramFiles(x86)}\Windows Kits\10\Include\10.0.26100.0\cppwinrt"
$diaInclude = Join-Path $vsbtBase "DIA SDK\include"

$msvcLib = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207\lib\x64"
$sdkUcrtLib = "${env:ProgramFiles(x86)}\Windows Kits\10\Lib\10.0.26100.0\ucrt\x64"
$sdkUmLib = "${env:ProgramFiles(x86)}\Windows Kits\10\Lib\10.0.26100.0\um\x64"
$diaLib = Join-Path $vsbtBase "DIA SDK\lib"

# MSVC パスの存在確認
if (-not (Test-Path $msvcBin)) {
    Write-Host "Error: MSVC path not found: $msvcBin"
    exit 1
}

# Windows SDK パスの存在確認
if (-not (Test-Path $sdkBin)) {
    Write-Host "Error: Windows SDK bin path not found: $sdkBin"
    exit 1
}

# 環境変数を設定 (常に上書き)
$env:VSCMD_ARG_HOST_ARCH = "x64"
$env:VSCMD_ARG_TGT_ARCH = "x64"
$env:VCToolsVersion = "14.44.35207"
$env:WindowsSDKVersion = "10.0.26100.0"
$env:VCToolsInstallDir = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207"
$env:WindowsSdkBinPath = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"

$pathsToAdd = @($msvcBin, $sdkBin, $sdkUcrtBin, $diaBin)
$currentPath = $env:PATH
$pathChanged = $false

foreach ($pathToAdd in $pathsToAdd) {
    # 既存の PATH にパスが含まれているかチェック
    $pathExists = $currentPath -split ';' | Where-Object { $_ -eq $pathToAdd }

    if ($pathExists) {
        # Write-Host "PATH already set: $pathToAdd"
    } else {
        # パスを先頭に追加
        $env:PATH = "$pathToAdd;$env:PATH"
        $pathChanged = $true
    }
}

# INCLUDE と LIB は常に上書き
$env:INCLUDE = "$msvcInclude;$sdkUcrtInclude;$sdkSharedInclude;$sdkUmInclude;$sdkWinrtInclude;$sdkCppWinrtInclude;$diaInclude"
$env:LIB = "$msvcLib;$sdkUcrtLib;$sdkUmLib;$diaLib"

if ($pathChanged) {
    Write-Host "VSBT PATH addition completed."
} else {
    Write-Host "VSBT PATH already set."
}
