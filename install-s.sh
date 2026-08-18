#!/bin/sh
# dotS installer - run on the other machine after extracting the tarball
set -e

INSTALL_DIR="$HOME/.config/opencode"

# Create directories
mkdir -p "$INSTALL_DIR/ctx/skills"

# Extract files (assuming tarball is already extracted to INSTALL_DIR)
# If running from the tarball directly:
# tar xzf dotS-complete.tar.gz -C "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/s.py"
chmod +x "$INSTALL_DIR/s"

# Add to PATH if not already there
if ! grep -q 'opencode' "$HOME/.zshrc" 2>/dev/null && \
   ! grep -q 'opencode' "$HOME/.bashrc" 2>/dev/null; then
  SHELL_RC="$HOME/.zshrc"
  [ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"
  echo "" >> "$SHELL_RC"
  echo "# dotS tool" >> "$SHELL_RC"
  echo 'export PATH="$HOME/.config/opencode:$PATH"' >> "$SHELL_RC"
  echo "Added PATH to $SHELL_RC"
fi

# Test
echo "Testing s tool..."
"$INSTALL_DIR/s" help > /dev/null 2>&1 && echo "OK: s tool works" || echo "FAIL: check s.py"

echo ""
echo "Done. Run: source ~/.zshrc"
echo "Then try: s list"
