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

### setup-reportgenerator.yml

ReportGenerator のセットアップと動作確認用ワークフローです。以下の処理を実行します:

1. .NET SDK のセットアップ
2. ReportGenerator を .NET グローバルツールとしてインストール
3. バージョン確認とヘルプ表示
4. サンプルの Cobertura カバレッジファイルを使用したレポート生成テスト
5. 生成されたレポートを artifacts としてアップロード

ReportGenerator のインストール方法:

```powershell
dotnet tool install --global dotnet-reportgenerator-globaltool
```

使用例:

```powershell
reportgenerator `
  -reports:"TestResults\coverage.cobertura.xml" `
  -targetdir:"CoverageReport" `
  -reporttypes:"Html;Badges;Cobertura"
```

実行タイミング:

- main ブランチへの push
- main ブランチへの pull request
- 手動実行 (workflow_dispatch)

## GitHub Actions Windows Runner 環境調査結果

> **調査日**: 2025-12-16 (Run ID: 20249876191, 52309684289)

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

PATH に含まれている開発ツール (バージョン情報):

- **cmake**: `C:\Program Files\CMake\bin\cmake.exe`
  - バージョン: 3.31.6
- **ninja**: `C:\ProgramData\Chocolatey\bin\ninja.exe`
  - バージョン: 1.13.2
- **make**: `C:\mingw64\bin\make.exe`
  - バージョン: GNU Make 4.4.1
- **gcc**: `C:\mingw64\bin\gcc.exe`
  - バージョン: 15.2.0 (x86_64-posix-seh-rev0, Built by MinGW-Builds project)
- **g++**: `C:\mingw64\bin\g++.exe`
  - バージョン: 15.2.0 (x86_64-posix-seh-rev0, Built by MinGW-Builds project)
- **clang**: `C:\Program Files\LLVM\bin\clang.exe`
  - バージョン: 20.1.8
- **Chocolatey**: 2.6.0

注: `C:\mingw64` は Git とは別の MinGW インストール

## 実装の説明

### ローカル環境と GitHub Actions 環境の違い

**ローカル環境** (sample ディレクトリのスクリプト):
- `Add-MinGW-Path`: スクリプトと同じディレクトリの `git\mingw64\bin` を参照
- `Add-VSBT-Env-x64`: スクリプトと同じディレクトリの `vsbt` を参照

**GitHub Actions 環境** (.github/workflows のスクリプト):
- `Add-MinGW-Path`: 不要 (既に PATH に含まれている)
- `Add-VSBT-Env-x64`: Visual Studio は `C:\Program Files\Microsoft Visual Studio\2022\Enterprise` にインストール済み

### 実装方針

GitHub Actions 専用の実装として以下を採用:

- **互換性は考慮不要**: ローカル環境との互換性は不要
- **Add-MinGW-Path**: GitHub Actions では不要 (スクリプト作成せず)
- **Add-VSBT-Env-x64**:
  - `.github/workflows` に GitHub Actions 専用版を配置
  - vswhere.exe で Visual Studio のインストールパスを動的取得
  - スクリプト構造は元のロジックを維持
  - MSVC 14.44.35207 と Windows SDK 10.0.26100.0 が見つからない場合はエラー終了
  - GitHub Actions の環境変数永続化メカニズムを使用

## 実装内容

### .github/workflows/Add-VSBT-Env-x64.ps1

GitHub Actions 専用の VSBT 環境設定スクリプトを作成しました。

**ファイル構成**:

```
D:\Users\tetsuo\Local\repos\diag-win-actions
├── .github
│   └── workflows
│       ├── Add-VSBT-Env-x64.ps1       ← GitHub Actions 専用
│       ├── env-diagnostics.yml
│       └── test-vsbt-setup.yml
└── sample
    ├── Add-MinGW-Path.cmd
    ├── Add-MinGW-Path.ps1
    ├── Add-VSBT-Env-x64.cmd
    └── Add-VSBT-Env-x64.ps1          ← ローカル環境用 (元のまま)
```

**主な実装内容**:

- L5-7: `vswhere.exe` を使用して Visual Studio のインストールパスを動的取得
  ```powershell
  $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
  $vsInstallPath = & $vswhere -latest -property installationPath
  $vsbtBase = $vsInstallPath
  ```
- Windows SDK は `${env:ProgramFiles(x86)}\Windows Kits\10` から直接参照
- MSVC 14.44.35207 と Windows SDK 10.0.26100.0 の存在確認を実施
- 見つからない場合はエラー終了 (`exit 1`)
- GitHub Actions の環境変数永続化メカニズムを使用:
  - `$env:GITHUB_PATH` に PATH を追加
  - `$env:GITHUB_ENV` に環境変数 (INCLUDE, LIB, VCToolsVersion など) を追加

### .github/workflows/test-vsbt-setup.yml

VSBT 環境設定スクリプトをテストするワークフローを作成しました。

テスト内容:

1. VSBT 環境設定スクリプトの実行
2. MSVC コンパイラ (cl.exe) の存在確認
3. 環境変数の検証 (INCLUDE, LIB, VCToolsVersion など)
4. 簡単な C プログラムのコンパイルと実行
5. 簡単な C++ プログラムのコンパイルと実行

### .github/workflows/env-diagnostics.yml の修正

Windows Runner 環境診断ワークフローに以下の修正を実施しました:

**修正内容**:

1. **Chocolatey エラーの修正**: `--local-only` オプションが廃止されたため `choco --version` に変更
2. **VSBT スクリプト呼び出し追加**: checkout の直後に `Add-VSBT-Env-x64.ps1` を実行
3. **Visual Studio と MSVC チェックの拡張**:
   - VSBT 環境変数の確認 (VCToolsVersion, VCToolsInstallDir, WindowsSDKVersion など)
   - MSVC 14.44.35207 のパス存在確認
   - MSVC バイナリの一覧表示 (先頭 10 個)
4. **Windows SDK チェックの拡張**:
   - SDK 10.0.26100.0 の bin/include/lib の存在確認
   - 各ディレクトリの内容表示
5. **開発ツールのバージョン表示追加**:
   - cmake, ninja, make, gcc, g++, clang の各ツールについて
   - パスとバージョン情報を両方表示

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

## 作業履歴

### 2025-12-19

1. **ReportGenerator セットアップ**
   - GitHub Actions で ReportGenerator を使用するためのセットアップワークフローを作成
   - .NET グローバルツールとしてインストール
   - サンプルカバレッジデータでレポート生成をテスト
   - 生成されたレポートを artifacts としてアップロード

### 2025-12-16

1. **初回環境調査** (Run ID: 20249876191)
   - Windows Runner の環境情報を収集
   - Git MinGW が既に PATH に含まれていることを確認
   - Visual Studio 2022 Enterprise インストール済みだが cl.exe は PATH になし

2. **VSBT スクリプト作成**
   - GitHub Actions 専用の `Add-VSBT-Env-x64.ps1` を実装
   - vswhere.exe で Visual Studio パスを動的取得
   - MSVC 14.44.35207 と Windows SDK 10.0.26100.0 の存在確認

3. **環境変数永続化の問題発見と修正** (Run ID: 52308335504, 52308335518)
   - 問題: `$env:PATH` が次のステップに引き継がれない
   - 修正: `$env:GITHUB_PATH` と `$env:GITHUB_ENV` を使用

4. **診断ワークフローの拡張**
   - VSBT 環境変数の確認項目を追加
   - MSVC と SDK のパス確認を追加
   - 開発ツールのバージョン表示を追加

## 現在の状態

### 完成したファイル

- `.github/workflows/Add-VSBT-Env-x64.ps1`: GitHub Actions で MSVC 環境を設定
- `.github/workflows/test-vsbt-setup.yml`: VSBT スクリプトのテストワークフロー
- `.github/workflows/env-diagnostics.yml`: 環境診断ワークフロー (VSBT 統合済み)
- `.github/workflows/setup-reportgenerator.yml`: ReportGenerator セットアップと動作確認ワークフロー

### 次のステップ

1. 修正したスクリプトでワークフローを再実行
2. cl.exe が正しく PATH に含まれることを確認
3. C/C++ プログラムのコンパイルテストが成功することを確認
4. 必要に応じてバージョン番号の動的検出機能を追加 (現在は 14.44.35207 固定)
