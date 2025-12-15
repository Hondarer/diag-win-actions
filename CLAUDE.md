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

## 次のステップ

1. ワークフローを実行して Windows Runner の環境情報を収集
2. 収集した情報を基に sample スクリプトのパスを GitHub Actions 環境に適合させる
3. 修正したスクリプトを Actions で実行してテスト
