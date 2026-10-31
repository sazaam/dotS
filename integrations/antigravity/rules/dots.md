# dotS Knowledge & Workflow Rules

1. **Token-Efficient Knowledge First**: When dealing with infrastructure, deployment, system configuration, or supported frameworks (e.g., SSH, Docker, Podman, Nginx, Traefik, Linux, Blender, Three.js, GLSL, Rust), ALWAYS check dotS before conducting web searches or generating verbose speculative solutions:
   - Run `dots find <topic>` to locate relevant `.s` knowledge blocks.
   - Use `dots get <skill.s> [@block]` to retrieve precise commands, syntax, and configurations.
2. **Execute Verified Playbooks**: Whenever performing standardized operational tasks (e.g., SSH key setup, deploy keys, server hardening, firewall setup), check for and use `dots run <playbook>`.
3. **Persist Learnings**: When new, reusable configuration details or operational commands are validated during a task, store or update them using `dots set` or `dots add`.
