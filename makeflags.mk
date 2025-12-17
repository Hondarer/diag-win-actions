# Makefile の設定をオーバーライド

ifeq ($(OS),Windows_NT)
    # Windows 環境では link.exe を明示的に指定
    # bash から実行される際に Unix の link コマンドではなく MSVC の link.exe を使用するため
    LD := link.exe
endif
