# claude-workflow

Sistema de memoria y workflows para Claude Code. Setup interactivo en 2 minutos.

## Instalación

```bash
npx diego31-10/claude-workflow
```

Funciona en: Windows (PowerShell/CMD), Mac (Bash/Zsh), Linux (Bash).

## Flujo

```
npx diego31-10/claude-workflow
  ↓
¿Configurar CLAUDE.md global? → [y/n]
  ↓
¿Configurar un proyecto? → [y/n] → da ruta
  ↓
✓ Listo. Abre terminal NUEVA y: cw help
```

## Qué crea

**CLAUDE.md global** (`~/.claude/CLAUDE.md`)
- Reglas personales para todos tus proyectos con Claude Code

**Por proyecto** en `~/.claude/projects/<hash>/memory/`
- `tech_architecture.md` — Stack, BD, patrones
- `project_state.md` — Tareas, roadmap
- `errors.md` — Bugs resueltos y prevención

**Comando `cw`**
- Instalado en PATH automáticamente
- Comandos: `cw init`, `cw status`, `cw update`, `cw help`

## Compatibilidad

| Shell | Status |
|-------|--------|
| PowerShell (Windows) | ✓ |
| CMD (Windows) | ✓ |
| Git Bash (Windows) | ✓ |
| Bash (Linux) | ✓ |
| Zsh (Mac) | ✓ |

## Requisitos

- Node.js >= 18.0.0
- NPM (viene con Node.js)

## Licencia

MIT
