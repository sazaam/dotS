#!/usr/bin/env python3
"""s.py - Compact state management DSL for AI-assisted projects.

Usage:
    s init                  Scaffold .opencode/ctx/ structure
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

CTX_DIR = Path(os.environ.get("S_CTX_DIR", os.path.expanduser("~/.config/opencode/ctx")))
INSTRUCTIONS_DIR = Path(os.environ.get("S_INSTRUCTIONS_DIR", os.path.expanduser("~/.config/opencode/instructions")))
SNAP_DIR = CTX_DIR / ".snaps"


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


# ── Parser ──────────────────────────────────────────────────────────────────

class Block:
    def __init__(self, tag: str, raw: str):
        self.tag = tag
        self.raw = raw
        self.props: dict = {}
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
            return [v.strip().strip('"').strip("'") for v in self._split_list(inner)]
        if val.startswith('{') and val.endswith('}'):
            inner = val[1:-1]
            return self._parse_inline_map(inner)
        return val.strip().strip('"').strip("'")

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
        lines = [f'@{self.tag} |']
        for k, v in self.props.items():
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

        for line in content.splitlines():
            stripped = line.strip()
            # block start: @tag | with possible inline props
            m = re.match(r'^@(\S+)\s*\|(.*)\|?\s*$', stripped)
            if m:
                if current_tag is not None:
                    self.blocks.append(Block(current_tag, '\n'.join(current_lines)))
                current_tag = m.group(1)
                # extract inline properties from the tag line
                inline = m.group(2).strip().rstrip('|').strip()
                if inline:
                    current_lines = [p.strip() for p in inline.split('|') if p.strip()]
                else:
                    current_lines = []
            elif stripped == '|' and current_tag is not None:
                self.blocks.append(Block(current_tag, '\n'.join(current_lines)))
                current_tag = None
                current_lines = []
            elif current_tag is not None:
                current_lines.append(line)
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
    """Scaffold the .opencode/ctx/ structure."""
    global CTX_DIR, SNAP_DIR
    if args:
        CTX_DIR = Path(args[0]) / ".opencode" / "ctx"
    else:
        CTX_DIR = Path(os.path.expanduser("~/.config/opencode/ctx"))
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
        print(f"\n  ctx dir: {CTX_DIR}")
        print(f"\n  examples:")
        print(f"    s get index.s           # read project index")
        print(f"    s get modules/core.s @t # read TODOs from core module")
        print(f"    s set modules/core.s s.state stable")
        print(f"    s add modules/core.s @t.add 'TODO: thing' priority:high")
        print(f"    s graph                 # show relationships")
        print(f"    s search 'todo'         # search across all files")


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
