#!/bin/sh
# dotS installer - run on the other machine after cloning the repo.
# Clones straight into ~/.config/opencode/dotS (the repo's canonical home),
# so this script only: adds the CLI to PATH and links OpenCode's commands.
set -e

# Detect where this script is located (the dotS directory)
DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create skill directories if they don't exist
mkdir -p "$DOTS_DIR/skills"

# Make executable
chmod +x "$DOTS_DIR/dots.py"
chmod +x "$DOTS_DIR/dots"

# Add to PATH if not already there
SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"
if ! grep -q "$DOTS_DIR" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# dotS tool" >> "$SHELL_RC"
  echo "export PATH=\"$DOTS_DIR:\$PATH\"" >> "$SHELL_RC"
  echo "Added PATH to $SHELL_RC"
fi

# Link the OpenCode commands namespace (/dots/*) into the config tree.
# The command files live in the repo (single source of truth); OpenCode
# only discovers commands from its own config tree, so a symlink is all
# the install needs. Updates = git pull, nothing to re-copy or move.
if [ -d "$DOTS_DIR/commands/dots" ]; then
  OC_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/commands"
  OC_DEST="$OC_CFG/dots"
  if [ -L "$OC_DEST" ]; then
    echo "OpenCode commands link already present: $OC_DEST"
  elif [ -d "$OC_DEST" ]; then
    echo "WARNING: $OC_DEST is a real directory - move its contents into" >&2
    echo "  $DOTS_DIR/commands/dots and remove it, then re-run." >&2
  else
    mkdir -p "$OC_CFG"
    ln -s "$DOTS_DIR/commands/dots" "$OC_DEST"
    echo "Linked OpenCode commands: $OC_DEST -> $DOTS_DIR/commands/dots"
  fi
fi

# Test
echo "Testing dots tool..."
"$DOTS_DIR/dots" help > /dev/null 2>&1 && echo "OK: dots tool works" || echo "FAIL: check dots.py"

echo ""
echo "Done. Run: source $SHELL_RC"
echo "Then try: dots list"