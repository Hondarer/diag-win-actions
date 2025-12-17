# VSBT PATH 動的追加スクリプト (PowerShell) - GitHub Actions 専用
# MSVC と Windows SDK を GitHub Actions の環境変数に追加します

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

# GitHub Actions の環境変数に PATH を追加
# 注: GitHub Actions では後に追加したパスほど PATH の先頭に来るため、
#     MSVC のパスを最後に追加することで、link.exe などが確実に MSVC のものになる
$pathsToAdd = @($diaBin, $sdkUcrtBin, $sdkBin, $msvcBin)

foreach ($pathToAdd in $pathsToAdd) {
    Write-Host "Adding to PATH: $pathToAdd"
    Add-Content -Path $env:GITHUB_PATH -Value $pathToAdd
}

# GitHub Actions の環境変数に INCLUDE, LIB などを追加
$includeValue = "$msvcInclude;$sdkUcrtInclude;$sdkSharedInclude;$sdkUmInclude;$sdkWinrtInclude;$sdkCppWinrtInclude;$diaInclude"
$libValue = "$msvcLib;$sdkUcrtLib;$sdkUmLib;$diaLib"

Write-Host "Setting environment variables for GitHub Actions..."
Add-Content -Path $env:GITHUB_ENV -Value "VSCMD_ARG_HOST_ARCH=x64"
Add-Content -Path $env:GITHUB_ENV -Value "VSCMD_ARG_TGT_ARCH=x64"
Add-Content -Path $env:GITHUB_ENV -Value "VCToolsVersion=14.44.35207"
Add-Content -Path $env:GITHUB_ENV -Value "WindowsSDKVersion=10.0.26100.0"
Add-Content -Path $env:GITHUB_ENV -Value "VCToolsInstallDir=$(Join-Path $vsbtBase 'VC\Tools\MSVC\14.44.35207')"
Add-Content -Path $env:GITHUB_ENV -Value "WindowsSdkBinPath=${env:ProgramFiles(x86)}\Windows Kits\10\bin"
Add-Content -Path $env:GITHUB_ENV -Value "INCLUDE=$includeValue"
Add-Content -Path $env:GITHUB_ENV -Value "LIB=$libValue"

# Makefile から呼び出される bash で MSVC ツールを使用するため、環境変数を設定
# CC, CXX, LD, AR を絶対パスで指定することで、bash の PATH に依存せず確実に MSVC ツールが使用される
$clExePath = Join-Path $msvcBin "cl.exe"
$linkExePath = Join-Path $msvcBin "link.exe"
$libExePath = Join-Path $msvcBin "lib.exe"

Add-Content -Path $env:GITHUB_ENV -Value "CC=$clExePath"
Add-Content -Path $env:GITHUB_ENV -Value "CXX=$clExePath"
Add-Content -Path $env:GITHUB_ENV -Value "LD=$linkExePath"
Add-Content -Path $env:GITHUB_ENV -Value "AR=$libExePath"

Write-Host "MSVC tool environment variables set:"
Write-Host "  CC=$clExePath"
Write-Host "  CXX=$clExePath"
Write-Host "  LD=$linkExePath"
Write-Host "  AR=$libExePath"

Write-Host "VSBT environment setup completed."
