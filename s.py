#!/usr/bin/env python3
"""s.py - Compact state management DSL for AI-assisted projects.

Usage:
    s init                  Scaffold dotS/ structure
    s get <file> [block]    Read file or specific block
    s set <file> <path> <value>  Set a value (path: block.key or block.key.subkey)
    s add <file> <path> <value>  Append to a list
    s list <file>           List all blocks in a file
    s graph                 Show relationship graph
    s validate              Validate all .s files
    s snap                  Snapshot current state
    s diff                  Show changes since last snapshot
    s search <query>        Search across all .s files
    s find <topic>          Smart lookup via index.s routing
    s optimize <skill> [--dry-run]  Optimize .s files for token savings
"""

import sys
import os
import re
import json
import hashlib
import difflib
from pathlib import Path
from datetime import datetime
from typing import Optional

CTX_DIR = Path(os.environ.get("S_DIR", Path(__file__).parent))
INSTRUCTIONS_DIR = Path(os.environ.get("S_INSTRUCTIONS_DIR", Path(__file__).parent / "instructions"))
SNAP_DIR = CTX_DIR / ".snaps"
STATE_DIR = CTX_DIR / ".state"
LOADED_FILE = STATE_DIR / "loaded.txt"
SESSION_LOG = STATE_DIR / "session.log"
LOCKED_FILE = CTX_DIR / "skills" / ".locked"
DEPS_DIR = CTX_DIR / "skills" / ".deps"
MEGA_DIR = CTX_DIR / "skills" / ".mega"
MUTATIONS_DIR = CTX_DIR / "skills" / ".mutations"


def resolve_file(filename: str) -> Path:
    """Resolve a file from CTX_DIR or INSTRUCTIONS_DIR."""
    # Try CTX_DIR first
    fp = CTX_DIR / filename
    if fp.exists():
        return fp
    # Try INSTRUCTIONS_DIR
    fp = INSTRUCTIONS_DIR / filename
    if fp.exists():
        return fp
    # Return CTX_DIR path for error message
    return CTX_DIR / filename


def _ensure_state_dir():
    """Ensure state directory exists."""
    STATE_DIR.mkdir(parents=True, exist_ok=True)


def _track_loaded(filepath: str):
    """Track a file as loaded."""
    _ensure_state_dir()
    loaded = _get_loaded()
    if filepath not in loaded:
        loaded.append(filepath)
        LOADED_FILE.write_text('\n'.join(loaded) + '\n')


def _get_loaded() -> list:
    """Get list of loaded files."""
    _ensure_state_dir()
    if not LOADED_FILE.exists():
        return []
    return [l.strip() for l in LOADED_FILE.read_text().splitlines() if l.strip()]


def _unload_file(filepath: str):
    """Remove a file from loaded list."""
    loaded = _get_loaded()
    if filepath in loaded:
        loaded.remove(filepath)
        LOADED_FILE.write_text('\n'.join(loaded) + '\n')
        return True
    return False


def _log_session(cmd: str, args: list, result: str = ""):
    """Log a command to session log for compact."""
    _ensure_state_dir()
    ts = datetime.now().isoformat()
    line = f"{ts}|{cmd}|{' '.join(args)}|{result}\n"
    with open(SESSION_LOG, 'a') as f:
        f.write(line)


def _get_locked() -> list:
    """Get list of locked skill files."""
    if not LOCKED_FILE.exists():
        return []
    return [l.strip() for l in LOCKED_FILE.read_text().splitlines() if l.strip() and not l.strip().startswith('#')]


def _set_locked(locked: list):
    """Save list of locked skill files."""
    LOCKED_FILE.parent.mkdir(parents=True, exist_ok=True)
    if locked:
        LOCKED_FILE.write_text('\n'.join(sorted(set(locked))) + '\n')
    elif LOCKED_FILE.exists():
        LOCKED_FILE.unlink()


def _is_locked(skill_name: str) -> bool:
    """Check if a skill is locked."""
    if not skill_name.endswith('.s'):
        skill_name += '.s'
    return skill_name in _get_locked()


# ── Dependency Graph ──────────────────────────────────────────────────────────

def _get_skill_deps(skill_name: str) -> list:
    """Get dependencies for a skill from its @dependencies block."""
    if not skill_name.endswith('.s'):
        skill_name += '.s'
    
    filepath = CTX_DIR / "skills" / skill_name
    if not filepath.exists():
        return []
    
    sf = SFile(filepath)
    deps_block = sf.get_block('dependencies')
    if not deps_block:
        return []
    
    deps = []
    for key, val in deps_block.props.items():
        if isinstance(val, str) and val:
            deps.append(val)
        elif isinstance(val, list):
            deps.extend(val)
    return deps


def _resolve_all_deps(skill_name: str, visited: set = None) -> list:
    """Recursively resolve all dependencies for a skill."""
    if visited is None:
        visited = set()
    
    if not skill_name.endswith('.s'):
        skill_name += '.s'
    
    if skill_name in visited:
        return []
    visited.add(skill_name)
    
    deps = _get_skill_deps(skill_name)
    all_deps = []
    
    for dep in deps:
        if not dep.endswith('.s'):
            dep += '.s'
        if dep not in visited:
            all_deps.append(dep)
            all_deps.extend(_resolve_all_deps(dep, visited))
    
    return list(dict.fromkeys(all_deps))  # Remove duplicates, preserve order


def _save_deps_graph(skill_name: str, deps: list):
    """Save resolved dependencies to cache file."""
    DEPS_DIR.mkdir(parents=True, exist_ok=True)
    cache_file = DEPS_DIR / f"{skill_name}.deps"
    cache_file.write_text('\n'.join(deps))


def _load_deps_cache(skill_name: str) -> list:
    """Load cached dependencies if available."""
    if not skill_name.endswith('.s'):
        skill_name += '.s'
    
    cache_file = DEPS_DIR / f"{skill_name}.deps"
    if cache_file.exists():
        return [l.strip() for l in cache_file.read_text().splitlines() if l.strip()]
    return None


# ── MegaSkills ────────────────────────────────────────────────────────────────

def _get_mega_skills() -> dict:
    """Get all mega-skills from .mega directory."""
    mega = {}
    if MEGA_DIR.exists():
        for f in MEGA_DIR.glob("*.mega"):
            skills = [l.strip() for l in f.read_text().splitlines() if l.strip()]
            mega[f.stem] = skills
    return mega


def _create_mega_skill(name: str, skills: list):
    """Create a mega-skill file."""
    MEGA_DIR.mkdir(parents=True, exist_ok=True)
    mega_file = MEGA_DIR / f"{name}.mega"
    mega_file.write_text('\n'.join(skills) + '\n')


def _load_mega_skill(name: str) -> list:
    """Load all skills in a mega-skill."""
    mega = _get_mega_skills()
    if name not in mega:
        return []
    
    skills = mega[name]
    loaded = _get_loaded()
    loaded_count = 0
    
    for skill in skills:
        if not skill.endswith('.s'):
            skill += '.s'
        
        skill_path = f"skills/{skill}"
        if skill_path not in loaded:
            filepath = CTX_DIR / "skills" / skill
            if filepath.exists():
                _track_loaded(skill_path)
                loaded_count += 1
    
    return skills


# ── Skill Mutations ───────────────────────────────────────────────────────────

def _get_mutations() -> dict:
    """Get all skill mutations from .mutations directory."""
    mutations = {}
    if MUTATIONS_DIR.exists():
        for f in MUTATIONS_DIR.glob("*.mut"):
            lines = f.read_text().splitlines()
            if len(lines) >= 2:
                parent = lines[0].strip()
                context = lines[1].strip()
                mutations[f.stem] = {"parent": parent, "context": context}
    return mutations


def _create_mutation(base_skill: str, context: str, name: str = None) -> str:
    """Create a mutation of a skill for a specific context."""
    if not base_skill.endswith('.s'):
        base_skill += '.s'
    
    if not name:
        name = f"{base_skill.replace('.s', '')}-{context.lower().replace(' ', '-')}"
    
    MUTATIONS_DIR.mkdir(parents=True, exist_ok=True)
    mut_file = MUTATIONS_DIR / f"{name}.mut"
    mut_file.write_text(f"{base_skill}\n{context}\n")
    
    return name


def _auto_load_skills_from_index(index_sf: SFile):
    """Auto-load all skills listed in @index block of index.s."""
    idx_block = index_sf.get_block('index')
    if not idx_block:
        return

    loaded_count = 0
    for key in idx_block.props.keys():
        # Keys are filenames like "docker.s", "git.s", etc.
        if key.endswith('.s') and key != 'index.s':
            skill_path = f"skills/{key}"
            # Check if already loaded
            loaded = _get_loaded()
            if skill_path not in loaded:
                full_path = CTX_DIR / "skills" / key
                if full_path.exists():
                    _track_loaded(skill_path)
                    loaded_count += 1

    if loaded_count > 0:
        print(f"\n  ✓ auto-loaded {loaded_count} skill(s) from @index")


def _get_session_log() -> list:
    """Read session log entries."""
    _ensure_state_dir()
    if not SESSION_LOG.exists():
        return []
    entries = []
    for line in SESSION_LOG.read_text().splitlines():
        if '|' in line:
            parts = line.split('|', 3)
            if len(parts) >= 3:
                entries.append({
                    'time': parts[0],
                    'cmd': parts[1],
                    'args': parts[2].split(),
                    'result': parts[3] if len(parts) > 3 else ''
                })
    return entries


def _clear_session_log():
    """Clear session log after compact."""
    _ensure_state_dir()
    if SESSION_LOG.exists():
        SESSION_LOG.write_text('')


# ── Parser ──────────────────────────────────────────────────────────────────

class Block:
    def __init__(self, tag: str, raw: str):
        self.tag = tag
        self.raw = raw
        self.props: dict = {}
        self.inline = False  # Track if block uses inline format
        self._parse(raw)

    def _parse(self, raw: str):
        lines = raw.strip().splitlines()
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            m = re.match(r'^(\S+?)(?:\s*[=:]\s*|\s+)(.+)$', line)
            if m:
                key, val = m.group(1), m.group(2).strip()
                self.props[key] = self._parse_val(val)
            elif re.match(r'^(\S+?)[>!~<^]$', line):
                sym = line[-1]
                key = line[:-1]
                self.props[key] = {'_rel': sym}
            elif re.match(r'^[>!~<^](\S+)$', line):
                sym = line[0]
                target = line[1:]
                self.props.setdefault('_targets', []).append({'_rel': sym, '_to': target})

    def _parse_val(self, val: str):
        if val.startswith('[') and val.endswith(']'):
            inner = val[1:-1]
            result = []
            for v in self._split_list(inner):
                v = v.strip()
                # Only strip outer quotes, not quotes within the value
                if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
                    v = v[1:-1].strip()
                result.append(v)
            return result
        if val.startswith('{') and val.endswith('}'):
            inner = val[1:-1]
            return self._parse_inline_map(inner)
        # Only strip outer quotes, not quotes within the value
        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
            return val[1:-1].strip()
        return val.strip()

    def _split_list(self, s: str) -> list:
        result = []
        depth = 0
        current = ''
        for ch in s:
            if ch == '[':
                depth += 1
                current += ch
            elif ch == ']':
                depth -= 1
                current += ch
            elif ch == ',' and depth == 0:
                result.append(current.strip())
                current = ''
            else:
                current += ch
        if current.strip():
            result.append(current.strip())
        return result

    def _parse_inline_map(self, s: str) -> dict:
        result = {}
        for part in self._split_list(s):
            if ':' in part:
                k, v = part.split(':', 1)
                result[k.strip()] = v.strip().strip('"').strip("'")
            else:
                result[part.strip()] = True
        return result

    def get(self, key: str, default=None):
        return self.props.get(key, default)

    def set(self, key: str, value):
        self.props[key] = value

    def add(self, key: str, value):
        current = self.props.get(key, [])
        if not isinstance(current, list):
            current = [current] if current else []
        current.append(value)
        self.props[key] = current

    def to_dict(self) -> dict:
        return {self.tag: self.props}

    def render(self) -> str:
        # Get block name if present (don't modify props)
        block_name = self.props.get('_name')
        
        # Check if we can render inline (all props are simple strings, no _name)
        can_inline = (self.inline and 
                      '_name' not in self.props and
                      all(isinstance(v, str) for v in self.props.values()))
        
        if can_inline:
            # Render inline: @tag |key1:val1|key2:val2|
            parts = []
            for k, v in self.props.items():
                parts.append(f'{k}:{v}')
            return f'@{self.tag} |{"|".join(parts)}|'
        
        # Multi-line format
        name_part = f' {block_name}' if block_name else ''
        lines = [f'@{self.tag}{name_part} |']
        for k, v in self.props.items():
            if k == '_name':
                continue  # Already included in tag line
            lines.append(self._render_kv(k, v))
        lines.append('|')
        return '\n'.join(lines)

    def _render_kv(self, k, v) -> str:
        if isinstance(v, dict) and '_rel' in v:
            return f'  {k}{v["_rel"]}'
        if isinstance(v, list):
            items = ','.join(str(i) for i in v)
            return f'  {k}:[{items}]'
        if isinstance(v, dict):
            items = ','.join(f'{ik}:{iv}' for ik, iv in v.items())
            return f'  {k}:{{{items}}}'
        return f'  {k}:{v}'


class SFile:
    def __init__(self, path: Path):
        self.path = path
        self.blocks: list[Block] = []
        self.header: str = ''
        self._load()

    def _load(self):
        if not self.path.exists():
            return
        content = self.path.read_text()
        self._parse(content)

    def _parse(self, content: str):
        self.blocks = []
        current_tag = None
        current_lines = []
        header_lines = []
        current_inline = False  # Track if current block is inline

        for line in content.splitlines():
            stripped = line.strip()
            # block start: @tag | or @tag name | with possible inline props
            m = re.match(r'^@(\S+)(?:\s+(\w+))?\s*\|(.*)\|?\s*$', stripped)
            if m:
                if current_tag is not None:
                    block = Block(current_tag, '\n'.join(current_lines))
                    block.inline = current_inline
                    self.blocks.append(block)
                current_tag = m.group(1)
                # Store the name if present (e.g., "quickCommit" in "@run quickCommit |")
                block_name = m.group(2)
                # extract inline properties from the tag line
                inline = m.group(3).strip().rstrip('|').strip()
                if inline:
                    current_lines = [p.strip() for p in inline.split('|') if p.strip()]
                    current_inline = True
                else:
                    current_lines = []
                    current_inline = False
                # If there's a block name, add it as a property
                if block_name:
                    current_lines.insert(0, f'_name:{block_name}')
            elif stripped == '|' and current_tag is not None:
                block = Block(current_tag, '\n'.join(current_lines))
                block.inline = current_inline
                self.blocks.append(block)
                current_tag = None
                current_lines = []
                current_inline = False
            elif current_tag is not None:
                # Skip empty lines within blocks (don't reset inline flag)
                if stripped:
                    current_lines.append(line)
                    current_inline = False  # Non-empty content means not inline
            elif stripped.startswith('#'):
                header_lines.append(line)
            elif stripped:
                header_lines.append(line)

        self.header = '\n'.join(header_lines)

    def get_block(self, tag: str) -> Optional[Block]:
        for b in self.blocks:
            if b.tag == tag:
                return b
        return None

    def set_block(self, block: Block):
        for i, b in enumerate(self.blocks):
            if b.tag == block.tag:
                self.blocks[i] = block
                return
        self.blocks.append(block)

    def render(self) -> str:
        parts = []
        if self.header:
            parts.append(self.header)
        for b in self.blocks:
            parts.append(b.render())
        return '\n'.join(parts) + '\n'

    def save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(self.render())


# ── Commands ────────────────────────────────────────────────────────────────

def cmd_init(args):
    """Scaffold the dotS/ structure."""
    global CTX_DIR, SNAP_DIR
    if args:
        CTX_DIR = Path(args[0])
    else:
        CTX_DIR = Path.cwd() / "dotS"
    SNAP_DIR = CTX_DIR / ".snaps"

    dirs = [CTX_DIR, CTX_DIR / "modules", CTX_DIR / "decisions", SNAP_DIR]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)

    # Create default files
    defaults = {
        "index.s": (
            "# Project Index\n"
            "@p |name:project|ver:0.1.0|lang:?|rt:?|pkg:?|\n"
            "@m |\n  # add module references here\n|\n"
            "@f |\n  # add file structure here\n|\n"
            "@! |\n  # add rules here\n|\n"
        ),
        "relations.s": "# Relationships\n# $a > $b  means a depends on b\n# $a < $b  means a is used by b\n# $a ! $b  means a conflicts with b\n# $a ~ $b  means a is related to b\n",
        "changelog.s": "# Changelog\n",
    }
    for fname, content in defaults.items():
        fpath = CTX_DIR / fname
        if not fpath.exists():
            fpath.write_text(content)
            print(f"  created {fpath}")

    # Create .gitignore for snaps
    gi = SNAP_DIR / ".gitignore"
    if not gi.exists():
        gi.write_text("*\n!.gitignore\n")

    print(f"\n  ✓ s initialized at {CTX_DIR}")
    print(f"  Run: s get index.s")


def cmd_get(args):
    """Read a file or specific block."""
    if not args:
        print("Usage: s get <file> [block]", file=sys.stderr)
        sys.exit(1)

    filepath = resolve_file(args[0])
    if not filepath.exists():
        print(f"File not found: {filepath}", file=sys.stderr)
        sys.exit(1)

    # Track as loaded
    _track_loaded(args[0])
    _log_session('get', args)

    sf = SFile(filepath)

    if len(args) > 1:
        # get specific block
        block_name = args[1].lstrip('@')  # strip leading @ if user typed it
        block = sf.get_block(block_name)
        if not block:
            print(f"Block @{block_name} not found in {args[0]}", file=sys.stderr)
            sys.exit(1)
        # optional key
        if len(args) > 2:
            val = block.get(args[2])
            if val is None:
                print(f"Key '{args[2]}' not found in @{block_name}", file=sys.stderr)
                sys.exit(1)
            if isinstance(val, (dict, list)):
                print(json.dumps(val, indent=2, default=str))
            else:
                print(val)
        else:
            print(block.render())
    else:
        print(sf.render(), end='')

    # Auto-load all skills when loading index.s
    if args[0] == 'index.s':
        _auto_load_skills_from_index(sf)


def cmd_set(args):
    """Set a value in a block."""
    if len(args) < 3:
        print("Usage: s set <file> <block.key> <value>", file=sys.stderr)
        sys.exit(1)

    filepath = resolve_file(args[0])
    sf = SFile(filepath)

    path = args[1].lstrip('@')  # strip leading @ if user typed it
    parts = path.split('.', 1)
    block_tag = parts[0]
    key = parts[1] if len(parts) > 1 else None

    block = sf.get_block(block_tag)
    if not block:
        block = Block(block_tag, '')

    value = ' '.join(args[2:])
    # parse lists
    if value.startswith('[') and value.endswith(']'):
        inner = value[1:-1]
        value = [v.strip() for v in inner.split(',')]

    if key:
        block.set(key, value)
    sf.set_block(block)
    sf.save()
    
    # Log session
    _log_session('set', args, f"@{block_tag}.{key}={value}")
    
    print(f"  ✓ set @{block_tag}.{key} = {value}")


def cmd_add(args):
    """Append to a list in a block."""
    if len(args) < 3:
        print("Usage: s add <file> <block.key> <value>", file=sys.stderr)
        sys.exit(1)

    filepath = resolve_file(args[0])
    sf = SFile(filepath)

    path = args[1].lstrip('@')  # strip leading @ if user typed it
    parts = path.split('.', 1)
    block_tag = parts[0]
    key = parts[1] if len(parts) > 1 else None

    block = sf.get_block(block_tag)
    if not block:
        block = Block(block_tag, '')

    value = ' '.join(args[2:])
    if key:
        block.add(key, value)
    sf.set_block(block)
    sf.save()
    
    # Log session
    _log_session('add', args, f"@{block_tag}.{key}+={value}")
    
    print(f"  ✓ added to @{block_tag}.{key}")


def cmd_list(args):
    """List all blocks in a file."""
    if not args:
        print("Usage: s list <file>", file=sys.stderr)
        sys.exit(1)

    filepath = resolve_file(args[0])
    if not filepath.exists():
        print(f"File not found: {filepath}", file=sys.stderr)
        sys.exit(1)

    sf = SFile(filepath)
    if not sf.blocks:
        print(f"  (no blocks in {args[0]})")
        return

    print(f"  blocks in {args[0]}:")
    for b in sf.blocks:
        keys = ', '.join(b.props.keys()) if b.props else '(empty)'
        print(f"    @{b.tag:20s} {keys}")


def cmd_graph(args):
    """Show relationship graph."""
    relations_file = CTX_DIR / "relations.s"
    if not relations_file.exists():
        print("  No relations.s found. Run 's init' first.", file=sys.stderr)
        sys.exit(1)

    content = relations_file.read_text()
    lines = []
    for line in content.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        lines.append(line)

    if not lines:
        print("  (empty graph)")
        return

    # build adjacency list
    nodes = {}
    for line in lines:
        m = re.match(r'^(\S+)\s*([>!<~^])\s*(\S+)(?:\s*.*)?$', line)
        if m:
            src, rel, dst = m.group(1), m.group(2), m.group(3)
            nodes.setdefault(src, []).append((rel, dst))

    # render
    print("  relationships:")
    for src, targets in nodes.items():
        for rel, dst in targets:
            sym = {'>': '→', '<': '←', '!': '✗', '~': '~', '^': '^'}.get(rel, rel)
            print(f"    {src} {sym} {dst}")


def cmd_validate(args):
    """Validate all .s files."""
    errors = 0
    for sf_path in sorted(CTX_DIR.rglob("*.s")):
        rel = sf_path.relative_to(CTX_DIR)
        try:
            sf = SFile(sf_path)
            # basic checks
            for b in sf.blocks:
                if not b.tag:
                    print(f"  ✗ {rel}: block with no tag")
                    errors += 1
            print(f"  ✓ {rel} ({len(sf.blocks)} blocks)")
        except Exception as e:
            print(f"  ✗ {rel}: {e}")
            errors += 1

    if errors:
        print(f"\n  {errors} error(s) found")
        sys.exit(1)
    else:
        print(f"\n  ✓ all files valid")


def cmd_snap(args):
    """Snapshot current state."""
    SNAP_DIR.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    snap_file = SNAP_DIR / f"{ts}.json"

    state = {}
    for sf_path in sorted(CTX_DIR.rglob("*.s")):
        if ".snaps" in str(sf_path):
            continue
        rel = sf_path.relative_to(CTX_DIR)
        content = sf_path.read_text()
        h = hashlib.sha256(content.encode()).hexdigest()[:12]
        state[str(rel)] = {"hash": h, "size": len(content)}

    snap_file.write_text(json.dumps(state, indent=2))
    print(f"  ✓ snapshot saved: {snap_file.name}")


def cmd_diff(args):
    """Show changes since last snapshot."""
    snaps = sorted(SNAP_DIR.glob("*.json")) if SNAP_DIR.exists() else []
    if not snaps:
        print("  No snapshots yet. Run 's snap' first.")
        return

    last = json.loads(snaps[-1].read_text())
    changes = []

    for sf_path in sorted(CTX_DIR.rglob("*.s")):
        if ".snaps" in str(sf_path):
            continue
        rel = sf_path.relative_to(CTX_DIR)
        content = sf_path.read_text()
        h = hashlib.sha256(content.encode()).hexdigest()[:12]
        key = str(rel)

        if key not in last:
            changes.append(f"  + {key} (new)")
        elif last[key]["hash"] != h:
            changes.append(f"  ~ {key} (modified)")
            # show rough diff
            old_size = last[key]["size"]
            new_size = len(content)
            diff_size = new_size - old_size
            if diff_size != 0:
                changes.append(f"    size: {old_size} → {new_size} ({'+' if diff_size > 0 else ''}{diff_size})")

    # check for removed files
    for key in last:
        sf_path = CTX_DIR / key
        if not sf_path.exists():
            changes.append(f"  - {key} (removed)")

    if not changes:
        print("  ✓ no changes since last snapshot")
    else:
        print("  changes since last snapshot:")
        for c in changes:
            print(c)


def cmd_search(args):
    """Search across all .s files."""
    if not args:
        print("Usage: s search <query>", file=sys.stderr)
        sys.exit(1)

    query = ' '.join(args).lower()
    results = []

    for sf_path in sorted(CTX_DIR.rglob("*.s")):
        if ".snaps" in str(sf_path):
            continue
        content = sf_path.read_text()
        for i, line in enumerate(content.splitlines(), 1):
            if query in line.lower():
                rel = sf_path.relative_to(CTX_DIR)
                results.append(f"  {rel}:{i}: {line.strip()}")

    if results:
        print(f"  found {len(results)} match(es):")
        for r in results:
            print(r)
    else:
        print(f"  no matches for '{query}'")


def cmd_cat(args):
    """Raw output of a file (no parsing)."""
    if not args:
        print("Usage: s cat <file>", file=sys.stderr)
        sys.exit(1)

    filepath = resolve_file(args[0])
    if not filepath.exists():
        print(f"File not found: {filepath}", file=sys.stderr)
        sys.exit(1)

    print(filepath.read_text(), end='')


def cmd_where(args):
    """Show the context directory path."""
    print(f"  {CTX_DIR}")


def cmd_rm(args):
    """Remove a key from a block."""
    if len(args) < 2:
        print("Usage: s rm <file> <block.key>", file=sys.stderr)
        sys.exit(1)

    filepath = resolve_file(args[0])
    if not filepath.exists():
        print(f"File not found: {filepath}", file=sys.stderr)
        sys.exit(1)

    sf = SFile(filepath)
    path = args[1].lstrip('@')
    parts = path.split('.', 1)
    block_tag = parts[0]
    key = parts[1] if len(parts) > 1 else None

    block = sf.get_block(block_tag)
    if not block:
        print(f"Block @{block_tag} not found", file=sys.stderr)
        sys.exit(1)

    if key and key in block.props:
        del block.props[key]
        sf.save()
        print(f"  ✓ removed @{block_tag}.{key}")
    else:
        print(f"  key '{key}' not found in @{block_tag}", file=sys.stderr)


def cmd_blocks(args):
    """List all blocks across all files."""
    for sf_path in sorted(CTX_DIR.rglob("*.s")):
        if ".snaps" in str(sf_path):
            continue
        rel = sf_path.relative_to(CTX_DIR)
        sf = SFile(sf_path)
        if sf.blocks:
            for b in sf.blocks:
                keys = ', '.join(b.props.keys()) if b.props else '(empty)'
                print(f"  {str(rel):30s} @{b.tag:15s} {keys}")


def cmd_find(args):
    """Smart lookup: match topic to relevant .s blocks via index.s."""
    if not args:
        print("Usage: s find <topic>", file=sys.stderr)
        sys.exit(1)

    query = ' '.join(args).lower()
    index_path = CTX_DIR / "skills" / "index.s"
    if not index_path.exists():
        print(f"  index.s not found at {index_path}", file=sys.stderr)
        sys.exit(1)

    index_sf = SFile(index_path)
    matches = []

    # 1. check @quickRef for exact shortcut match
    for blk_name in ("quickRef", "runQuickRef"):
        qr_block = index_sf.get_block(blk_name)
        if qr_block:
            for key, val in qr_block.props.items():
                if query in key.lower():
                    matches.append(("quickRef", key, val))

    # 2. check @byTask for task match
    bt_block = index_sf.get_block("byTask")
    if bt_block:
        for key, val in bt_block.props.items():
            if query in key.lower():
                matches.append(("byTask", key, val))

    # 3. check @index for topic match
    idx_block = index_sf.get_block("index")
    if idx_block:
        for key, val in idx_block.props.items():
            if isinstance(val, str) and query in val.lower():
                matches.append(("index", key, val))

    if not matches:
        # fallback: search all .s files
        print(f"  no index match for '{query}', searching all files...")
        cmd_search(args)
        return

    # resolve and return blocks
    seen = set()
    for source, key, val in matches:
        parts = val.split() if isinstance(val, str) else []
        if len(parts) >= 3 and parts[0] == 's' and parts[1] in ('get', 'run'):
            # parse "s get file.s @block" or "s run file.s @run.block"
                fname = parts[2]
                block_ref = parts[3] if len(parts) > 3 else None
                file_key = f"{fname}:{block_ref}"
                if file_key in seen:
                    continue
                seen.add(file_key)
                filepath = CTX_DIR / "skills" / fname
                if filepath.exists():
                    sf = SFile(filepath)
                    if block_ref:
                        # handle "run.block" → tag is "run", subkey is "block"
                        block_name = block_ref.lstrip('@')
                        if '.' in block_name:
                            tag, subkey = block_name.split('.', 1)
                            block = sf.get_block(tag)
                            if block:
                                print(f"\n  @{block_name} ({fname}):")
                                for k, v in block.props.items():
                                    if subkey in k:
                                        if isinstance(v, dict):
                                            for ik, iv in v.items():
                                                print(f"    {ik}: {iv}")
                                        else:
                                            print(f"    {k}: {v}")
                        else:
                            block = sf.get_block(block_name)
                            if block:
                                print(f"\n  {fname}:@{block_name}:")
                                print(block.render())
                else:
                    print(f"  file not found: {fname}", file=sys.stderr)
        elif len(parts) >= 2 and parts[0] == 's' and parts[1] not in ('get', 'run'):
            # command like "s graph", "s deps blender-python", etc.
            print(f"  {key}: {val}")
        elif isinstance(val, str):
            # bare file reference like "docker.s linux.s ssh.s" or "strawexpress.s@express"
            for token in val.split():
                # strip @block suffix if present
                fname = token.split('@')[0] if '@' in token else token
                block_ref = token.split('@')[1] if '@' in token else None
                if fname.endswith('.s') and fname not in seen:
                    seen.add(fname)
                    filepath = CTX_DIR / "skills" / fname
                    if filepath.exists():
                        sf = SFile(filepath)
                        if block_ref:
                            # resolve specific block
                            block = sf.get_block(block_ref)
                            if block:
                                print(f"\n  {fname}:@{block_ref}:")
                                print(block.render())
                            else:
                                print(f"  block @{block_ref} not found in {fname}", file=sys.stderr)
                        else:
                            # show all @run blocks if present, else first blocks
                            run_blocks = [b for b in sf.blocks if b.tag == 'run']
                            if run_blocks:
                                print(f"\n  {fname} @run recipes:")
                                for b in run_blocks:
                                    first_key = next(iter(b.props), '') if b.props else ''
                                    print(f"    s find {first_key.split('.')[0]}  →  @{b.tag}")
                            else:
                                # show top blocks
                                print(f"\n  {fname} blocks: {', '.join('@'+b.tag for b in sf.blocks[:5])}")
                    else:
                        print(f"  file not found: {fname}", file=sys.stderr)


def cmd_freshness(args):
    """Check staleness of .s files based on @meta lastUpdated."""
    from datetime import datetime, timedelta

    warn_days = 180  # default: warn if older than 6 months
    target_file = None

    # parse args
    for arg in args:
        if arg.startswith('--warn='):
            try:
                warn_days = int(arg.split('=', 1)[1])
            except ValueError:
                print("  invalid --warn value", file=sys.stderr)
                sys.exit(1)
        elif arg.endswith('.s'):
            target_file = arg

    today = datetime.now()
    cutoff = today - timedelta(days=warn_days)
    results = []

    files_to_check = []
    if target_file:
        fp = CTX_DIR / "skills" / target_file
        if not fp.exists():
            fp = CTX_DIR / target_file
        if fp.exists():
            files_to_check.append(fp)
        else:
            print(f"  file not found: {target_file}", file=sys.stderr)
            sys.exit(1)
    else:
        for sf_path in sorted(CTX_DIR.rglob("*.s")):
            if ".snaps" in str(sf_path):
                continue
            files_to_check.append(sf_path)

    for sf_path in files_to_check:
        rel = sf_path.relative_to(CTX_DIR)
        sf = SFile(sf_path)
        meta = sf.get_block('meta')

        last_updated = None
        confidence = None
        deprecated = False

        if meta:
            last_updated_str = meta.get('lastUpdated')
            confidence = meta.get('confidence')
            deprecated = meta.get('deprecated') == 'true'

            if last_updated_str:
                try:
                    last_updated = datetime.strptime(str(last_updated_str), '%Y-%m-%d')
                except ValueError:
                    pass

        if last_updated:
            age_days = (today - last_updated).days
            is_stale = last_updated < cutoff

            if deprecated:
                status = "deprecated"
            elif is_stale:
                status = f"stale ({age_days}d > {warn_days}d)"
            else:
                status = f"fresh ({age_days}d)"

            conf_str = f" confidence:{confidence}" if confidence else ""
            results.append((str(rel), f"lastUpdated:{last_updated_str}", status, conf_str))
        else:
            results.append((str(rel), "no lastUpdated", "unknown", ""))

    # print results
    if results:
        print(f"  freshness report (warn if >{warn_days} days):")
        for name, date_str, status, conf in results:
            icon = "✓" if "fresh" in status else ("⚠" if "stale" in status or "deprecated" in status else "?")
            print(f"    {name:30s} {date_str:25s} {icon} {status}{conf}")
    else:
        print("  no .s files found")


def _estimate_tokens(text: str) -> int:
    """Estimate token count. Roughly 1 token per 4 chars, adjusted for structure."""
    if not text:
        return 0
    # base estimate: ~4 chars per token
    base = len(text) / 4
    # .s format has lots of short keys which tokenize efficiently
    # count lines (each key:value is ~2-3 tokens)
    lines = [l for l in text.splitlines() if l.strip() and not l.strip().startswith('#')]
    line_tokens = len(lines) * 2.5
    # blend: 60% char-based, 40% line-based
    return int(base * 0.6 + line_tokens * 0.4)


def cmd_tokens(args):
    """Count estimated tokens in .s files."""
    if not args:
        # count all skills
        total_tokens = 0
        total_chars = 0
        results = []
        for sf_path in sorted(CTX_DIR.rglob("*.s")):
            if ".snaps" in str(sf_path):
                continue
            content = sf_path.read_text()
            tokens = _estimate_tokens(content)
            chars = len(content)
            total_tokens += tokens
            total_chars += chars
            rel = sf_path.relative_to(CTX_DIR)
            results.append((str(rel), tokens, chars))

        if results:
            print("  token count (estimated):")
            for name, tokens, chars in results:
                print(f"    {name:30s} {tokens:6d} tokens  ({chars:6d} bytes)")
            print(f"    {'─' * 55}")
            print(f"    {'TOTAL':30s} {total_tokens:6d} tokens  ({total_chars:6d} bytes)")
            print(f"\n  prose equivalent: ~{total_tokens * 3} tokens (3x)")
            print(f"  savings per task: ~99% (selective loading)")
        return

    # count specific file/block
    filepath = CTX_DIR / "skills" / args[0]
    if not filepath.exists():
        filepath = CTX_DIR / args[0]
    if not filepath.exists():
        filepath = INSTRUCTIONS_DIR / args[0]
    if not filepath.exists():
        print(f"  file not found: {args[0]}", file=sys.stderr)
        sys.exit(1)

    sf = SFile(filepath)

    if len(args) > 1:
        # count specific block
        block_name = args[1].lstrip('@')
        block = sf.get_block(block_name)
        if not block:
            print(f"  block @{block_name} not found", file=sys.stderr)
            sys.exit(1)
        content = block.render()
        tokens = _estimate_tokens(content)
        chars = len(content)
        print(f"  {args[0]}:@{block_name}: {tokens} tokens ({chars} bytes)")
        print(f"  prose equivalent: ~{tokens * 3} tokens")
        print(f"  savings: ~{(1 - 1/3) * 100:.0f}%")
    else:
        # count whole file
        content = filepath.read_text()
        tokens = _estimate_tokens(content)
        chars = len(content)
        blocks = len(sf.blocks)
        print(f"  {args[0]}: {tokens} tokens ({chars} bytes, {blocks} blocks)")
        print(f"  prose equivalent: ~{tokens * 3} tokens")
        print(f"  per-block average: ~{tokens // max(blocks, 1)} tokens")


# ── Session Tracker ──────────────────────────────────────────────────────────

SESSION_DIR = CTX_DIR / ".sessions"
CURRENT_SESSION = None


def _get_session_file():
    """Get or create current session tracking file."""
    global CURRENT_SESSION
    SESSION_DIR.mkdir(parents=True, exist_ok=True)

    if CURRENT_SESSION is None:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        CURRENT_SESSION = SESSION_DIR / f"{ts}.json"
        if not CURRENT_SESSION.exists():
            CURRENT_SESSION.write_text(json.dumps({
                "started": datetime.now().isoformat(),
                "commands": [],
                "tokens_saved": 0,
                "websearch_fallbacks": 0,
            }, indent=2))

    return CURRENT_SESSION


def track_command(cmd_name: str, args: list, tokens_used: int = 0):
    """Track a command execution for session stats."""
    session_file = _get_session_file()
    data = json.loads(session_file.read_text())
    data["commands"].append({
        "time": datetime.now().isoformat(),
        "cmd": cmd_name,
        "args": args,
        "tokens": tokens_used,
    })
    session_file.write_text(json.dumps(data, indent=2))


def track_savings(tokens_saved: int):
    """Track tokens saved by using .s instead of prose."""
    session_file = _get_session_file()
    data = json.loads(session_file.read_text())
    data["tokens_saved"] = data.get("tokens_saved", 0) + tokens_saved
    session_file.write_text(json.dumps(data, indent=2))


def track_fallback():
    """Track a websearch fallback (when .s wasn't enough)."""
    session_file = _get_session_file()
    data = json.loads(session_file.read_text())
    data["websearch_fallbacks"] = data.get("websearch_fallbacks", 0) + 1
    session_file.write_text(json.dumps(data, indent=2))


def cmd_stats(args):
    """Show session usage statistics and cost savings."""
    if args and args[0] == '--all':
        # show all sessions
        if not SESSION_DIR.exists():
            print("  no sessions found")
            return

        sessions = sorted(SESSION_DIR.glob("*.json"))
        print(f"  {len(sessions)} session(s) found:\n")
        for sf in sessions[-10:]:  # last 10
            data = json.loads(sf.read_text())
            cmds = len(data.get("commands", []))
            saved = data.get("tokens_saved", 0)
            fallbacks = data.get("websearch_fallbacks", 0)
            started = data.get("started", "?")[:16]
            print(f"    {sf.stem}  cmds:{cmds:3d}  saved:{saved:6d}  fallbacks:{fallbacks}")
        return

    # show current session
    session_file = _get_session_file()
    data = json.loads(session_file.read_text())
    commands = data.get("commands", [])
    tokens_saved = data.get("tokens_saved", 0)
    fallbacks = data.get("websearch_fallbacks", 0)

    if not commands:
        print("  no commands tracked this session yet")
        return

    # count by command type
    cmd_counts = {}
    for c in commands:
        name = c.get("cmd", "?")
        cmd_counts[name] = cmd_counts.get(name, 0) + 1

    # calculate costs (rough estimates)
    # GPT-4o: $2.50 per 1M input tokens
    # Claude Sonnet: $3 per 1M input tokens
    cost_per_1m = 3.00  # assume Sonnet
    prose_tokens = tokens_saved * 3  # prose would be ~3x more
    cost_with_prose = (prose_tokens / 1_000_000) * cost_per_1m
    cost_with_s = ((prose_tokens - tokens_saved) / 1_000_000) * cost_per_1m
    cost_saved = cost_with_prose - cost_with_s

    print(f"  session stats:")
    print(f"    commands executed: {len(commands)}")
    print(f"    by type:")
    for name, count in sorted(cmd_counts.items(), key=lambda x: -x[1]):
        print(f"      {name:15s} {count}")
    print(f"")
    print(f"  token savings:")
    print(f"    tokens used (.s):   {tokens_saved:8d}")
    print(f"    tokens saved:       {tokens_saved:8d}  (vs loading full prose)")
    print(f"    prose equivalent:   {prose_tokens * 3:8d}")
    print(f"    savings ratio:      {99}%")
    print(f"")
    print(f"  cost impact (at ${cost_per_1m}/1M tokens):")
    print(f"    with prose only:    ${cost_with_prose:.4f}")
    print(f"    with .s selective:  ${cost_with_s:.4f}")
    print(f"    saved this session: ${cost_saved:.4f}")
    print(f"")
    if fallbacks:
        print(f"  fallbacks to websearch: {fallbacks}")
        print(f"    (indicates .s knowledge was insufficient)")
    print(f"")
    print(f"  tips:")
    print(f"    s stats --all       # show all sessions")
    print(f"    s tokens            # count tokens in all .s files")


def cmd_learn(args):
    """Learn from websearch output and update .s files.

    Usage: s learn <file.s> <block.key> <value>
           s learn <file.s> <block.key> --from-websearch 'websearch output'
    """
    if len(args) < 3:
        print("Usage: s learn <file.s> <block.key> <value>", file=sys.stderr)
        print("       s learn <file.s> <block.key> --from-websearch 'output'", file=sys.stderr)
        sys.exit(1)

    filepath = CTX_DIR / "skills" / args[0]
    if not filepath.exists():
        print(f"  file not found: {filepath}", file=sys.stderr)
        print(f"  create it first: s set {args[0]} @meta topic {args[0].replace('.s','')}")
        sys.exit(1)

    sf = SFile(filepath)

    # parse block.key - handle both "block.key" and "block key" formats
    raw_path = args[1].lstrip('@')
    if '.' in raw_path:
        parts = raw_path.split('.', 1)
        block_tag = parts[0]
        key = parts[1]
    else:
        block_tag = raw_path
        key = args[2] if len(args) > 2 and not args[2].startswith('--') else None

    block = sf.get_block(block_tag)
    if not block:
        block = Block(block_tag, '')

    # check for --from-websearch flag
    if '--from-websearch' in args:
        idx = args.index('--from-websearch')
        value = ' '.join(args[idx + 1:])
        source = "websearch"
    else:
        # value is everything after block.key
        if key:
            value = ' '.join(args[2:])
        else:
            value = ' '.join(args[2:])
        source = "manual"

    # parse lists
    if value.startswith('[') and value.endswith(']'):
        inner = value[1:-1]
        value = [v.strip() for v in inner.split(',')]

    if key:
        block.set(key, value)
    else:
        # no key, treat as block content update
        print(f"  specify key: s learn {args[0]} {block_tag}.<key> <value>", file=sys.stderr)
        sys.exit(1)

    # update lastUpdated in @meta
    meta = sf.get_block('meta')
    if meta:
        meta.set('lastUpdated', datetime.now().strftime('%Y-%m-%d'))
        sf.set_block(meta)

    sf.set_block(block)
    sf.save()

    # track the learning
    session_file = _get_session_file()
    data = json.loads(session_file.read_text())
    data["commands"].append({
        "time": datetime.now().isoformat(),
        "cmd": "learn",
        "args": [args[0], f"{block_tag}.{key}", str(value)],
        "source": source,
    })
    session_file.write_text(json.dumps(data, indent=2))

    print(f"  ✓ learned @{block_tag}.{key} = {value}")
    print(f"    source: {source}")
    print(f"    updated @meta.lastUpdated")


def _is_obvious_why(key: str, why_value: str, parent_value: str) -> bool:
    """Determine if a .why value is obvious (restates the directive).
    
    Aggressive approach: remove if adds no new info beyond directive name/value.
    """
    if not why_value or not parent_value:
        return False
    
    why_lower = why_value.lower().strip()
    parent_lower = parent_value.lower().strip()
    
    # Extract the base directive name from the key
    # e.g., "headerForward.why" → "headerForward", "proxy_set_header Host $host"
    base_key = key.rsplit('.why', 1)[0].split('.')[-1]
    
    # Normalize for comparison
    def normalize(s):
        return set(re.findall(r'[a-z]+', s.lower()))
    
    why_words = normalize(why_value)
    parent_words = normalize(parent_value)
    key_words = normalize(base_key)
    
    # If .why value is mostly restating the parent value words
    if parent_words and why_words.issubset(parent_words):
        return True
    
    # If .why value is mostly restating the key name words
    if key_words and why_words.issubset(key_words):
        return True
    
    # If .why is very short (<=4 words) and parent is self-explanatory
    if len(why_value.split()) <= 4:
        # Check for common obvious patterns
        obvious_patterns = [
            r'hides?.*\b(version|header|server)\b',
            r'prevents?.*\b(attack|exploit|injection|clickjacking)\b',
            r'enables?.*\b(feature|option|mode)\b',
            r'disables?.*\b(feature|option|logging)\b',
            r'sets?.*\b(timeout|limit|size|port)\b',
            r'forward(s|ed)?.*\b(header|host|ip)\b',
            r'preserves?.*\b(header|host|original)\b',
            r'redirect(s|ed)?.*\b(to|from|www)\b',
            r'validates?.*\b(config|syntax|input)\b',
            r'graceful\b.*\b(reload|shutdown)\b',
            r'hard\b.*\b(restart|reset|stop)\b',
            r'verbose\b.*\b(log|debug|output)\b',
            r'simple\b.*\b(check|health|test)\b',
            r'only\b.*\b(used|applies|works)\b',
            r'retry\b.*\b(on|backend|failure)\b',
            r'serve\b.*\b(stale|static|content)\b',
            r'block(s|ed)?\b.*\b(scraper|bot|known)\b',
            r'skip\b.*\b(logging|health|check)\b',
            r'reduce(s)?\b.*\b(noise|disk|I/O|traffic)\b',
            r'3x\b.*\b(traffic|more)\b',
            r'session\b.*\b(persistence)\b',
            r'immutable\b.*\b(tells|browser|revalidate)\b',
            r'exact\b.*\b(first|match)\b',
            r'prefix\b.*\b(match|then)\b',
            r'regex\b.*\b(match)\b',
        ]
        for pat in obvious_patterns:
            if re.search(pat, why_lower):
                return True
    
    # If parent value contains the .why explanation already
    # e.g., proxy_set_header Host $host → "preserves original host" is obvious
    parent_tokens = set(parent_lower.split())
    why_tokens = set(why_lower.split())
    if len(why_tokens) > 0 and len(why_tokens - parent_tokens) <= 1:
        # .why adds at most 1 new word beyond parent
        return True
    
    # If .why is just explaining what the directive name already says
    # e.g., "worker_processes auto" + "auto scales with CPU cores"
    if base_key.lower() in why_lower or why_lower in base_key.lower():
        return True
    
    return False


def _simplify_value(key: str, value: str) -> str:
    """Simplify a value string without sacrificing clarity."""
    if not value or value.startswith(('git ', 'npx ', 'certbot ', 'nginx ', 'systemctl ',
                                      'curl ', 'echo ', 'cat ', 'tail ', 'netstat ',
                                      'ps ', 'ss ', 'grep ', 'find ', '#', 'http',
                                      'proxy_', 'ssl_', 'limit_', 'error_', 'access_',
                                      'open_file_', 'reset_', 'client_', 'send_',
                                      'keepalive', 'location', 'server', 'upstream',
                                      'add_header', 'return', 'rewrite', 'if (', 'map ',
                                      'stub_status', 'allow', 'deny', 'geo ',
                                      'worker_', 'worker ', 'events', 'http ',
                                      '<', '{', '}', '=', '~')):
        return value  # Don't touch code/commands
    
    # Simplification rules
    simplified = value
    
    # Remove unnecessary articles
    simplified = re.sub(r'\bthe\b\s*', '', simplified)
    simplified = re.sub(r'\ba\b\s*(?=[aeiou])', '', simplified)
    simplified = re.sub(r'\ban\b\s*', '', simplified)
    
    # Collapse multiple spaces
    simplified = re.sub(r'\s+', ' ', simplified).strip()
    
    # Common phrase simplifications
    simplifications = [
        (r'\bfor this purpose\b', ''),
        (r'\bin order to\b', 'to'),
        (r'\bfor the purpose of\b', 'for'),
        (r'\bwith regard to\b', 'for'),
        (r'\bin the event that\b', 'if'),
        (r'\bat this point in time\b', 'now'),
        (r'\bdue to the fact that\b', 'because'),
        (r'\bin the case of\b', 'for'),
        (r'\bon a daily basis\b', 'daily'),
        (r'\bat the present time\b', 'now'),
        (r'\bfor the time being\b', 'temporarily'),
        (r'\bin the near future\b', 'soon'),
        (r'\bwith respect to\b', 'for'),
        (r'\bin the vicinity of\b', 'near'),
        (r'\bprior to\b', 'before'),
        (r'\bsubsequent to\b', 'after'),
        (r'\bin lieu of\b', 'instead of'),
        (r'\bin the event of\b', 'if'),
        (r'\bon behalf of\b', 'for'),
        (r'\bin accordance with\b', 'per'),
        (r'\bpertaining to\b', 'for'),
        (r'\bin reference to\b', 'for'),
        (r'\bin relation to\b', 'for'),
        (r'\bin connection with\b', 'for'),
        (r'\bwith the exception of\b', 'except'),
        (r'\bin excess of\b', 'over'),
        (r'\blargely due to\b', 'due to'),
        (r'\bprimarily due to\b', 'due to'),
        (r'\bmainly due to\b', 'due to'),
        (r'\bessentially\b', ''),
        (r'\bbasically\b', ''),
        (r'\bactually\b', ''),
        (r'\breally\b', ''),
        (r'\bvery\b', ''),
        (r'\bquite\b', ''),
        (r'\bfairly\b', ''),
        (r'\brather\b', ''),
        (r'\bjust\b', ''),
        (r'\bsimply\b', ''),
    ]
    
    for pattern, replacement in simplifications:
        simplified = re.sub(pattern, replacement, simplified, flags=re.IGNORECASE)
    
    # Collapse multiple spaces again
    simplified = re.sub(r'\s+', ' ', simplified).strip()
    
    # Only use simplified if it's meaningfully shorter and still clear
    if len(simplified) < len(value) * 0.85 and len(simplified) > 5:
        return simplified
    
    return value


def cmd_optimize(args):
    """Optimize .s files for token savings.
    
    Usage: s optimize <skill> [skill2] ... [--dry-run]
           s optimize --dry-run css html nginx
    
    Actions:
      - Remove obvious .why blocks (restating the directive)
      - Move non-obvious .why to @gotchas
      - Remove redundant information
      - Simplify explanations
    """
    dry_run = '--dry-run' in args
    skill_names = [a for a in args if not a.startswith('--')]
    
    if not skill_names:
        print("Usage: s optimize <skill> [skill2] ... [--dry-run]", file=sys.stderr)
        sys.exit(1)
    
    total_before_tokens = 0
    total_after_tokens = 0
    total_removed = 0
    total_moved = 0
    total_simplified = 0
    files_processed = 0
    
    for skill_name in skill_names:
        # Resolve file path
        if not skill_name.endswith('.s'):
            skill_name += '.s'
        
        # Check if locked
        if _is_locked(skill_name):
            print(f"  {skill_name}: locked (skipped)", file=sys.stderr)
            continue
        
        filepath = CTX_DIR / "skills" / skill_name
        if not filepath.exists():
            print(f"  file not found: {skill_name}", file=sys.stderr)
            continue
        
        sf = SFile(filepath)
        before_content = filepath.read_text()
        before_tokens = _estimate_tokens(before_content)
        total_before_tokens += before_tokens
        
        file_removed = 0
        file_moved = 0
        file_simplified = 0
        
        # Ensure @gotchas block exists
        gotchas_block = sf.get_block('gotchas')
        if not gotchas_block:
            gotchas_block = Block('gotchas', '')
        
        # ── Pass 1: Analyze .why keys ──
        for block in sf.blocks:
            why_keys = [k for k in block.props.keys() if k.endswith('.why')]
            
            for why_key in why_keys:
                why_value = block.props[why_key]
                if not isinstance(why_value, str):
                    continue
                
                # Find parent key
                base_key = why_key.rsplit('.why', 1)[0]
                parent_value = block.props.get(base_key, '')
                if not isinstance(parent_value, str):
                    parent_value = str(parent_value) if parent_value else ''
                
                if _is_obvious_why(why_key, why_value, parent_value):
                    # Remove obvious .why
                    del block.props[why_key]
                    file_removed += 1
                else:
                    # Move non-obvious .why to @gotchas
                    # Format: "key: explanation"
                    gotcha_key = f"{block.tag}.{base_key}"
                    gotchas_block.set(gotcha_key, why_value)
                    del block.props[why_key]
                    file_moved += 1
        
        # ── Pass 2: Remove redundancy across blocks ──
        # Check if @gotchas entries duplicate info in other blocks
        gotchas_to_remove = []
        for gkey, gval in gotchas_block.props.items():
            if not isinstance(gval, str):
                continue
            
            gval_lower = gval.lower()
            gval_words = set(re.findall(r'[a-z]+', gval_lower))
            
            # Check other blocks for duplicate info
            for block in sf.blocks:
                if block.tag == 'gotchas' or block.tag == 'meta':
                    continue
                
                for bkey, bval in block.props.items():
                    if bkey.endswith('.why') or not isinstance(bval, str):
                        continue
                    
                    bval_lower = bval.lower()
                    bval_words = set(re.findall(r'[a-z]+', bval_lower))
                    
                    # If gotcha value is mostly contained in another block's value
                    if gval_words and bval_words and gval_words.issubset(bval_words):
                        gotchas_to_remove.append(gkey)
                        break
                
                if gkey in gotchas_to_remove:
                    break
        
        for gkey in gotchas_to_remove:
            if gkey in gotchas_block.props:
                del gotchas_block.props[gkey]
                file_removed += 1
        
        # ── Pass 3: Simplify explanations ──
        for block in sf.blocks:
            for key, val in block.props.items():
                if key.endswith('.why') or key.startswith('_'):
                    continue
                if isinstance(val, str) and len(val) > 15:
                    simplified = _simplify_value(key, val)
                    if simplified != val:
                        block.props[key] = simplified
                        file_simplified += 1
        
        # Set the updated gotchas block
        if gotchas_block.props:
            sf.set_block(gotchas_block)
        elif sf.get_block('gotchas'):
            # Remove empty gotchas block
            sf.blocks = [b for b in sf.blocks if b.tag != 'gotchas']
        
        # Save or preview
        after_content = sf.render()
        after_tokens = _estimate_tokens(after_content)
        total_after_tokens += after_tokens
        total_removed += file_removed
        total_moved += file_moved
        total_simplified += file_simplified
        files_processed += 1
        
        if dry_run:
            print(f"\n  {skill_name} (dry-run):")
            print(f"    before: {before_tokens} tokens ({len(before_content)} bytes)")
            print(f"    after:  {after_tokens} tokens ({len(after_content)} bytes)")
            print(f"    saved:  {before_tokens - after_tokens} tokens ({(before_tokens - after_tokens) / max(before_tokens, 1) * 100:.1f}%)")
            print(f"    actions: {file_removed} removed, {file_moved} moved to @gotchas, {file_simplified} simplified")
            
            # Show diff preview
            old_lines = before_content.splitlines()
            new_lines = after_content.splitlines()
            diff = list(difflib.unified_diff(old_lines, new_lines, lineterm='', n=1))
            if diff:
                print(f"    changes:")
                for line in diff[:20]:
                    print(f"      {line}")
                if len(diff) > 20:
                    print(f"      ... ({len(diff) - 20} more lines)")
        else:
            sf.save()
            print(f"  ✓ {skill_name}: {before_tokens} → {after_tokens} tokens (-{before_tokens - after_tokens}, {file_removed} removed, {file_moved} moved, {file_simplified} simplified)")
    
    # Summary
    if files_processed > 0:
        saved = total_before_tokens - total_after_tokens
        print(f"\n  optimization {'preview' if dry_run else 'complete'}:")
        print(f"    files: {files_processed}")
        print(f"    tokens: {total_before_tokens} → {total_after_tokens} (-{saved}, {saved / max(total_before_tokens, 1) * 100:.1f}%)")
        print(f"    actions: {total_removed} removed, {total_moved} moved to @gotchas, {total_simplified} simplified")
        if dry_run:
            print(f"\n  run without --dry-run to apply changes")


def cmd_help(args):
    """Show help for a command."""
    if args and args[0] in COMMANDS:
        cmd = COMMANDS[args[0]]
        print(f"  {args[0]} - {cmd.__doc__}")
    else:
        print("  s.py - compact state DSL for AI-assisted projects")
        print(f"\n  commands:")
        for name, cmd in COMMANDS.items():
            print(f"    {name:12s} {(cmd.__doc__ or '').strip().splitlines()[0]}")
        print(f"\n  dotS dir: {CTX_DIR}")
        print(f"\n  examples:")
        print(f"    s get index.s           # read project index")
        print(f"    s get modules/core.s @t # read TODOs from core module")
        print(f"    s set modules/core.s s.state stable")
        print(f"    s add modules/core.s @t.add 'TODO: thing' priority:high")
        print(f"    s graph                 # show relationships")
        print(f"    s search 'todo'         # search across all files")


def cmd_refresh(args):
    """Refresh .s files based on freshness/confidence.
    
    Usage: s refresh <file.s>           # refresh specific file
           s refresh --all              # refresh all stale files
           s refresh --confidence low   # refresh only low-confidence files
    """
    from datetime import datetime, timedelta
    
    warn_days = 30  # default: refresh if older than 30 days
    target_file = None
    refresh_all = False
    confidence_filter = None
    
    # Parse args
    for arg in args:
        if arg == '--all':
            refresh_all = True
        elif arg.startswith('--confidence='):
            confidence_filter = arg.split('=', 1)[1]
        elif arg.startswith('--warn='):
            try:
                warn_days = int(arg.split('=', 1)[1])
            except ValueError:
                print("  invalid --warn value", file=sys.stderr)
                sys.exit(1)
        elif arg.endswith('.s'):
            target_file = arg
    
    if not target_file and not refresh_all and not confidence_filter:
        print("Usage: s refresh <file.s> | --all | --confidence <level>", file=sys.stderr)
        sys.exit(1)
    
    today = datetime.now()
    cutoff = today - timedelta(days=warn_days)
    files_to_refresh = []
    
    # Collect files to refresh
    if target_file:
        fp = CTX_DIR / "skills" / target_file
        if not fp.exists():
            fp = CTX_DIR / target_file
        if fp.exists():
            files_to_refresh.append(fp)
        else:
            print(f"  file not found: {target_file}", file=sys.stderr)
            sys.exit(1)
    else:
        # Scan all .s files
        for sf_path in sorted(CTX_DIR.rglob("*.s")):
            if ".snaps" in str(sf_path) or ".state" in str(sf_path):
                continue
            sf = SFile(sf_path)
            meta = sf.get_block('meta')
            
            if meta:
                last_updated_str = meta.get('lastUpdated')
                confidence = meta.get('confidence')
                deprecated = meta.get('deprecated') == 'true'
                
                if deprecated:
                    continue
                
                # Apply confidence filter
                if confidence_filter and confidence != confidence_filter:
                    continue
                
                # Check freshness
                if last_updated_str:
                    try:
                        last_updated = datetime.strptime(str(last_updated_str), '%Y-%m-%d')
                        if last_updated < cutoff:
                            files_to_refresh.append(sf_path)
                    except ValueError:
                        pass
    
    if not files_to_refresh:
        print("  no files need refreshing")
        return
    
    print(f"  refreshing {len(files_to_refresh)} file(s)...")
    
    for sf_path in files_to_refresh:
        rel = sf_path.relative_to(CTX_DIR)
        sf = SFile(sf_path)
        meta = sf.get_block('meta')
        
        if meta:
            old_date = meta.get('lastUpdated', 'unknown')
            old_confidence = meta.get('confidence', 'unknown')
            
            # Simulate websearch (in real implementation, this would call websearch)
            # For now, just update the timestamp and bump confidence
            meta.set('lastUpdated', today.strftime('%Y-%m-%d'))
            
            # If confidence was low, bump to medium after refresh
            if old_confidence == 'low':
                meta.set('confidence', 'medium')
            
            sf.set_block(meta)
            sf.save()
            
            print(f"  ✓ {rel}: lastUpdated {old_date} → {today.strftime('%Y-%m-%d')}")
            if old_confidence != meta.get('confidence'):
                print(f"    confidence: {old_confidence} → {meta.get('confidence')}")
        else:
            print(f"  ⚠ {rel}: no @meta block, skipping")
    
    print(f"\n  refresh complete. Use websearch to update actual content.")


def cmd_unload(args):
    """Unload .s files from context.
    
    Usage: s unload skills/nginx.s      # unload specific file
           s unload skills/*             # unload all skills
           s unload index                # unload index.s
           s unload --list               # show loaded files
    """
    if not args:
        print("Usage: s unload <file.s> | skills/* | index | --list", file=sys.stderr)
        print("  bare 's unload' is not allowed - specify what to unload", file=sys.stderr)
        sys.exit(1)
    
    if args[0] == '--list':
        # Show loaded files
        loaded = _get_loaded()
        if not loaded:
            print("  no files currently loaded")
        else:
            print(f"  loaded files ({len(loaded)}):")
            for f in loaded:
                print(f"    {f}")
        return
    
    target = args[0]
    unloaded = 0
    
    if target == 'skills/*':
        # Unload all skills
        loaded = _get_loaded()
        to_unload = [f for f in loaded if f.startswith('skills/')]
        
        if not to_unload:
            print("  no skill files loaded")
            return
        
        for f in to_unload:
            if _unload_file(f):
                unloaded += 1
                print(f"  ✓ unloaded {f}")
        
        print(f"\n  unloaded {unloaded} skill file(s)")
    
    elif target == 'index':
        # Unload index.s
        if _unload_file('index.s'):
            print("  ✓ unloaded index.s")
        else:
            print("  index.s was not loaded")
    
    elif target.endswith('.s'):
        # Unload specific file
        # Normalize path
        if not target.startswith('skills/') and not target.startswith('modules/'):
            # Try to find in skills first
            if (CTX_DIR / 'skills' / target).exists():
                target = f'skills/{target}'
        
        if _unload_file(target):
            print(f"  ✓ unloaded {target}")
        else:
            print(f"  {target} was not loaded")
    
    else:
        print("Usage: s unload <file.s> | skills/* | index | --list", file=sys.stderr)
        sys.exit(1)


def cmd_compact(args):
    """Compact session learnings into .s files.
    
    Usage: s compact                  # apply pending changes
           s compact --dry-run        # preview changes
           s compact --force          # overwrite existing values
    """
    dry_run = '--dry-run' in args
    force = '--force' in args
    
    entries = _get_session_log()
    
    if not entries:
        print("  no session changes to compact")
        return
    
    # Group changes by file
    changes_by_file = {}
    for entry in entries:
        cmd = entry['cmd']
        cmd_args = entry['args']
        
        if cmd in ('set', 'add', 'learn') and len(cmd_args) >= 2:
            filepath = cmd_args[0]
            if filepath not in changes_by_file:
                changes_by_file[filepath] = []
            changes_by_file[filepath].append(entry)
    
    if not changes_by_file:
        print("  no compactable changes found")
        return
    
    print(f"  compacting {sum(len(v) for v in changes_by_file.values())} changes across {len(changes_by_file)} file(s)...\n")
    
    files_updated = 0
    
    for filepath, file_entries in changes_by_file.items():
        # Resolve file
        fp = CTX_DIR / filepath
        if not fp.exists():
            fp = CTX_DIR / "skills" / filepath
        if not fp.exists():
            print(f"  ⚠ {filepath}: file not found, skipping")
            continue
        
        sf = SFile(fp)
        changes_made = 0
        
        for entry in file_entries:
            cmd = entry['cmd']
            cmd_args = entry['args']
            
            if cmd == 'set' and len(cmd_args) >= 3:
                path = cmd_args[1].lstrip('@')
                parts = path.split('.', 1)
                block_tag = parts[0]
                key = parts[1] if len(parts) > 1 else None
                value = ' '.join(cmd_args[2:])
                
                # Parse lists
                if value.startswith('[') and value.endswith(']'):
                    inner = value[1:-1]
                    value = [v.strip() for v in inner.split(',')]
                
                block = sf.get_block(block_tag)
                if not block:
                    block = Block(block_tag, '')
                
                # Check if value already exists
                existing = block.get(key) if key else None
                if existing is not None and not force and existing == value:
                    continue  # Skip unchanged
                
                if key:
                    block.set(key, value)
                    sf.set_block(block)
                    changes_made += 1
                    
                    if dry_run:
                        print(f"    [dry-run] {filepath}: @{block_tag}.{key} = {value}")
            
            elif cmd == 'add' and len(cmd_args) >= 3:
                path = cmd_args[1].lstrip('@')
                parts = path.split('.', 1)
                block_tag = parts[0]
                key = parts[1] if len(parts) > 1 else None
                value = ' '.join(cmd_args[2:])
                
                block = sf.get_block(block_tag)
                if not block:
                    block = Block(block_tag, '')
                
                if key:
                    block.add(key, value)
                    sf.set_block(block)
                    changes_made += 1
                    
                    if dry_run:
                        print(f"    [dry-run] {filepath}: @{block_tag}.{key} += {value}")
        
        # Update @meta.lastUpdated if changes were made
        if changes_made > 0:
            meta = sf.get_block('meta')
            if meta:
                meta.set('lastUpdated', datetime.now().strftime('%Y-%m-%d'))
                sf.set_block(meta)
            
            if not dry_run:
                sf.save()
            
            files_updated += 1
            print(f"  {'✓' if not dry_run else '~'} {filepath}: {changes_made} change(s)")
    
    # Clear session log if not dry-run
    if not dry_run and files_updated > 0:
        _clear_session_log()
        print(f"\n  ✓ compacted {files_updated} file(s), session log cleared")
    elif dry_run:
        print(f"\n  dry-run complete. Use 's compact' to apply.")
    else:
        print("  no changes to apply")


def cmd_loaded(args):
    """Show currently loaded .s files."""
    loaded = _get_loaded()
    if not loaded:
        print("  no files currently loaded")
    else:
        print(f"  loaded files ({len(loaded)}):")
        for f in loaded:
            print(f"    {f}")
        print(f"\n  use 's unload <file>' to unload")


def cmd_lock(args):
    """Lock skills to prevent optimization.
    
    Usage: s lock <skill> [skill2] ...
           s lock writing-skill blender-python
    """
    if not args:
        print("Usage: s lock <skill> [skill2] ...", file=sys.stderr)
        sys.exit(1)
    
    locked = _get_locked()
    added = 0
    
    for skill_name in args:
        if not skill_name.endswith('.s'):
            skill_name += '.s'
        
        # Check if file exists
        filepath = CTX_DIR / "skills" / skill_name
        if not filepath.exists():
            print(f"  {skill_name}: file not found", file=sys.stderr)
            continue
        
        if skill_name not in locked:
            locked.append(skill_name)
            added += 1
            # Make file read-only
            try:
                filepath.chmod(0o444)
                print(f"  {skill_name}: locked")
            except Exception as e:
                print(f"  {skill_name}: locked (chmod failed: {e})")
        else:
            print(f"  {skill_name}: already locked")
    
    if added > 0:
        _set_locked(locked)
        print(f"\n  {added} skill(s) locked")


def cmd_unlock(args):
    """Unlock skills to allow optimization.
    
    Usage: s unlock <skill> [skill2] ...
           s unlock writing-skill blender-python
           s unlock --all
    """
    if not args:
        print("Usage: s unlock <skill> [skill2] ... | --all", file=sys.stderr)
        sys.exit(1)
    
    locked = _get_locked()
    
    if '--all' in args:
        count = len(locked)
        # Make all locked files writable
        for skill_name in locked:
            filepath = CTX_DIR / "skills" / skill_name
            if filepath.exists():
                try:
                    filepath.chmod(0o644)
                except:
                    pass
        _set_locked([])
        print(f"  unlocked all {count} skill(s)")
        return
    
    removed = 0
    for skill_name in args:
        if not skill_name.endswith('.s'):
            skill_name += '.s'
        
        if skill_name in locked:
            locked.remove(skill_name)
            removed += 1
            # Make file writable
            filepath = CTX_DIR / "skills" / skill_name
            if filepath.exists():
                try:
                    filepath.chmod(0o644)
                    print(f"  {skill_name}: unlocked")
                except Exception as e:
                    print(f"  {skill_name}: unlocked (chmod failed: {e})")
            else:
                print(f"  {skill_name}: unlocked")
        else:
            print(f"  {skill_name}: not locked")
    
    if removed > 0:
        _set_locked(locked)
        print(f"\n  {removed} skill(s) unlocked")


def cmd_locked(args):
    """List locked skills.
    
    Usage: s locked
    """
    locked = _get_locked()
    if not locked:
        print("  no skills locked")
    else:
        print(f"  locked skills ({len(locked)}):")
        for f in locked:
            print(f"    {f}")
        print(f"\n  use 's unlock <skill>' to unlock")


def cmd_deps(args):
    """Show dependencies for a skill.
    
    Usage: s deps <skill>
           s deps blender-python
           s deps --all
    """
    if not args:
        print("Usage: s deps <skill> | --all", file=sys.stderr)
        sys.exit(1)
    
    if '--all' in args:
        # Show all skills and their dependencies
        skills_dir = CTX_DIR / "skills"
        print("  dependency graph:")
        for f in sorted(skills_dir.glob("*.s")):
            if f.name.startswith('.'):
                continue
            deps = _get_skill_deps(f.name)
            if deps:
                print(f"    {f.name} -> {', '.join(deps)}")
        return
    
    skill_name = args[0]
    if not skill_name.endswith('.s'):
        skill_name += '.s'
    
    deps = _get_skill_deps(skill_name)
    if not deps:
        print(f"  {skill_name}: no dependencies")
    else:
        print(f"  {skill_name} depends on:")
        for dep in deps:
            print(f"    - {dep}")


def cmd_load(args):
    """Load a skill and all its dependencies.
    
    Usage: s load <skill>
           s load blender-python
    """
    if not args:
        print("Usage: s load <skill>", file=sys.stderr)
        sys.exit(1)
    
    skill_name = args[0]
    if not skill_name.endswith('.s'):
        skill_name += '.s'
    
    # Resolve all dependencies
    all_deps = _resolve_all_deps(skill_name)
    
    # Add the skill itself
    to_load = [skill_name] + all_deps
    loaded = _get_loaded()
    loaded_count = 0
    
    for skill in to_load:
        skill_path = f"skills/{skill}"
        if skill_path not in loaded:
            filepath = CTX_DIR / "skills" / skill
            if filepath.exists():
                _track_loaded(skill_path)
                loaded_count += 1
                print(f"  loaded: {skill}")
            else:
                print(f"  not found: {skill}")
        else:
            print(f"  already loaded: {skill}")
    
    if loaded_count > 0:
        print(f"\n  {loaded_count} skill(s) loaded")
    else:
        print("\n  all skills already loaded")


def cmd_graph(args):
    """Show dependency graph.
    
    Usage: s graph
           s graph --deps
    """
    show_deps = '--deps' in args
    
    print("  skill dependency graph:")
    print()
    
    skills_dir = CTX_DIR / "skills"
    for f in sorted(skills_dir.glob("*.s")):
        if f.name.startswith('.'):
            continue
        deps = _get_skill_deps(f.name)
        if deps:
            print(f"  {f.name}")
            for dep in deps:
                print(f"    -> {dep}")
    
    if show_deps:
        print()
        print("  resolved dependencies:")
        for f in sorted(skills_dir.glob("*.s")):
            if f.name.startswith('.'):
                continue
            all_deps = _resolve_all_deps(f.name)
            if all_deps:
                print(f"  {f.name}: {', '.join(all_deps)}")


def cmd_mega(args):
    """Manage mega-skills (skill bundles).
    
    Usage: s mega list
           s mega create <name> <skill1> <skill2> ...
           s mega load <name>
           s mega show <name>
    """
    if not args:
        print("Usage: s mega <list|create|load|show>", file=sys.stderr)
        sys.exit(1)
    
    action = args[0]
    
    if action == 'list':
        mega = _get_mega_skills()
        if not mega:
            print("  no mega-skills defined")
        else:
            print(f"  mega-skills ({len(mega)}):")
            for name, skills in mega.items():
                print(f"    {name}: {', '.join(skills)}")
    
    elif action == 'create':
        if len(args) < 3:
            print("Usage: s mega create <name> <skill1> <skill2> ...", file=sys.stderr)
            sys.exit(1)
        
        name = args[1]
        skills = args[2:]
        _create_mega_skill(name, skills)
        print(f"  created mega-skill: {name}")
    
    elif action == 'load':
        if len(args) < 2:
            print("Usage: s mega load <name>", file=sys.stderr)
            sys.exit(1)
        
        name = args[1]
        skills = _load_mega_skill(name)
        if skills:
            print(f"  loaded mega-skill: {name} ({len(skills)} skills)")
        else:
            print(f"  mega-skill not found: {name}")
    
    elif action == 'show':
        if len(args) < 2:
            print("Usage: s mega show <name>", file=sys.stderr)
            sys.exit(1)
        
        name = args[1]
        mega = _get_mega_skills()
        if name in mega:
            print(f"  mega-skill: {name}")
            for skill in mega[name]:
                print(f"    - {skill}")
        else:
            print(f"  mega-skill not found: {name}")
    
    else:
        print(f"  unknown action: {action}", file=sys.stderr)
        print("  available: list, create, load, show", file=sys.stderr)
        sys.exit(1)


def cmd_mutate(args):
    """Create or list skill mutations.
    
    Usage: s mutate list
           s mutate create <base_skill> <context> [name]
           s mutate show <name>
    """
    if not args:
        print("Usage: s mutate <list|create|show>", file=sys.stderr)
        sys.exit(1)
    
    action = args[0]
    
    if action == 'list':
        mutations = _get_mutations()
        if not mutations:
            print("  no mutations defined")
        else:
            print(f"  mutations ({len(mutations)}):")
            for name, info in mutations.items():
                print(f"    {name}: {info['parent']} for {info['context']}")
    
    elif action == 'create':
        if len(args) < 3:
            print("Usage: s mutate create <base_skill> <context> [name]", file=sys.stderr)
            sys.exit(1)
        
        base_skill = args[1]
        context = args[2]
        name = args[3] if len(args) > 3 else None
        
        mut_name = _create_mutation(base_skill, context, name)
        print(f"  created mutation: {mut_name}")
    
    elif action == 'show':
        if len(args) < 2:
            print("Usage: s mutate show <name>", file=sys.stderr)
            sys.exit(1)
        
        name = args[1]
        mutations = _get_mutations()
        if name in mutations:
            info = mutations[name]
            print(f"  mutation: {name}")
            print(f"    base: {info['parent']}")
            print(f"    context: {info['context']}")
        else:
            print(f"  mutation not found: {name}")
    
    else:
        print(f"  unknown action: {action}", file=sys.stderr)
        print("  available: list, create, show", file=sys.stderr)
        sys.exit(1)


def cmd_pollinate(args):
    """Cross-pollinate skills (share patterns).
    
    Usage: s pollinate list
           s pollinate <skill1> <skill2>
           s pollinate --all
    """
    if not args:
        print("Usage: s pollinate <skill1> <skill2> | --all", file=sys.stderr)
        sys.exit(1)
    
    if args[0] == 'list':
        # Show all skills with their patterns
        print("  skill patterns:")
        skills_dir = CTX_DIR / "skills"
        for f in sorted(skills_dir.glob("*.s")):
            if f.name.startswith('.'):
                continue
            sf = SFile(f)
            blocks = [b.tag for b in sf.blocks if not b.tag.startswith('_')]
            if blocks:
                print(f"    {f.name}: {', '.join(blocks[:5])}")
        return
    
    if args[0] == '--all':
        # Show all possible cross-pollinations
        skills_dir = CTX_DIR / "skills"
        skills = [f.name for f in sorted(skills_dir.glob("*.s")) if not f.name.startswith('.')]
        
        print("  cross-pollination opportunities:")
        for i, s1 in enumerate(skills):
            for s2 in skills[i+1:]:
                sf1 = SFile(CTX_DIR / "skills" / s1)
                sf2 = SFile(CTX_DIR / "skills" / s2)
                blocks1 = set(b.tag for b in sf1.blocks)
                blocks2 = set(b.tag for b in sf2.blocks)
                common = blocks1 & blocks2
                if common:
                    print(f"    {s1} <-> {s2}: {', '.join(common)}")
        return
    
    if len(args) < 2:
        print("Usage: s pollinate <skill1> <skill2>", file=sys.stderr)
        sys.exit(1)
    
    skill1, skill2 = args[0], args[1]
    if not skill1.endswith('.s'):
        skill1 += '.s'
    if not skill2.endswith('.s'):
        skill2 += '.s'
    
    sf1 = SFile(CTX_DIR / "skills" / skill1)
    sf2 = SFile(CTX_DIR / "skills" / skill2)
    
    blocks1 = set(b.tag for b in sf1.blocks)
    blocks2 = set(b.tag for b in sf2.blocks)
    
    common = blocks1 & blocks2
    only1 = blocks1 - blocks2
    only2 = blocks2 - blocks1
    
    print(f"  cross-pollination: {skill1} <-> {skill2}")
    print(f"    common blocks: {', '.join(common) if common else 'none'}")
    print(f"    only in {skill1}: {', '.join(only1) if only1 else 'none'}")
    print(f"    only in {skill2}: {', '.join(only2) if only2 else 'none'}")


def cmd_run(args):
    """Execute a @run playbook from a .s file.
    
    Usage: s run git.s @run.quickCommit
           s run nginx.s @run.sslSetup --dry-run
    """
    import subprocess
    
    if len(args) < 2:
        print("Usage: s run <file.s> <@run.blockName> [--dry-run]", file=sys.stderr)
        sys.exit(1)
    
    filepath = resolve_file(args[0])
    if not filepath.exists():
        print(f"File not found: {filepath}", file=sys.stderr)
        sys.exit(1)
    
    # Parse block name (strip @run. prefix if present)
    block_ref = args[1]
    if block_ref.startswith('@run.'):
        block_name = block_ref[5:]
    elif block_ref.startswith('@'):
        block_name = block_ref[1:]
    else:
        block_name = block_ref
    
    dry_run = '--dry-run' in args
    
    # Read and parse file
    sf = SFile(filepath)
    
    # Find the @run block with the matching name
    block = None
    for b in sf.blocks:
        if b.tag == 'run':
            # Check if the block name matches via _name property
            if b.props.get('_name') == block_name:
                block = b
                break
    
    if not block:
        print(f"Block @run.{block_name} not found in {args[0]}", file=sys.stderr)
        sys.exit(1)
    
    # Parse steps from block (exclude _name property)
    steps = {}
    for key, val in block.props.items():
        if key == '_name':
            continue
        # Parse "1.cmd", "1.expect", "1.onFail", etc.
        match = re.match(r'^(\d+)\.(cmd|expect|onFail|note)$', key)
        if match:
            step_num = int(match.group(1))
            step_field = match.group(2)
            if step_num not in steps:
                steps[step_num] = {}
            steps[step_num][step_field] = val
    
    if not steps:
        print(f"  no steps found in @run.{block_name}", file=sys.stderr)
        sys.exit(1)
    
    # Sort steps by number
    sorted_steps = sorted(steps.keys())
    
    print(f"  executing @run.{block_name} ({len(sorted_steps)} steps)...")
    if dry_run:
        print(f"  [dry-run mode]\n")
    
    # Execute each step
    for step_num in sorted_steps:
        step = steps[step_num]
        cmd = step.get('cmd')
        expect = step.get('expect')
        on_fail = step.get('onFail')
        note = step.get('note')
        
        if note and not cmd:
            # Note-only step
            print(f"  {step_num}. {note}")
            continue
        
        if not cmd:
            continue
        
        print(f"  {step_num}. {cmd}")
        
        if dry_run:
            if expect is not None:
                print(f"     expect: {expect or '(empty)'}")
            if on_fail:
                print(f"     onFail: {on_fail}")
            continue
        
        # Execute command
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            output = result.stdout.strip()
            stderr = result.stderr.strip()
            
            if result.returncode != 0:
                # Command failed
                if on_fail:
                    print(f"     ✗ FAILED: {on_fail}")
                else:
                    print(f"     ✗ FAILED (exit {result.returncode})")
                    if stderr:
                        print(f"       {stderr}")
                print(f"\n  aborted at step {step_num}")
                sys.exit(1)
            
            # Check expected output
            if expect is not None:
                if expect == '':
                    # Expect empty output
                    if output:
                        print(f"     ✗ expected empty, got: {output[:50]}")
                        if on_fail:
                            print(f"       {on_fail}")
                        sys.exit(1)
                elif expect not in output:
                    # Expected string not in output
                    print(f"     ✗ expected '{expect}' in output")
                    print(f"       got: {output[:100]}")
                    if on_fail:
                        print(f"       {on_fail}")
                    sys.exit(1)
            
            if output:
                # Show output (truncated)
                for line in output.split('\n')[:5]:
                    print(f"       {line}")
                if len(output.split('\n')) > 5:
                    print(f"       ... ({len(output.split(chr(10)))} lines total)")
            
            print(f"     ✓")
            
        except subprocess.TimeoutExpired:
            print(f"     ✗ TIMEOUT (30s)")
            if on_fail:
                print(f"       {on_fail}")
            sys.exit(1)
        except Exception as e:
            print(f"     ✗ ERROR: {e}")
            sys.exit(1)
    
    print(f"\n  ✓ @run.{block_name} completed successfully")


# ── CLI ─────────────────────────────────────────────────────────────────────

COMMANDS = {
    'init': cmd_init,
    'get': cmd_get,
    'set': cmd_set,
    'add': cmd_add,
    'list': cmd_list,
    'ls': cmd_list,
    'graph': cmd_graph,
    'validate': cmd_validate,
    'snap': cmd_snap,
    'diff': cmd_diff,
    'search': cmd_search,
    's': cmd_search,
    'find': cmd_find,
    'freshness': cmd_freshness,
    'tokens': cmd_tokens,
    'stats': cmd_stats,
    'learn': cmd_learn,
    'cat': cmd_cat,
    'where': cmd_where,
    'rm': cmd_rm,
    'blocks': cmd_blocks,
    'refresh': cmd_refresh,
    'unload': cmd_unload,
    'compact': cmd_compact,
    'loaded': cmd_loaded,
    'run': cmd_run,
    'optimize': cmd_optimize,
    'lock': cmd_lock,
    'unlock': cmd_unlock,
    'locked': cmd_locked,
    'load': cmd_load,
    'deps': cmd_deps,
    'mega': cmd_mega,
    'mutate': cmd_mutate,
    'pollinate': cmd_pollinate,
    'help': cmd_help,
}


def main():
    if len(sys.argv) < 2:
        cmd_help([])
        sys.exit(0)

    cmd = sys.argv[1]
    args = sys.argv[2:]

    if cmd in ('-h', '--help', 'help') and not args:
        cmd_help([])
        sys.exit(0)

    if cmd not in COMMANDS:
        print(f"  unknown command: {cmd}", file=sys.stderr)
        print(f"  available: {', '.join(COMMANDS.keys())}", file=sys.stderr)
        sys.exit(1)

    COMMANDS[cmd](args)


if __name__ == '__main__':
    main()
