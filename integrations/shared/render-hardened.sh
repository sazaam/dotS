#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BODY="$ROOT/integrations/shared/dots-hardened.body.md"

write_variant() {
  _out="$1"
  _header="$2"
  mkdir -p "$(dirname "$_out")"
  printf '%s\n\n' "$_header" > "$_out"
  cat "$BODY" >> "$_out"
  printf 'rendered %s\n' "${_out#$ROOT/}"
}

write_variant "$ROOT/integrations/opencode/AGENTS.hardened.md" "$(cat <<'EOF'
<!--
Opt-in hardened OpenCode instructions, generated from integrations/shared/dots-hardened.body.md.
dotS install injects the canonical AGENTS.md when the global file is absent; link this variant manually.
Regenerate with: sh integrations/shared/render-hardened.sh
-->
EOF
)"

write_variant "$ROOT/integrations/claude-code/CLAUDE.hardened.md" "$(cat <<'EOF'
<!--
Opt-in hardened Claude Code instructions, generated from integrations/shared/dots-hardened.body.md.
dotS install injects the canonical CLAUDE.md; link this variant manually.
Regenerate with: sh integrations/shared/render-hardened.sh
-->
EOF
)"

write_variant "$ROOT/integrations/generic/AGENTS.hardened.md" "$(cat <<'EOF'
<!--
Opt-in hardened generic instructions, generated from integrations/shared/dots-hardened.body.md.
Use as AGENTS.md in tools that accept markdown agent instructions.
Regenerate with: sh integrations/shared/render-hardened.sh
-->
EOF
)"

write_variant "$ROOT/integrations/antigravity/rules/dots.hardened.md" "$(cat <<'EOF'
<!--
Opt-in hardened Antigravity rule, generated from integrations/shared/dots-hardened.body.md.
dotS install injects the canonical dots.md into ~/.gemini/config/rules/dots.md and GEMINI.md; link this variant manually.
Regenerate with: sh integrations/shared/render-hardened.sh
-->
EOF
)"

write_variant "$ROOT/integrations/cursor/dots.hardened.mdc" "$(cat <<'EOF'
---
description: dotS hardened gate — conditional routing plus `skip dots` bypass
alwaysApply: true
---

<!--
Opt-in hardened Cursor rule, generated from integrations/shared/dots-hardened.body.md.
dotS install injects the canonical dots.mdc; link this variant manually.
Regenerate with: sh integrations/shared/render-hardened.sh
-->
EOF
)"

write_variant "$ROOT/integrations/hermes/skills/dots-hardened/SKILL.md" "$(cat <<'EOF'
---
name: dots-hardened
description: >-
  Hardened dotS routing gate with `skip dots` bypass. Use before web search or
  speculation on infrastructure, system configuration, and supported stacks.
---

<!--
Opt-in hardened Hermes skill, generated from integrations/shared/dots-hardened.body.md.
dotS install links only the canonical dots skill; link this variant manually.
Regenerate with: sh integrations/shared/render-hardened.sh
-->
EOF
)"
