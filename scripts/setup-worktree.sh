#!/bin/sh
set -eu

worktree_root="$(cd "$(dirname "$0")/.." && pwd)"
main_root="$(cd "$(git -C "$worktree_root" rev-parse --git-common-dir)/.." && pwd)"
cd "$worktree_root"

for sibling in account-av apps-av; do
  source_dir="$(cd "$main_root/.." && pwd)/$sibling"
  target_dir="$worktree_root/../$sibling"
  if [ ! -d "$source_dir/web" ]; then
    printf 'setup-worktree: %s is missing beside %s\n' "$sibling" "$main_root" >&2
    exit 1
  fi
  if [ ! -e "$target_dir" ]; then
    ln -s "$source_dir" "$target_dir"
  fi
done

if [ -f "$main_root/.env" ] && [ ! -e "$worktree_root/.env" ]; then
  ln -s "$main_root/.env" "$worktree_root/.env"
fi

pnpm install --frozen-lockfile --reporter=silent

printf 'Worktree ready: %s\n' "$worktree_root"
