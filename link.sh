#!/usr/bin/env bash
# Symlink personal configs from this repo into ~/.config.
# Safe to re-run (e.g. after `./setup install`, whose rsync replaces links with copies).
# Existing non-link targets are moved to <target>.bak.<timestamp>.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO/dots/.config"
DST="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

LINKS=(
  starship.toml
  zellij/config.kdl
  kitty
  fish/config.fish
  zed/settings.json
  opencode/opencode.json
  llmfit/theme
  hypr/custom
)

for p in "${LINKS[@]}"; do
  src="$SRC/$p" dst="$DST/$p"
  if [[ ! -e "$src" ]]; then
    echo "skip   $p (missing in repo)"; continue
  fi
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok     $p"; continue
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak.$STAMP"
    echo "backup $p -> $(basename "$dst").bak.$STAMP"
  fi
  ln -s "$src" "$dst"
  echo "link   $p"
done
