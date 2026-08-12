#!/bin/bash
# Claude Code のグローバル設定を2台のMac間で同期する。
#
#   ./sync.sh pull   リポジトリの settings.json を ~/.claude/ へ反映する（他マシンの変更を取り込む）
#   ./sync.sh push   ~/.claude/settings.json をリポジトリへ取り込む（このマシンの変更を保存する）
#   ./sync.sh link   新しいマシンで初回セットアップする（CLAUDE.md のリンクを張る）
#
# CLAUDE.md はシンボリックリンクのため、このスクリプトによる同期は不要。
# settings.json は Claude Code 自身が書き換える（/model 等）ため、
# リンクにすると書き換え時にリンクが実体ファイルへ置き換わる恐れがある。
# そのためコピー方式とし、明示的に push / pull する。

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

case "${1:-}" in
  pull)
    cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "反映しました: リポジトリ -> $CLAUDE_DIR/settings.json"
    ;;
  push)
    cp "$CLAUDE_DIR/settings.json" "$REPO_DIR/settings.json"
    echo "取り込みました: $CLAUDE_DIR/settings.json -> リポジトリ"
    echo "git commit と push を忘れずに。"
    ;;
  link)
    mkdir -p "$CLAUDE_DIR"
    if [ -e "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
      mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup"
      echo "既存ファイルを CLAUDE.md.backup として退避しました。"
    fi
    ln -sfn "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "セットアップ完了: CLAUDE.md をリンクし、settings.json を配置しました。"
    ;;
  *)
    echo "使い方: ./sync.sh {pull|push|link}" >&2
    exit 1
    ;;
esac
