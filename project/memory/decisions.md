---
name: Architectural Decisions (ADR)
description: Record of important technical decisions and their rationale.
type: reference
---

# Architectural Decisions

## Philosophy
We record decisions here to avoid "circular debates" and remember the constraints of the past. 

**Format**:
- **Decision**: What was decided.
- **Context**: Why was this relevant?
- **Rationale**: Why did we choose this over alternatives?
- **Consequences**: What does this imply for the future?

---

## [Date] - Project Memory Structure
- **Decision**: Use a separate `memory/` folder for technical context.
- **Context**: Need to keep the root clean while maintaining deep context.
- **Rationale**: CLAUDE.md is for rules/entry points; `memory/` is for persistent technical knowledge.
- **Consequences**: Claude must always check `memory/` for deep technical info.

---
**Last Updated**: 2026-04-12
