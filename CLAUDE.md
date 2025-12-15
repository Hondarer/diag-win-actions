# CLAUDE.md

## プロジェクト概要

このレポジトリは、GitHub Actions の Windows Runner の環境を調査するためのレポジトリです。

## 目的

sample ディレクトリ以下のスクリプトを GitHub Actions に対応させるため、まず Windows Runner の環境情報を収集します。

## スクリプト概要

sample ディレクトリには以下のスクリプトが含まれています:

- `Add-MinGW-Path.cmd` / `Add-MinGW-Path.ps1`
  - Git MinGW バイナリを現在のセッションの PATH に追加
  - ローカル環境では `git\mingw64\bin` と `git\usr\bin` をスクリプトと同じディレクトリから探す

- `Add-VSBT-Env-x64.cmd` / `Add-VSBT-Env-x64.ps1`
  - Visual Studio Build Tools の環境変数を設定
  - MSVC コンパイラと Windows SDK のパスを PATH、INCLUDE、LIB に追加
  - ローカル環境では `vsbt` ディレクトリをスクリプトと同じディレクトリから探す

## GitHub Actions ワークフロー

### env-diagnostics.yml

Windows Runner の環境調査用ワークフローです。以下の情報を収集します:

1. システム情報 (Windows バージョン、アーキテクチャ)
2. 環境変数一覧
3. PATH の詳細
4. Git インストール状況と MinGW パスの存在確認
5. Visual Studio と MSVC コンパイラの状況
6. Windows SDK のバージョンと場所
7. インストール済み開発ツール (cmake, ninja, make, gcc, g++, clang など)
8. ディスク情報とワークスペース構造
9. sample ディレクトリのスクリプト確認

実行タイミング:

- main ブランチへの push
- main ブランチへの pull request
- 手動実行 (workflow_dispatch)

## GitHub Actions Windows Runner 環境調査結果

ワークフロー実行結果 (Run ID: 20249876191)

### 基本環境

- OS: Microsoft Windows Server 2025 (10.0.26100)
- Runner: windows-2025 (Image Version: 20251208.136.1)
- PowerShell: 7.x
- ワークスペース: `D:\a\diag-win-actions\diag-win-actions`

### Git と MinGW

- Git バージョン: 2.52.0.windows.1
- Git インストールパス: `C:\Program Files\Git`
- MinGW パス: `C:\Program Files\Git\mingw64\bin` (存在確認済み)
- usr/bin パス: `C:\Program Files\Git\usr\bin` (存在確認済み)
- PATH に既に含まれている:
  - `C:\Program Files\Git\cmd`
  - `C:\Program Files\Git\mingw64\bin`
  - `C:\Program Files\Git\usr\bin`

### Visual Studio と MSVC

- Visual Studio 2022 Enterprise (バージョン 17.14.36717.8)
- インストールパス: `C:\Program Files\Microsoft Visual Studio\2022\Enterprise`
- **重要**: `cl.exe` は PATH に含まれていない (デフォルトでは利用不可)
- MSVC を使用するには Developer Command Prompt または vcvarsall.bat の実行が必要

### Windows SDK

- SDK ルート: `C:\Program Files (x86)\Windows Kits\10`
- 利用可能な SDK バージョン:
  - Include/Lib: 10.0.10240.0, 10.0.26100.0
  - Bin: 10.0.14393.0, 10.0.15063.0, 10.0.16299.0, 10.0.17134.0, 10.0.26100.0
- アーキテクチャ: arm, arm64, x64, x86

### 開発ツール

PATH に含まれている開発ツール:

- cmake: `C:\Program Files\CMake\bin\cmake.exe`
- ninja: `C:\ProgramData\Chocolatey\bin\ninja.exe`
- make: `C:\mingw64\bin\make.exe`
- gcc: `C:\mingw64\bin\gcc.exe`
- g++: `C:\mingw64\bin\g++.exe`
- clang: `C:\Program Files\LLVM\bin\clang.exe`

注: `C:\mingw64` は Git とは別の MinGW インストール

## スクリプト修正方針

### Add-MinGW-Path スクリプト

GitHub Actions 環境では、Git MinGW は既に PATH に含まれているため、スクリプトの修正が必要:

1. ローカル環境: スクリプトと同じディレクトリの `git\mingw64\bin` を参照
2. GitHub Actions 環境: `C:\Program Files\Git\mingw64\bin` を参照

対応策:

- 環境変数 `GITHUB_ACTIONS` の有無で動作を切り替える
- GitHub Actions 環境では既に PATH に含まれているため、何もしないか確認のみ

### Add-VSBT-Env スクリプト

GitHub Actions 環境では、Visual Studio は別の場所にインストールされているため、パスの修正が必要:

1. ローカル環境: スクリプトと同じディレクトリの `vsbt` を参照
2. GitHub Actions 環境: `C:\Program Files\Microsoft Visual Studio\2022\Enterprise` を参照

対応策:

- 環境変数 `GITHUB_ACTIONS` の有無で動作を切り替える
- vswhere.exe を使用して Visual Studio のインストールパスを動的に取得
- MSVC のバージョン番号もハードコードせず、動的に検出

## 実装内容

### .github/workflows/Add-VSBT-Env-x64.ps1

GitHub Actions 専用の VSBT 環境設定スクリプトを作成しました。

主な変更点:

- L5-7: `vswhere.exe` を使用して Visual Studio のインストールパスを動的取得
- Windows SDK は `${env:ProgramFiles(x86)}\Windows Kits\10` から直接参照
- MSVC と Windows SDK の両方で存在確認を実施 (見つからない場合はエラー終了)
- バージョン固定: MSVC 14.44.35207、Windows SDK 10.0.26100.0

### .github/workflows/test-vsbt-setup.yml

VSBT 環境設定スクリプトをテストするワークフローを作成しました。

テスト内容:

1. VSBT 環境設定スクリプトの実行
2. MSVC コンパイラ (cl.exe) の存在確認
3. 環境変数の検証 (INCLUDE, LIB, VCToolsVersion など)
4. 簡単な C プログラムのコンパイルと実行
5. 簡単な C++ プログラムのコンパイルと実行

### env-diagnostics.yml の修正

以下の修正を実施しました:

1. Chocolatey の `--local-only` オプションが廃止されたため、`choco --version` に変更してエラーを回避
2. 先頭に `Add-VSBT-Env-x64.ps1` の呼び出しを追加
3. Visual Studio と MSVC チェックに以下を追加:
   - VSBT 環境変数の確認 (VCToolsVersion, VCToolsInstallDir, WindowsSDKVersion など)
   - MSVC 14.44.35207 の存在確認とバイナリ一覧表示
4. Windows SDK チェックに以下を追加:
   - SDK 10.0.26100.0 の bin/include/lib の存在確認
   - 各ディレクトリの内容表示

## 問題と修正

### 初回実行での問題 (Run ID: 52308335504, 52308335518)

**問題**: VSBT スクリプトが "VSBT PATH addition completed." と表示されるが、次のステップで cl.exe が PATH に見つからない

**原因**: GitHub Actions では各ステップが独立した PowerShell セッションで実行されるため、`$env:PATH` などの環境変数は次のステップに引き継がれない

**修正内容**:

1. `$env:PATH` の代わりに `$env:GITHUB_PATH` に書き込むように変更
2. `$env:INCLUDE`, `$env:LIB` などの環境変数も `$env:GITHUB_ENV` に書き込むように変更
3. GitHub Actions の環境変数永続化メカニズムを使用

修正後のスクリプトでは以下を実施:

- `Add-Content -Path $env:GITHUB_PATH -Value $pathToAdd` で PATH を永続化
- `Add-Content -Path $env:GITHUB_ENV -Value "KEY=VALUE"` で環境変数を永続化

## 次のステップ

1. 修正したスクリプトでワークフローを再実行
2. cl.exe が正しく PATH に含まれることを確認
3. C/C++ プログラムのコンパイルテストが成功することを確認
