# CLAUDE.md

Config de trabajo para Claude Code. Todo se basa en memoria.

**Memoria global**: Lee `~/.claude/memory/MEMORY.md` — índice de contexto personal.
**Memoria proyecto**: Lee `memory/MEMORY.md` del proyecto actual — contexto técnico.
**Evolución**: Actualiza proactivamente la memoria cada sesión. ESO ES CLAVE.
**Context**: Referencia archivo leído en lugar de releer (ahorro de tokens).

---

## Principios

- Lee antes de escribir
- Edita secciones, no archivos completos
- Valida antes de finalizar
- Sin formalismo
- Siempre con foco en memory
- Usuario > CLAUDE.md

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
- `tech_architecture.md` — Si descubres patrón nuevo: agrégalo
- `superpowers_workflows.md` — Si descubres workflow útil nuevo
- `project_state.md` — Si estado de tareas cambia
- `user_profile.md` — Si aprendes algo nuevo del usuario

**Resultado**: Próxima sesión Claude es más inteligente. Memoria evoluciona, no estanca.

---

**Versión**: 1.0 (Agnóstico, cross-project)
