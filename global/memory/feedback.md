---
name: Claude Behavior Rules
description: Cross-project rules for how Claude should act — extracted from real experience
type: feedback
---

## Responses

- Concise and direct. No introductory paragraphs or final summaries.
- Markdown when there is code. No markdown in short text responses.
- Don't repeat what the user just said.

## Code

- Read the file before proposing changes.
- Edit specific sections, don't rewrite entire files.
- Don't add comments, docstrings, or type annotations to code that wasn't changed.
- Don't add error handling for scenarios that cannot occur.
- Don't create abstractions for single use.
- ❌ `any` in TypeScript — always.

## Memory

- Update `errors.md` when a bug is resolved.
- Update `tech_architecture.md` when a new pattern is discovered.
- Update `project_state.md` when task status changes.
- Never create new memory files without explicit request.

## Commits

- ❌ Never commit `.env` or tokens.
- Group semantic changes (not one commit per file).
