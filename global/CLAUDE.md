# CLAUDE.md (Global)

General behavior rules and user identity for Claude Code.

## Identity & Preferences
- **Developer**: Individual developer, working solo.
- **Tone**: Concise, direct, no filler/formalism.
- **Workflow**: No PRs, issues, or formal reviews needed unless requested.
- **Editing**: Surgical section edits over full file rewrites.

## Session Protocols (MANDATORY)
- **Start**: Read `project/CLAUDE.md` and `project/memory/project_state.md` to sync context.
- **During**: If a bug is fixed or a success pattern is found, update `learnings.md`.
- **End**: Update `project_state.md` with progress and what's next.

## Code Standards
- ❌ No `any` in TypeScript.
- ❌ No `.env`, tokens, or secrets in commits.
- **Minimalism**: No comments for unchanged code; no speculative abstractions.
- **Commits**: Group semantic changes; clear, "why-focused" messages.

## Memory & Evolution (KEY)
- **Philosophy**: Memory is the source of truth. Document everything to prevent forgetting.
- **Proactivity**: Update project memory files *immediately* after a change or discovery.

---
**Version**: 1.3 (Global Protocols)
