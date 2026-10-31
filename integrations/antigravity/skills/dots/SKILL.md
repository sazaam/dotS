---
name: dots
description: >-
  Use the dotS token-efficient state and knowledge storage system. Trigger whenever working with infrastructure, DevOps, system administration (SSH, Docker, Podman, Nginx, Traefik, Linux), specialized dev stacks (Blender, Three.js, Rust, GLSL), or looking up verified runbooks and commands.
---

# dotS Knowledge & State System

dotS stores dense, token-efficient knowledge in `.s` format (`key:value` pairs in blocks) inside `~/.config/opencode/dotS`.

## When to Use

1. **Before general research or web search:** Whenever configuring, troubleshooting, or setting up supported stacks (SSH, Docker, Podman, Nginx, Traefik, Linux, Blender, Rust, etc.).
2. **Running Playbooks:** When executing multi-step procedures defined in `@run` blocks.
3. **Recording Learned State:** When verifying operational commands or project patterns.

## Core Commands

- **Find relevant knowledge:**
  ```bash
  dots find <topic>
  ```
- **Inspect a specific block or full file:**
  ```bash
  dots get <skill>.s [@block]
  # Examples:
  dots get ssh.s @tunneling
  dots get docker.s @compose
  dots get rust.s @cargo
  ```
- **Search across all knowledge files:**
  ```bash
  dots search "<term>"
  ```
- **List blocks in a skill:**
  ```bash
  dots list <skill>.s
  ```
- **Execute a verified runbook:**
  ```bash
  dots run <playbook>
  # Example:
  dots run keySetup
  ```
- **Persist state and patterns:**
  ```bash
  dots add <skill>.s @block.list "new item"
  dots set <skill>.s key value
  ```
