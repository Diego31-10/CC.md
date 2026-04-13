---
name: Superpowers Workflows
description: Integrated workflows for feature development, bugs, cleanup and review
type: reference
---

# Superpowers Workflows

## Feature Development

```
/brainstorm → Explore intent, requirements, design
  ↓
/write-plan → Clear structure, atomic tasks
  ↓
git worktree add → Isolation
  ↓
/subagent-driven-development → Execute (Haiku/Sonnet optimized)
  ↓
/verification → Grep + tsc + eslint
  ↓
Cherry-pick to main
  ↓
/requesting-code-review → Validation
  ↓
/finishing-branch → Merge decision
```

**Tokens**: 40% savings (Haiku mechanics, Sonnet logic)

---

## Bug Fixing

```
/systematic-debugging → Diagnose root cause
  ↓
Fix in worktree
  ↓
/verification → Confirm fixed
  ↓
PR → Merge
```

**Key**: Document cause in errors.md

---

## Batch Cleanup (Refactoring)

```
/write-plan → Divide into tasks
  ↓
git worktree add → Isolation
  ↓
/subagent-driven-development → Haiku (mechanics) + Sonnet (complex batch)
  ↓
/verification → Full validation
  ↓
Cherry-pick → Sync to main
```

---

## Code Review

```
Feature completed
  ↓
/requesting-code-review → Spec + quality validation
  ↓
Issues found?
  ├─ Yes → Fix + re-review
  └─ No → /finishing-branch → Merge
```

---

## Model Optimization

| Task | Model | Reason |
|------|-------|--------|
| ESLint, TypeScript | Haiku | Pure mechanics |
| Docs generation | Haiku | Copy writing |
| Batch cleanup | Sonnet | Analysis + context |
| Feature impl | Sonnet | Complex logic |
| Architecture | Sonnet | Decisions |

**Rule**: If mechanics → Haiku. If analysis required → Sonnet.

---

**Last Updated**: (update each session)
