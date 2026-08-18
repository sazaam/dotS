#!/bin/sh
# dotS installer - run on the other machine after extracting the tarball
set -e

# Detect where this script is located (the dotS directory)
DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create skill directories if they don't exist
mkdir -p "$DOTS_DIR/skills"

# Make executable
chmod +x "$DOTS_DIR/s.py"
chmod +x "$DOTS_DIR/s"

# Add to PATH if not already there
if ! grep -q "$DOTS_DIR" "$HOME/.zshrc" 2>/dev/null && \
   ! grep -q "$DOTS_DIR" "$HOME/.bashrc" 2>/dev/null; then
  SHELL_RC="$HOME/.zshrc"
  [ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"
  echo "" >> "$SHELL_RC"
  echo "# dotS tool" >> "$SHELL_RC"
  echo "export PATH=\"$DOTS_DIR:\$PATH\"" >> "$SHELL_RC"
  echo "Added PATH to $SHELL_RC"
fi

# Test
echo "Testing s tool..."
"$DOTS_DIR/s" help > /dev/null 2>&1 && echo "OK: s tool works" || echo "FAIL: check s.py"

echo ""
echo "Done. Run: source $SHELL_RC"
echo "Then try: s list"
