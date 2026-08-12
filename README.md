# dotfiles

Mac mini と MacBook Air で共有する設定ファイル。

## claude/ — Claude Code のグローバル設定

| ファイル | 同期方式 | 備考 |
|---|---|---|
| `CLAUDE.md` | シンボリックリンク | `~/.claude/CLAUDE.md` から参照。編集は即座に両方へ反映される（要 push/pull） |
| `settings.json` | コピー | Claude Code 自身が書き換えるため、`sync.sh` で明示的にやり取りする |

### 新しいマシンでの初回セットアップ

```bash
git clone <このリポジトリ> ~/dotfiles
cd ~/dotfiles/claude
./sync.sh link
```

### 日常の運用

このマシンで設定を変えたとき（`/model` での変更を含む）:

```bash
cd ~/dotfiles/claude && ./sync.sh push && git add -A && git commit -m "chore: settings 更新" && git push
```

他のマシンの変更を取り込むとき:

```bash
cd ~/dotfiles && git pull && ./claude/sync.sh pull
```

## 同期しないもの

`~/.claude/` 配下には次のものが含まれるが、いずれも**同期対象外**とする。

- `.credentials.json` — 認証トークン。リポジトリに入れてはならない
- `sessions/`、`history.jsonl`、`projects/` — 会話履歴。マシン固有
- `plugins/` — 各マシンで `claude plugin install` により再構築する

## プロジェクト固有の設定について

各リポジトリの `.claude/`（スキル、`settings.local.json`、プロジェクトの `CLAUDE.md`）は
そのリポジトリ自身で Git 管理されているため、ここでは扱わない。
`git pull` すれば自動的に両マシンで揃う。
