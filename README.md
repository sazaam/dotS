# dotS

> Token-efficient state storage for AI-assisted development

```
The .s format is optimized for AI context windows — dense, grepable, surgically editable.
```

## What is dotS?

dotS is a **Python script** that stores knowledge in `.s` files. Instead of verbose prose documentation, dotS uses **key:value pairs** in structured blocks that are:

- **Dense** — 300 tokens vs 6000+ for equivalent prose
- **Grepable** — find any concept in milliseconds
- **Surgically editable** — change one key, not whole files
- **On-demand** — loads only when you ask, skippable when you don't need it
- **Fallback-ready** — websearch when .s files are stale or insufficient

## Installation

### Prerequisites

- Python 3.6+

### Quick Install

```bash
# Clone the repository
git clone https://github.com/sazaam/dots.git

# Use the installer (auto-detects location, adds to PATH)
cd ~/.dotS && ./install-dots.sh

source ~/.zshrc  # or ~/.bashrc
```

### Verify

```bash
dots help
# dots.py - compact state DSL for AI-assisted projects
```

### Portable

dotS is **location-agnostic**. Place it anywhere:
- `~/.config/opencode/dotS/` (opencode)
- `~/.local/share/dotS/` (generic)
- `/opt/dotS/` (system-wide)
- `~/projects/dotS/` (development)

The installer auto-detects its location and configures PATH accordingly.

## How It Works

### The .s Format

```bash
@blockName |
  key:value
  key:[array, of, values]
  key:{nested: object}
  flag=truthy
|

# Comments start with #
```

### Key Point: NOT Auto-Loaded

**dotS is on-demand, not automatic.** You must explicitly ask for it:

```bash
# This does NOT happen automatically
# You must request it:
dots find "nginx"           # smart lookup
# or
dots get skills/nginx.s     # direct load
# or 
"load nginx through dotS"             # natural language (agent reads file)
```

**Why?**
- Zero overhead when you don't need it
- No token waste on irrelevant context
- You control what loads, when
- Skippable for simple tasks

## Token Savings: The Real Numbers

### The Problem: Prose Documentation

```bash
# Traditional AI context loading: nginx SSL configuration
## SSL Configuration in Nginx

To configure SSL in Nginx, you need to:
1. Obtain an SSL certificate (Let\'s Encrypt, commercial, etc.)
2. Configure the server block
3. Set up HTTP to HTTPS redirect
4. Configure SSL protocols and ciphers
5. Enable OCSP stapling
6. Set up HSTS headers
...

[500+ words of explanation, examples, edge cases]
```

**= ~6,000-8,000 tokens loaded**

### The dotS Solution

```bash
# dotS nginx SSL configuration
@ssl |
  certPath:/etc/letsencrypt/live/domain.com/fullchain.pem
  keyPath:/etc/letsencrypt/live/domain.com/privkey.pem
  protocol:TLSv1.2 TLSv1.3
  ciphers:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
  hsts:max-age=63072000
  stapling:ssl_stapling on
  redirect:return 301 https://$server_name$request_uri
|
```

**= ~150-200 tokens loaded**

### Real-World Comparison: nginx SSL

| Approach      | Tokens      | Reduction  | Time    |
| ------------- | ----------- | ---------- | ------- |
| Plain prose   | 6,000-8,000 | —          | Slow    |
| Markdown docs | 2,000-3,000 | 60-70%     | Medium  |
| dotS          | 150-200     | **97-99%** | Instant |

### Why so high in this case?

1. **No prose** — just key:value pairs
2. **No explanations** — agent knows what `certPath` means
3. **No examples** — agent can generate examples from keys
4. **No edge cases** — handled by confidence levels + websearch fallback
5. **No redundancy** — each concept appears once

### More Examples

| Topic             | Prose Tokens | dotS Tokens | Savings |
| ----------------- | ------------ | ----------- | ------- |
| nginx SSL         | 6,000        | 150         | 97.5%   |
| Three.js geometry | 4,000        | 120         | 97%     |
| GLSL raymarching  | 5,000        | 180         | 96.4%   |
| CSS flexbox       | 3,500        | 100         | 97.1%   |
| Git commands      | 2,500        | 80          | 96.8%   |

**Average: 97% token reduction**

## Fallback Chain: When .s Isn't Enough

### Confidence Levels

Every .s file has a `@meta` block:

```bash
@meta |
  topic:nginx
  confidence:high        # high | medium | low
  lastUpdated:2026-08-17
  knownGaps:"HTTP/3 config, nginx unit"
  deprecated:false
|
```

### The Fallback Logic

```
1. dots find <topic>
   │
   ├─ Found + confidence:high → use .s directly (300 tokens)
   │
   ├─ Found + confidence:medium → .s + websearch supplement
   │   └─ Load .s for structure, websearch for gaps
   │
   ├─ Found + confidence:low → websearch primary, .s as reference
   │   └─ .s is outdated, use websearch as source of truth
   │
   └─ Not found → full websearch
       └─ No .s file exists, search the web
```

### Staleness Detection

```bash
dots freshness                # check all files
dots freshness nginx.s        # check one file
dots freshness --warn 180     # warn if older than 180 days
```

Output:
```
  freshness report:
    nginx.s   lastUpdated:2026-08-17  (0 days ago)  ✓ fresh
    git.s     lastUpdated:2026-08-17  (0 days ago)  ✓ fresh
    python.s  lastUpdated:2025-01-15  (214 days ago)  ⚠ stale
```

### Why This Matters

- **Fresh content** → use .s (fast, cheap)
- **Stale content** → websearch (accurate, current)
- **Missing content** → websearch (discover new topics)
- **You decide** → confidence levels give you control

### Execution Model

```
┌─────────────────────────────────────────────────────────┐
│                    USER REQUEST                         │
│              "load nginx SSL config"                    │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  SMART LOOKUP                           │
│                   dots find "ssl"                          │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                 CHECK INDEX.S                           │
│              @quickRef → @byTask → @index               │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                CHECK CONFIDENCE                         │
│         @meta block: high | medium | low                │
└─────────────────────────────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌─────────┐  ┌─────────┐  ┌─────────┐
        │  HIGH   │  │ MEDIUM  │  │   LOW   │
        │  use .s │  │ .s +    │  │websearch│
        │ directly│  │websearch│  │ primary │
        └─────────┘  └─────────┘  └─────────┘
              │            │            │
              ▼            ▼            ▼
┌─────────────────────────────────────────────────────────┐
│              LOAD CONTEXT (~300 tokens)                 │
│         dots get skills/nginx.s @ssl                       │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              RESPOND WITH CONFIDENCE                    │
│         Use .s content + websearch if needed            │
└─────────────────────────────────────────────────────────┘
```


## Agent Integration

### For Any Agent

dotS is **agent-agnostic**. Any agent that can:
- Read files
- Execute commands
- Parse key:value pairs

...can use dotS. The `s` script is just a convenience wrapper — the format is the real power.

### Integration with Other Tools

#### dotS + ponytail

Use [ponytail](https://github.com/DietrichGebert/ponytail) for YAGNI enforcement:

```bash
# Load ponytail rules
dots get skills/ponytail.s @rules
```

**Benefits:**
- ponytail enforces minimal code output
- dotS provides dense reference material
- Together: fast context + minimal output = maximum efficiency

#### dotS + Three.js

```bash
dots find "threejs"           # load Three.js reference
dots find "geometry"          # load geometry patterns
dots find "animation"         # load animation system
```

#### dotS + GLSL/ShaderToyLite

```bash
dots find "glsl"              # load GLSL fundamentals
dots find "shaderToy"         # load ShaderToyLite API
dots find "raymarching"       # load raymarching patterns
```

#### dotS + Obsidian

Store your .s files in Obsidian for visual browsing:

```bash
# Your vault structure
~/Documents/pensive/
├── Projects/
│   └── dotS/
│       └── README.md      # This file
└── .config/opencode/dotS/
    ├── index.s
    └── skills/
        ├── css.s
        ├── html.s
        ├── threejs.s
        └── ...
```

## dotS + opencode: The Optimal Setup

This is the reference configuration for running dotS as the context layer
of [opencode](https://opencode.ai). It routes the *map* into the system
prompt once and pulls skill *bodies* on demand — the fast path is cheap,
and nothing heavy (50k tokens worth of skills) ever loads unless you ask.

### Recommended layout

```
~/.config/opencode/
├── opencode.json          # wires index.s into the system prompt
├── dotS/                  # the dotS install (knowledge base)
│   ├── dots               # CLI wrapper (~/.local/bin/dots)
│   ├── dots.py
│   ├── index.s            # routing map — the ONLY thing loaded at start
│   └── skills/*.s         # knowledge bodies — loaded on demand
└── instructions/          # rule .s files (core.s, security.s, ...)
```

### opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "~/.config/opencode/instructions/INSTRUCTIONS.md",
    "~/.config/opencode/dotS/index.s"
  ]
}
```

`instructions` injects the file contents into the model's system prompt on
every start (TUI, `opencode run`, subagents). Loading `index.s` there means
the routing map is always resident with no command, no latency, and none of
the "did the agent remember to load it?" ambiguity.

### Pointing `dots` at a sibling instructions dir

If your rule files live *outside* the dotS install (e.g. under
`~/.config/opencode/instructions/`), the CLI needs to know where:

```bash
# In the dots wrapper, or your shell rc:
export S_INSTRUCTIONS_DIR="~/.config/opencode/instructions"
```

`dots.py` resolves every `<file>.s` against `S_DIR` (the install)
and `S_INSTRUCTIONS_DIR`, so both `dots get core.s @always` (instructions) and
`dots get skills/nginx.s @ssl` (knowledge base) work from any working
directory. Without this, `dots get <instructions-file>.s` fails with
"File not found".

### At session start (and why)

| Command | Tokens | Verdict |
|---|---|---|
| `dots get index.s "*"` | **~50,000** (loads every skill body) | Never do this |
| `index.s` injected via `instructions` | ~2,400 always resident | **Recommended** |
| `dots get core.s @always` | ~100, occasionally | Run when coding starts |

The 50k "load-all" startup both defeats dotS's token advantage and burns
context before a single task arrives. Injecting only `index.s` keeps the
routing map (which skill covers what, how to fetch it) always available at
~2,400 tokens, then lets the agent pull just the block it needs:

```bash
dots get skills/nginx.s @ssl          # 150 tokens, on demand
dots find "ssl"                        # or route by topic
dots run skills/git.s @run.quickCommit # run a playbook
dots tokens                            # audit your own footprint
```

### The `.s` syntax inside the injected prompt is fine

`index.s` is dense `key:value`/`|`-delimited DSL. Models read it as a routing
table without a prologue — no need to render it to prose. If the injected
file ever gets large, trim to the routing blocks only:

```bash
dots get index.s @index @byTask   # ~1,100 tokens: map without shortcut tables
```

### Anti-patterns

- ❌ `dots get index.s "*"` in your shell profile / INSTRUCTIONS.md
- ❌ Duplicating `@quickRef` contents into AGENTS.md or prose docs
- ❌ Storing API keys in `index.s` or any `.s` file (commit to git is too easy)

Caveat: legacy references in this README may still say `s` where the shipped
CLI is `dots`. If your install predates the rename, `s` was simply renamed
to `dots` — same behavior.

## File Structure

```
dotS/
├── dots.py           # main CLI script
├── dots              # bash wrapper (installed to PATH)
├── install-dots.sh      # installer
├── index.s           # project index (read first, ~200 tokens)
├── relations.s       # dependency graph
├── changelog.s       # change history
├── skills/           # knowledge base .s files
│   ├── css.s
│   ├── html.s
│   ├── threejs.s
│   ├── glsl.s
│   └── ...
├── .mutations/       # skill variants for specific contexts
├── .snaps/           # snapshots for diff
├── .state/           # tracking
└── .sessions/        # session logs
```

## Commands Reference

```bash
# Reading
dots get index.s              # read file
dots get skills/css.s @flexbox  # read specific block
dots list index.s             # list blocks

# Writing
dots set skills/css.s state done  # set value
dots add skills/css.s @notes "did the thing"  # append to list
s rm skills/css.s @notes  # remove key

# Discovery
dots find "topic"             # smart lookup
dots blocks                   # list all blocks
dots search "todo"            # grep across all .s files
dots graph                    # show relationships

# Analysis
dots tokens                   # count tokens
dots tokens nginx.s @ssl      # count tokens in block
dots stats                    # session usage stats

# Maintenance
dots freshness                # check staleness
dots validate                 # check parse errors
dots snap                     # snapshot for diff
dots diff                     # show changes since snap

# Learning
dots learn nginx.s @ssl.hsts "new value"  # update from websearch
```

## Mutations

Mutations create skill variants for specific contexts. A mutation maps a base skill to a context, so when you ask about that topic, the right skill is loaded.

```bash
# Create a mutation
dots mutate create blender-python "game development"

# List all mutations
dots mutate list

# Show mutation details
dots mutate show blender-game
```

A mutation file (`.mutations/<name>.mut`) is two lines:
```
blender-python.s
game development
```

This means: "when the user asks about game development, load `blender-python.s`."

## Pollination

Pollination compares skills to find shared patterns. It's read-only — no files are created.

```bash
# List all skills with their block names
dots pollinate list

# Compare two specific skills
dots pollinate nginx docker

# Show all cross-pollination opportunities across every skill pair
dots pollinate --all
```

Example output of `dots pollinate nginx sh`:

```
  cross-pollination: nginx.s <-> sh.s
    common blocks: security, logging, commonPatterns
    only in nginx.s: ...
    only in sh.s: ...
```

Boilerplate blocks (`@meta`, `@gotchas`, `@run`, `@basics`, etc.) are skipped — only semantically meaningful overlaps are shown.

## Key Principles

1. **Read index.s first** — always orient before diving in
2. **Try .s first** — fast path, 300 tokens vs 6000+
3. **Detect insufficiency** — check confidence levels
4. **Fall back gracefully** — websearch when .s isn't enough
5. **Update after learning** — keep .s files fresh
6. **Surgical edits** — change one key, not whole files
7. **Run playbooks** — use @run blocks for repeatable workflows
8. **Not auto-loaded** — on-demand, skippable, you control it

## Why dotS?

### For Developers

- **Instant context** — no waiting for large file loads
- **Precise edits** — change one key, not entire files
- **Portable** — works with any AI agent
- **Versionable** — git-friendly format
- **Token savings** — typically 30-90%, best cases (single-block loads) reach ~97%

### For AI Agents

- **Token efficient** — usually far less context than prose docs
- **Grepable** — find concepts in milliseconds
- **Structured** — parseable blocks, not prose
- **On-demand** — load only what's needed
- **Fallback-aware** — websearch when content is stale

### For Teams

- **Shared knowledge** — same .s files for everyone
- **Confidence tracking** — know what's reliable
- **Freshness tracking** — know what's current
- **Modular** — each topic in its own file
- **Zero overhead** — nothing loads unless you ask

## Example: nginx SSL

### Before (Prose)

```markdown
## SSL Configuration

To set up SSL in Nginx, you'll need to:

1. **Obtain a certificate**: Use Let's Encrypt with certbot, or purchase
   a commercial certificate. For Let's Encrypt:
   ```bash
   certbot certonly --webroot -w /var/www/html -d example.com
   ```

2. **Configure the server block**: Add SSL settings to your Nginx config:
   ```nginx
   server {
       listen 443 ssl http2;
       server_name example.com;
       
       ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
       
       # SSL protocols
       ssl_protocols TLSv1.2 TLSv1.3;
       
       # SSL ciphers
       ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
       
       # HSTS
       add_header Strict-Transport-Security "max-age=63072000" always;
       
       # OCSP stapling
       ssl_stapling on;
       ssl_stapling_verify on;
   }
   ```

3. **Redirect HTTP to HTTPS**:
   ```nginx
   server {
       listen 80;
       server_name example.com;
       return 301 https://$server_name$request_uri;
   }
   ```

[... more explanation, edge cases, troubleshooting ...]
```

**= ~6,000 tokens**

### After (dotS)

```bash
@ssl |
  certPath:/etc/letsencrypt/live/domain.com/fullchain.pem
  keyPath:/etc/letsencrypt/live/domain.com/privkey.pem
  protocol:TLSv1.2 TLSv1.3
  ciphers:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
  hsts:max-age=63072000
  stapling:ssl_stapling on
  redirect:return 301 https://$server_name$request_uri
|
```

**= ~150 tokens**

**Savings: 97.5%**

## Contributing

### Adding a New Skill

1. Create `dotS/skills/topic.s`
2. Add `@meta` block with confidence level
3. Add content blocks with key:value pairs
4. Update `index.s` with routing rules

### Updating Existing Skills

```bash
dots set skills/topic.s @meta lastUpdated 2026-08-18
dots set skills/topic.s @ssl hsts "max-age=63072000"
dots add skills/topic.s @gotchas "new gotcha discovered"
```

### When to Update

- After websearch reveals new information
- When you discover a gotcha
- When a feature becomes deprecated
- When confidence level changes

## License

GNU 3 — use it, fork it, improve it.

## Credits

Sazaam

---

**Remember:** The best context is the one you don't have to load.

```bash
dots get index.s  # Start here
```
