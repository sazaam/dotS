#!/bin/bash
# s - wrapper for s.py (global)
# Detect where this script is located
DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"
exec python3 "$DOTS_DIR/s.py" "$@"
