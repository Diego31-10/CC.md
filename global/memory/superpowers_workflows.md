---
name: Superpowers Workflows
description: Workflows integrados para feature development, bugs, cleanup y review
type: reference
---

# Superpowers Workflows

## Feature Development

```
/brainstorm → Explora intent, requirements, design
  ↓
/write-plan → Estructura clara, tasks atómicas
  ↓
git worktree add → Aislamiento
  ↓
/subagent-driven-development → Ejecuta (Haiku/Sonnet optimizado)
  ↓
/verification → Grep + tsc + eslint
  ↓
Cherry-pick a main
  ↓
/requesting-code-review → Validación
  ↓
/finishing-branch → Decisión merge
```

**Tokens**: 40% ahorro (Haiku mecánica, Sonnet lógica)

---

## Bug Fixing

```
/systematic-debugging → Diagnosticar causa raíz
  ↓
Fix en worktree
  ↓
/verification → Confirmar arreglado
  ↓
PR → Merge
```

**Clave**: Documentar causa en errors.md

---

## Batch Cleanup (Refactoring)

```
/write-plan → Divide en tasks
  ↓
git worktree add → Aislamiento
  ↓
/subagent-driven-development → Haiku (mecánica) + Sonnet (batch complex)
  ↓
/verification → Validación completa
  ↓
Cherry-pick → Sincronizar a main
```

---

## Code Review

```
Feature completada
  ↓
/requesting-code-review → Validación spec + quality
  ↓
Issues encontrados?
  ├─ Sí → Fix + re-review
  └─ No → /finishing-branch → Merge
```

---

## Model Optimization

| Tarea | Modelo | Razón |
|-------|--------|-------|
| ESLint, TypeScript | Haiku | Mecánica pura |
| Docs generation | Haiku | Copy writing |
| Batch cleanup | Sonnet | Análisis + contexto |
| Feature impl | Sonnet | Lógica compleja |
| Architecture | Sonnet | Decisiones |

**Regla**: Si es mecánica → Haiku. Si requiere análisis → Sonnet.

---

**Last Updated**: (actualizar cada sesión)
