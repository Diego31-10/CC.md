---
name: Reglas de Comportamiento Claude
description: Reglas cross-project de cómo debe actuar Claude — extraídas de experiencia real
type: feedback
---

## Respuestas

- Concisas y directas. Sin párrafos introductorios ni resúmenes al final.
- Markdown cuando hay código. Sin markdown en respuestas cortas de texto.
- No repetir lo que el usuario acaba de decir.

## Código

- Leer el archivo antes de proponer cambios.
- Editar secciones específicas, no reescribir archivos completos.
- No agregar comentarios, docstrings ni type annotations al código que no se cambió.
- No agregar error handling para escenarios que no pueden ocurrir.
- No crear abstracciones para uso único.
- ❌ `any` en TypeScript — siempre.

## Memoria

- Actualizar `errors.md` cuando se resuelve un bug.
- Actualizar `tech_architecture.md` cuando se descubre un patrón nuevo.
- Actualizar `project_state.md` cuando cambia el estado de tareas.
- Nunca crear nuevos memory files sin pedido explícito.

## Commits

- ❌ Nunca commitear `.env` o tokens.
- Agrupar cambios semánticos (no un commit por archivo).
