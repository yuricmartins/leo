#!/bin/bash
set -e
echo "🦁 Installing Leo..."
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git clone --depth 1 https://github.com/yuricmartins/leo.git
cd leo
chmod +x build.sh && ./build.sh
cd ~
rm -rf "$TMPDIR"
echo "🦁 Done! Leo is in your menu bar."
