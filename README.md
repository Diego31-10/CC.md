# claude-workflow

Sistema de memoria y workflows para Claude Code. Setup interactivo en 2 minutos.

## Setup

```bash
npx diego31-10/claude-workflow
```

O si lo prefieres desde bash:

```bash
```

El installer te pregunta qué configurar:
- ✓ **CLAUDE.md global** (`~/.claude/CLAUDE.md`) — reglas personales para todos tus proyectos
- ✓ **Proyecto** — crea CLAUDE.md en la carpeta + memory en `~/.claude/projects/<hash>/`
- ✓ **Comando `cw`** — instalado y agregado al PATH automáticamente

## Flujo

```
npx diego31-10/claude-workflow
  ↓
¿Configurar CLAUDE.md global? → [y/n]
  ↓
¿Configurar un proyecto? → [y/n] → da ruta
  ↓
✓ Listo. Abre una terminal NUEVA y: cw help
```

## Comandos disponibles

| Comando | Qué hace |
|---------|----------|
| `cw init` | Inicializa memoria para un proyecto (desde dentro del proyecto) |
| `cw onboard` | Re-ejecuta el onboarding interactivo |
| `cw status` | Muestra estado actual |
| `cw update` | Actualiza desde GitHub |
| `cw help` | Muestra ayuda |

## Compatibilidad

| Shell | Funciona |
|-------|----------|
| Git Bash (Windows) | ✓ |
| PowerShell (Windows) | ✓ (via cw.bat) |
| CMD (Windows) | ✓ (via cw.bat) |
| Bash (Linux/Mac) | ✓ |
| Zsh (Mac) | ✓ |

## Estructura después del setup

```
~/.claude/
├── CLAUDE.md (tu config personal)
└── projects/
    └── <hash-del-proyecto>/
        └── memory/
            ├── tech_architecture.md
            ├── project_state.md
            └── errors.md

mi-proyecto/
└── CLAUDE.md (config del proyecto)
```

## Solución de problemas

**`cw help` no funciona:**
- Abre una **terminal NUEVA** (el PATH se actualiza al abrir)
- Si aún no funciona en PowerShell, reinicia la PC

**Symlink no funcionó:**
- El script usa fallback a copia, funciona igual
- Corre `cw update` cuando actualices el repo
