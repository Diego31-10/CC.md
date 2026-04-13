# claude-workflow

Sistema de memoria y workflows para Claude Code. Onboarding interactivo en 2 minutos.

## Setup (nueva PC)

```bash
curl -fsSL https://raw.githubusercontent.com/Diego31-10/claude-workflow/main/install.sh | bash
```

El onboarding te pregunta qué configurar:
- ✓ Memoria global (`~/.claude/`) — aplica a todos tus proyectos
- ✓ Memoria de proyecto — indicas la ruta, se configura automáticamente
- ✓ Template de memoria (full o minimal)
- ✓ Comando `cw` instalado al final

## Comandos disponibles

| Comando | Qué hace |
|---------|----------|
| `cw init` | Inicializa memoria Claude para el proyecto actual |
| `cw onboard` | Re-ejecuta el onboarding interactivo |
| `cw status` | Muestra estado de memoria global y del proyecto |
| `cw update` | Actualiza templates desde GitHub |
| `cw help` | Muestra esta ayuda |

## Compatibilidad

| Shell | Funciona |
|-------|----------|
| Bash (Linux/Mac) | ✓ |
| Git Bash (Windows) | ✓ |
| PowerShell (Windows) | ✓ (via cw.bat) |
| CMD (Windows) | ✓ (via cw.bat) |

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
