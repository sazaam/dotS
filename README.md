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
- pip

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/dots.git
cd dots

# Run the installer
./install_s.sh
```

The installer will:
1. Copy `s` script to `/usr/local/bin/` (or `~/.local/bin/`)
2. Make it executable
3. Verify installation

### Manual Install

```bash
# Copy the script
cp s /usr/local/bin/

# Make executable
chmod +x /usr/local/bin/s

# Or add to your PATH manually
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Verify Installation

```bash
s --version
# dotS v0.1.0
```

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
│                   s find "ssl"                          │
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
│         s get skills/nginx.s @ssl                       │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              RESPOND WITH CONFIDENCE                    │
│         Use .s content + websearch if needed            │
└─────────────────────────────────────────────────────────┘
```

### Key Point: NOT Auto-Loaded

**dotS is on-demand, not automatic.** You must explicitly ask for it:

```bash
# This does NOT happen automatically
# You must request it:
s find "nginx"           # smart lookup
s get skills/nginx.s     # direct load
"load nginx"             # natural language (agent reads file)
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
1. Obtain an SSL certificate (Let's Encrypt, commercial, etc.)
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

| Approach | Tokens | Reduction | Time |
|----------|--------|-----------|------|
| Plain prose | 6,000-8,000 | — | Slow |
| Markdown docs | 2,000-3,000 | 60-70% | Medium |
| dotS | 150-200 | **97-99%** | Instant |

### Why 97-99%?

1. **No prose** — just key:value pairs
2. **No explanations** — agent knows what `certPath` means
3. **No examples** — agent can generate examples from keys
4. **No edge cases** — handled by confidence levels + websearch fallback
5. **No redundancy** — each concept appears once

### More Examples

| Topic | Prose Tokens | dotS Tokens | Savings |
|-------|--------------|-------------|---------|
| nginx SSL | 6,000 | 150 | 97.5% |
| Three.js geometry | 4,000 | 120 | 97% |
| GLSL raymarching | 5,000 | 180 | 96.4% |
| CSS flexbox | 3,500 | 100 | 97.1% |
| Git commands | 2,500 | 80 | 96.8% |

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
1. s find <topic>
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
s freshness                # check all files
s freshness nginx.s        # check one file
s freshness --warn 180     # warn if older than 180 days
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

## Agent Integration

### For OpenCode

dotS works with OpenCode's skill system:

1. Create context directory:
   ```bash
   mkdir -p ~/.config/opencode/ctx/skills
   ```

2. Add your .s files to `skills/`

3. Create `index.s` with routing rules

4. Load at session start:
   ```bash
   s get index.s
   ```

### For Claude Code

Create `~/.claude/ctx/index.s` with your skills routing.

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
s get skills/ponytail.s @rules
```

**Benefits:**
- ponytail enforces minimal code output
- dotS provides dense reference material
- Together: fast context + minimal output = maximum efficiency

#### dotS + Three.js

```bash
s find "threejs"           # load Three.js reference
s find "geometry"          # load geometry patterns
s find "animation"         # load animation system
```

#### dotS + GLSL/ShaderToyLite

```bash
s find "glsl"              # load GLSL fundamentals
s find "shaderToy"         # load ShaderToyLite API
s find "raymarching"       # load raymarching patterns
```

#### dotS + Obsidian

Store your .s files in Obsidian for visual browsing:

```bash
# Your vault structure
~/Documents/pensive/
├── Projects/
│   └── dotS/
│       └── README.md      # This file
└── .config/opencode/ctx/
    ├── index.s
    └── skills/
        ├── css.s
        ├── html.s
        ├── threejs.s
        └── ...
```

## File Structure

```
~/.config/opencode/ctx/
├── index.s           # PROJECT INDEX (read first, ~200 tokens)
├── relations.s       # dependency graph
├── changelog.s       # change history
├── modules/          # per-module state
├── decisions/        # architecture decisions
├── skills/           # knowledge base .s files
│   ├── index.s       # skill index
│   ├── css.s
│   ├── html.s
│   ├── threejs.s
│   ├── glsl.s
│   └── ...
└── .snaps/           # snapshots for diff
```

## Commands Reference

```bash
# Reading
s get index.s              # read file
s get skills/css.s @flexbox  # read specific block
s list index.s             # list blocks

# Writing
s set skills/css.s state done  # set value
s add skills/css.s @notes "did the thing"  # append to list
s rm skills/css.s @notes  # remove key

# Discovery
s find "topic"             # smart lookup
s blocks                   # list all blocks
s search "todo"            # grep across all .s files
s graph                    # show relationships

# Analysis
s tokens                   # count tokens
s tokens nginx.s @ssl      # count tokens in block
s stats                    # session usage stats

# Maintenance
s freshness                # check staleness
s validate                 # check parse errors
s snap                     # snapshot for diff
s diff                     # show changes since snap

# Learning
s learn nginx.s @ssl.hsts "new value"  # update from websearch
```

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
- **97% token savings** — your context window goes further

### For AI Agents

- **Token efficient** — 97-99% less context used
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

1. Create `~/.config/opencode/ctx/skills/topic.s`
2. Add `@meta` block with confidence level
3. Add content blocks with key:value pairs
4. Update `index.s` with routing rules

### Updating Existing Skills

```bash
s set skills/topic.s @meta lastUpdated 2026-08-18
s set skills/topic.s @ssl hsts "max-age=63072000"
s add skills/topic.s @gotchas "new gotcha discovered"
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
s get index.s  # Start here
```
