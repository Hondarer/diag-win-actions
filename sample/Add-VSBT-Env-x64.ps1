# VSBT PATH 動的追加スクリプト (PowerShell)
# MSVC と Windows SDK を現在のセッションの環境変数に追加します

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vsbtBase = Join-Path $scriptDir "vsbt"

$msvcBin = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64"
$sdkBin = Join-Path $vsbtBase "Windows Kits\10\bin\10.0.26100.0\x64"
$sdkUcrtBin = Join-Path $vsbtBase "Windows Kits\10\bin\10.0.26100.0\x64\ucrt"
$diaBin = Join-Path $vsbtBase "DIA SDK\bin"

$msvcInclude = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207\include"
$sdkUcrtInclude = Join-Path $vsbtBase "Windows Kits\10\Include\10.0.26100.0\ucrt"
$sdkSharedInclude = Join-Path $vsbtBase "Windows Kits\10\Include\10.0.26100.0\shared"
$sdkUmInclude = Join-Path $vsbtBase "Windows Kits\10\Include\10.0.26100.0\um"
$sdkWinrtInclude = Join-Path $vsbtBase "Windows Kits\10\Include\10.0.26100.0\winrt"
$sdkCppWinrtInclude = Join-Path $vsbtBase "Windows Kits\10\Include\10.0.26100.0\cppwinrt"
$diaInclude = Join-Path $vsbtBase "DIA SDK\include"

$msvcLib = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207\lib\x64"
$sdkUcrtLib = Join-Path $vsbtBase "Windows Kits\10\Lib\10.0.26100.0\ucrt\x64"
$sdkUmLib = Join-Path $vsbtBase "Windows Kits\10\Lib\10.0.26100.0\um\x64"
$diaLib = Join-Path $vsbtBase "DIA SDK\lib"

# MSVC パスの存在確認
if (-not (Test-Path $msvcBin)) {
    Write-Host "Error: MSVC path not found: $msvcBin"
    exit 1
}

# 環境変数を設定 (常に上書き)
$env:VSCMD_ARG_HOST_ARCH = "x64"
$env:VSCMD_ARG_TGT_ARCH = "x64"
$env:VCToolsVersion = "14.44.35207"
$env:WindowsSDKVersion = "10.0.26100.0"
$env:VCToolsInstallDir = Join-Path $vsbtBase "VC\Tools\MSVC\14.44.35207"
$env:WindowsSdkBinPath = Join-Path $vsbtBase "Windows Kits\10\bin"

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