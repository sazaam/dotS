#!/usr/bin/env bash
# dotS multi-AI installer
# Discovers installed AI coding tools (Antigravity, OpenCode, Claude Code, Cursor, Hermes)
# and links the dotS routing-gate adapters for each one.
# Symlinks keep the repo the single source of truth.
# Updates are instant via `git pull` with nothing to re-copy.

set -euo pipefail

# Detect where this script is located (the dotS directory)
DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"
case "$DOTS_DIR" in
  *[!A-Za-z0-9._/-]*)
    echo "Refusing unsafe install path: $DOTS_DIR" >&2
    exit 1
    ;;
esac

# Parse optional arguments
MODE_ALL=false
MODE_ANTIGRAVITY=false
MODE_OPENCODE=false
MODE_CLAUDE=false
MODE_CURSOR=false
MODE_HERMES=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --all) MODE_ALL=true ;;
    --antigravity) MODE_ANTIGRAVITY=true ;;
    --opencode) MODE_OPENCODE=true ;;
    --claude) MODE_CLAUDE=true ;;
    --cursor) MODE_CURSOR=true ;;
    --hermes) MODE_HERMES=true ;;
    --force) FORCE=true ;;
    -h|--help)
      echo "Usage: ./install-dots.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  (no args)       Auto-detect installed AI tools and link integrations"
      echo "  --all           Force-install integrations for all supported AI environments"
      echo "  --antigravity   Configure Antigravity / Gemini Code Assist integration"
      echo "  --opencode      Configure OpenCode (/dots/*) slash-commands integration"
      echo "  --claude        Configure Claude Code global rules"
      echo "  --cursor        Configure Cursor rules"
      echo "  --hermes        Configure Hermes local dots skill"
      echo "  --force         Overwrite/backup conflicting files with symlinks"
      echo "  -h, --help      Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (use -h for help)"
      exit 1
      ;;
  esac
done

# ANSI color codes
if [ -t 1 ]; then
  BOLD="\033[1m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  BLUE="\033[34m"
  CYAN="\033[36m"
  RED="\033[31m"
  RESET="\033[0m"
else
  BOLD=""
  GREEN=""
  YELLOW=""
  BLUE=""
  CYAN=""
  RED=""
  RESET=""
fi

printf "%b=== dotS Multi-AI Installer ===%b\n" "$BOLD$CYAN" "$RESET"
printf "dotS Directory: %s\n\n" "$DOTS_DIR"

# Ensure core directories & permissions
mkdir -p "$DOTS_DIR/skills"
chmod +x "$DOTS_DIR/dots.py" "$DOTS_DIR/dots"

# Add to PATH if not already there
SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"
if ! grep -qF "$DOTS_DIR" "$SHELL_RC" 2>/dev/null && ! grep -qF "\$HOME/${DOTS_DIR#$HOME/}" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# dotS tool" >> "$SHELL_RC"
  echo "export PATH='$DOTS_DIR':\$PATH" >> "$SHELL_RC"
  printf "%b[PATH]%b Added %s to %s\n" "$GREEN" "$RESET" "$DOTS_DIR" "$SHELL_RC"
else
  printf "%b[PATH]%b CLI already configured in %s\n" "$BLUE" "$RESET" "$SHELL_RC"
fi

# Helper: safe symlink with detection, content comparison, and no silent failures
safe_link() {
  _src="$1"
  _dst="$2"
  _label="$3"

  if [ ! -e "$_src" ]; then
    printf "  %b[ERROR]%b %s: source does not exist: %s\n" "$RED" "$RESET" "$_label" "$_src"
    return 0
  fi

  _dst_dir="$(dirname "$_dst")"
  if [ -L "$_dst_dir" ]; then
    printf "  %b[ERROR]%b %s: destination parent is a symlink: %s\n" "$RED" "$RESET" "$_label" "$_dst_dir"
    return 0
  fi
  mkdir -p "$_dst_dir"

  if [ -L "$_dst" ]; then
    _curr="$(readlink "$_dst" || true)"
    if [ "$_curr" = "$_src" ]; then
      printf "  %b[UP-TO-DATE]%b %s: %s\n" "$GREEN" "$RESET" "$_label" "$_dst"
      return 0
    else
      rm -f "$_dst"
      ln -s "$_src" "$_dst"
      printf "  %b[UPDATED]%b %s: %s -> %s\n" "$YELLOW" "$RESET" "$_label" "$_dst" "$_src"
      return 0
    fi
  elif [ -e "$_dst" ]; then
    # If regular file, check if content is identical
    if cmp -s "$_src" "$_dst"; then
      rm -f "$_dst"
      ln -s "$_src" "$_dst"
      printf "  %b[LINKED]%b %s: converted identical file to symlink (%s)\n" "$GREEN" "$RESET" "$_label" "$_dst"
      return 0
    elif [ "$FORCE" = true ]; then
      _bak="${_dst}.bak.$(date +%s)"
      mv "$_dst" "$_bak"
      ln -s "$_src" "$_dst"
      printf "  %b[BACKUP & LINKED]%b %s: backed up to %s and symlinked -> %s\n" "$YELLOW" "$RESET" "$_label" "$_bak" "$_src"
      return 0
    else
      printf "  %b[WARNING]%b %s: %s exists as a regular file/dir.\n" "$YELLOW" "$RESET" "$_label" "$_dst"
      printf "            Use --force to backup and replace with symlink.\n"
      return 0
    fi
  else
    ln -s "$_src" "$_dst"
    printf "  %b[LINKED]%b %s: %s -> %s\n" "$GREEN" "$RESET" "$_label" "$_dst" "$_src"
    return 0
  fi
}

echo ""
printf "%bScanning for supported AI environments...%b\n" "$BOLD" "$RESET"

# ---------------------------------------------------------
# 1. OpenCode Integration
# ---------------------------------------------------------
OC_BASE="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
if [ "$MODE_ALL" = true ] || [ "$MODE_OPENCODE" = true ] || [ -d "$OC_BASE" ] || command -v opencode >/dev/null 2>&1; then
  printf "%b[DETECTED] OpenCode%b\n" "$BOLD" "$RESET"
  _oc_cmds="$DOTS_DIR/integrations/opencode/commands/dots"

  if [ -d "$_oc_cmds" ]; then
    safe_link "$_oc_cmds" "$OC_BASE/commands/dots" "OpenCode commands (/dots/*)"
  else
    printf "  %b[SKIP]%b OpenCode commands folder missing in repo.\n" "$RED" "$RESET"
  fi

  _oc_agents="$DOTS_DIR/integrations/opencode/AGENTS.md"
  if [ -f "$_oc_agents" ]; then
    if [ ! -f "$OC_BASE/AGENTS.md" ]; then
      safe_link "$_oc_agents" "$OC_BASE/AGENTS.md" "OpenCode V2 AGENTS.md"
    else
      printf "  %b[UP-TO-DATE]%b OpenCode AGENTS.md already exists (%s/AGENTS.md)\n" "$GREEN" "$RESET" "$OC_BASE"
    fi
  fi
else
  printf "%b[SKIPPED]%b  OpenCode (not detected. Use --opencode or --all to force)\n" "$CYAN" "$RESET"
fi

# ---------------------------------------------------------
# 2. Hermes Agent Integration
# ---------------------------------------------------------
HERMES_BASE="${HERMES_HOME:-$HOME/.hermes}"
if [ "$MODE_ALL" = true ] || [ "$MODE_HERMES" = true ] || [ -d "$HERMES_BASE" ] || command -v hermes >/dev/null 2>&1; then
  printf "%b[DETECTED] Hermes Agent%b\n" "$BOLD" "$RESET"
  _hermes_skill="$DOTS_DIR/integrations/hermes/skills/dots"
  _hermes_target="$HERMES_BASE/skills/autonomous-ai-agents/dots"
  if [ -d "$_hermes_skill" ]; then
    safe_link "$_hermes_skill/SKILL.md" "$_hermes_target/SKILL.md" "Hermes dots skill"
    safe_link "$_hermes_skill/references/hermes-enablement.md" "$_hermes_target/references/hermes-enablement.md" "Hermes enablement notes"
  else
    printf "  %b[SKIP]%b Hermes adapter folder missing in repo.\n" "$RED" "$RESET"
  fi
else
  printf "%b[SKIPPED]%b  Hermes (not detected. Use --hermes or --all to force)\n" "$CYAN" "$RESET"
fi

# ---------------------------------------------------------
# 3. Antigravity / Gemini Code Assist Integration
# ---------------------------------------------------------
GEMINI_BASE="$HOME/.gemini"
if [ "$MODE_ALL" = true ] || [ "$MODE_ANTIGRAVITY" = true ] || [ -d "$GEMINI_BASE" ] || command -v agy >/dev/null 2>&1; then
  printf "%b[DETECTED] Antigravity / Gemini%b\n" "$BOLD" "$RESET"
  mkdir -p "$GEMINI_BASE/config/skills" "$GEMINI_BASE/config/rules"
  
  if [ -d "$DOTS_DIR/integrations/antigravity/skills/dots" ]; then
    safe_link "$DOTS_DIR/integrations/antigravity/skills/dots" "$GEMINI_BASE/config/skills/dots" "Antigravity Skill"
  fi
  _ag_rule="$DOTS_DIR/integrations/antigravity/rules/dots.md"
  if [ -f "$_ag_rule" ]; then
    safe_link "$_ag_rule" "$GEMINI_BASE/config/rules/dots.md" "Antigravity Rule (rules/)"
    safe_link "$_ag_rule" "$GEMINI_BASE/config/GEMINI.md" "Antigravity Global Rule (GEMINI.md)"
  fi
else
  printf "%b[SKIPPED]%b  Antigravity / Gemini (not detected. Use --antigravity or --all to force)\n" "$CYAN" "$RESET"
fi

# ---------------------------------------------------------
# 4. Claude Code Integration
# ---------------------------------------------------------
CLAUDE_BASE="$HOME/.claude"
if [ "$MODE_ALL" = true ] || [ "$MODE_CLAUDE" = true ] || [ -d "$CLAUDE_BASE" ] || command -v claude >/dev/null 2>&1; then
  printf "%b[DETECTED] Claude Code%b\n" "$BOLD" "$RESET"
  mkdir -p "$CLAUDE_BASE"
  _claude_instructions="$DOTS_DIR/integrations/claude-code/CLAUDE.md"
  if [ -f "$_claude_instructions" ]; then
    safe_link "$_claude_instructions" "$CLAUDE_BASE/CLAUDE.md" "Claude Code global instructions"
  fi
else
  printf "%b[SKIPPED]%b  Claude Code (not detected. Use --claude or --all to force)\n" "$CYAN" "$RESET"
fi

# ---------------------------------------------------------
# 5. Cursor Integration
# ---------------------------------------------------------
CURSOR_BASE="$HOME/.cursor"
CURSOR_CFG="$HOME/.config/Cursor"
if [ "$MODE_ALL" = true ] || [ "$MODE_CURSOR" = true ] || [ -d "$CURSOR_BASE" ] || [ -d "$CURSOR_CFG" ] || command -v cursor >/dev/null 2>&1; then
  printf "%b[DETECTED] Cursor%b\n" "$BOLD" "$RESET"
  mkdir -p "$CURSOR_BASE/rules"
  _cursor_rule="$DOTS_DIR/integrations/cursor/dots.mdc"
  if [ -f "$_cursor_rule" ]; then
    safe_link "$_cursor_rule" "$CURSOR_BASE/rules/dots.mdc" "Cursor rule (dots.mdc)"
  fi
else
  printf "%b[SKIPPED]%b  Cursor (not detected. Use --cursor or --all to force)\n" "$CYAN" "$RESET"
fi

# ---------------------------------------------------------
# Test dots CLI
# ---------------------------------------------------------
echo ""
printf "Testing dots CLI binary...\n"
if "$DOTS_DIR/dots" help > /dev/null 2>&1; then
  printf "%b[OK]%b dots CLI is operational.\n" "$GREEN" "$RESET"
else
  printf "%b[FAIL]%b dots CLI execution failed. Please verify Python 3 installation.\n" "$RED" "$RESET" >&2
  exit 1
fi

echo ""
printf "%b%bInstallation complete!%b\n" "$BOLD" "$GREEN" "$RESET"
printf "Run: %bsource %s%b\n" "$BOLD" "$SHELL_RC" "$RESET"
printf "Try: %bdots find ssh%b or %bdots list%b\n" "$BOLD" "$RESET" "$BOLD" "$RESET"
