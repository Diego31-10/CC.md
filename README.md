# claude-workflow

Sistema de memoria y workflows para Claude Code. Bootstrappea tu setup en cualquier PC en 2 minutos.

## Setup inicial (nueva PC)

```bash
curl -fsSL https://raw.githubusercontent.com/Diego31-10/claude-workflow/main/install.sh | bash
```

## Inicializar proyecto nuevo

```bash
cd tu-proyecto
cw init
```

## Comandos disponibles

| Comando | Qué hace |
|---------|----------|
| `cw init` | Inicializa memoria Claude para el proyecto actual |
| `cw status` | Muestra estado de memoria global y del proyecto |
| `cw update` | Actualiza templates desde GitHub |
| `cw help` | Muestra ayuda |

## Estructura instalada

**Global** (`~/.claude/`):
- `CLAUDE.md` — Config personal cross-project
- `memory/user_profile.md` — Tu perfil como dev
- `memory/feedback.md` — Reglas de comportamiento Claude
- `memory/superpowers_workflows.md` — Workflows feature/bug/cleanup

**Por proyecto** (`~/.claude/projects/<hash>/memory/`):
- `tech_architecture.md` — Stack, BD, patrones
- `project_state.md` — Tareas, roadmap
- `errors.md` — Bugs resueltos y prevención

## Flujo nueva PC

```
curl install.sh | bash
  ↓
Editar ~/.claude/memory/user_profile.md con tu info
  ↓
cd mi-proyecto && cw init
  ↓
Claude Code listo con memoria completa
```
