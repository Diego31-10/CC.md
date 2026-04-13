# CLAUDE.md

Config de trabajo para Claude en este proyecto.

**Memoria global**: Lee `~/.claude/memory/MEMORY.md` — contexto personal.
**Memoria local**: Lee `memory/MEMORY.md` — contexto técnico de este proyecto.
**Evolución**: Actualiza proactivamente TODA la memory cada sesión.

---

## Principios

- Lee antes de escribir
- Edita secciones, no completo
- Valida antes de finalizar
- Sin formalismo
- Siempre con foco en memory

---

## Reglas No-Negociables

- ❌ `.env` o tokens en commits
- ❌ `any` en TypeScript
- Nunca crear archivos nuevos en `docs/` sin pedido explícito
- Nunca crear nuevos memory files sin pedido explícito — actualizar existing siempre

---

## Proactividad en Memory (CLAVE)

**Cada sesión, actualiza proactivamente**:

- `errors.md` — Cuando encuentres error: causa + solución + prevención
- `tech_architecture.md` — Si descubres patrón nuevo o refactoring: agrégalo
- `project_state.md` — Si estado de tareas cambia

---

**Versión**: 1.0
