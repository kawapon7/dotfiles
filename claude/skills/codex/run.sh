#!/bin/bash
# Codex に読むだけの雑用を頼み、最後の答えだけを標準出力へ返す。
#
#   run.sh <対象フォルダ> "<依頼文>" [字数=800]
#
# 終了コード: 0 成功 / 2 HIBIKI なので断った / 3 Codex が無い / 4 時間切れ / その他 Codex の失敗
# 設計: black_note/docs/superpowers/specs/2026-11-05-codex-delegate-design.md

set -uo pipefail

DIR="${1:-}"
TASK="${2:-}"
LIMIT="${3:-800}"
TIMEOUT_SEC=300

if [ -z "$DIR" ] || [ -z "$TASK" ]; then
  echo "使い方: run.sh <対象フォルダ> \"<依頼文>\" [字数]" >&2
  exit 1
fi

REAL_DIR="$(cd "$DIR" 2>/dev/null && pwd -P)" || { echo "フォルダが無い: $DIR" >&2; exit 1; }

# HIBIKI は指示ではなく仕組みで止める
HIBIKI="$(cd "$HOME/dev/unsou-system" 2>/dev/null && pwd -P)"
if [ -n "$HIBIKI" ] && { [ "$REAL_DIR" = "$HIBIKI" ] || [[ "$REAL_DIR" == "$HIBIKI"/* ]]; }; then
  echo "断りました: HIBIKI（unsou-system）は Codex に回さない決まり" >&2
  exit 2
fi

CODEX="$(command -v codex || true)"
if [ -z "$CODEX" ]; then
  CODEX="/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex"
  [ -x "$CODEX" ] || { echo "Codex が見つからない" >&2; exit 3; }
fi

OUT="$(mktemp -t codex-out)"
LOG="$(mktemp -t codex-log)"
trap 'rm -f "$OUT" "$LOG"' EXIT

PROMPT="決まり: .env・鍵・トークン・認証情報のファイルは開かない。ファイルは変更しない。答えは日本語で${LIMIT}字以内、前置き不要。

依頼: ${TASK}"

# macOS に timeout が無いので perl の alarm で打ち切る
perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SEC" \
  "$CODEX" exec --sandbox read-only --skip-git-repo-check -C "$REAL_DIR" -o "$OUT" "$PROMPT" \
  </dev/null >"$LOG" 2>&1
CODE=$?

if [ "$CODE" -eq 142 ]; then
  echo "時間切れ（${TIMEOUT_SEC}秒）" >&2
  exit 4
fi
if [ "$CODE" -ne 0 ] || [ ! -s "$OUT" ]; then
  echo "Codex が失敗（終了コード $CODE）。記録の末尾:" >&2
  tail -5 "$LOG" >&2
  [ "$CODE" -ne 0 ] && exit "$CODE" || exit 5
fi

cat "$OUT"
