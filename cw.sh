#!/usr/bin/env bash
set -euo pipefail

# ─── Configuración ────────────────────────────────────────────────
CW_REPO_DIR="${HOME}/.claude-workflow"
CW_GLOBAL_DIR="${HOME}/.claude"
CW_VERSION="1.0.0"

# ─── Colores ──────────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${BLUE}→${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }
warn()    { echo -e "${YELLOW}!${RESET} $1"; }
error()   { echo -e "${RED}✗${RESET} $1"; exit 1; }

# ─── Hash del proyecto ────────────────────────────────────────────
# Replica el algoritmo de Claude Code:
# /Users/diego/projects/myapp  → Users-diego-projects-myapp
# C:\Users\diego\Desktop\myapp → C--Users-diego-Desktop-myapp
compute_project_hash() {
  local abs_path
  abs_path="$(pwd)"

  if [[ "$abs_path" == /mnt/* ]]; then
    # WSL: /mnt/c/Users/diego/Desktop/myapp → C--Users-diego-Desktop-myapp
    abs_path="${abs_path#/mnt/}"
    local drive="${abs_path:0:1}"
    abs_path="${drive^^}--${abs_path:2}"
  elif [[ "$abs_path" == /[a-zA-Z]/* ]]; then
    # Git Bash en Windows: /c/Users/diego/Desktop/myapp → C--Users-diego-Desktop-myapp
    local drive="${abs_path:1:1}"
    abs_path="${drive^^}--${abs_path:3}"
  elif [[ "$abs_path" == /* ]]; then
    # Mac/Linux: /Users/diego/myapp → Users-diego-myapp
    abs_path="${abs_path:1}"
  fi

  # Reemplazar / y \ por -, colapsar múltiples -
  echo "$abs_path" | sed 's|[/\\]|-|g' | sed 's|-\{2,\}|--|g'
}

# ─── Subcomando: init ─────────────────────────────────────────────
cmd_init() {
  local project_hash
  project_hash="$(compute_project_hash)"
  local memory_dir="${CW_GLOBAL_DIR}/projects/${project_hash}/memory"

  echo ""
  info "Inicializando claude-workflow para este proyecto..."
  echo "  Path:  $(pwd)"
  echo "  Hash:  ${project_hash}"
  echo ""

  # 1. Crear directorio de memoria del proyecto
  if [[ -d "$memory_dir" ]]; then
    warn "La memoria del proyecto ya existe en: ${memory_dir}"
    read -r -p "  ¿Sobrescribir archivos existentes? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      info "Sin cambios. Usa 'cw status' para ver el estado actual."
      exit 0
    fi
  fi

  mkdir -p "$memory_dir"
  success "Directorio de memoria creado: ${memory_dir}"

  # 2. Copiar templates de memoria del proyecto
  local templates_dir="${CW_REPO_DIR}/templates/memory"
  if [[ ! -d "$templates_dir" ]]; then
    error "No se encontraron templates en ${templates_dir}. Ejecuta 'cw update'."
  fi

  for template in "${templates_dir}"/*.md; do
    local filename
    filename="$(basename "$template")"
    if [[ -f "${memory_dir}/${filename}" ]]; then
      warn "  Sobrescribiendo: ${filename}"
    else
      info "  Creando: ${filename}"
    fi
    cp "$template" "${memory_dir}/${filename}"
  done

  # 3. Crear settings.json del proyecto con autoMemoryDirectory
  local settings_file="${CW_GLOBAL_DIR}/projects/${project_hash}/settings.json"
  if [[ ! -f "$settings_file" ]]; then
    cat > "$settings_file" <<EOF
{
  "autoMemoryEnabled": true,
  "autoMemoryDirectory": "~/.claude/projects/${project_hash}/memory"
}
EOF
    success "settings.json creado para el proyecto"
  else
    info "  settings.json ya existe — no se sobrescribió."
  fi

  # 4. Copiar CLAUDE.md al proyecto (sin sobrescribir si ya existe)
  local claude_template="${CW_REPO_DIR}/templates/CLAUDE.md"
  local claude_dest
  claude_dest="$(pwd)/CLAUDE.md"

  if [[ -f "$claude_dest" ]]; then
    warn "CLAUDE.md ya existe en el proyecto — no se sobrescribió."
    warn "  Para reemplazarlo: cp ${claude_template} ./CLAUDE.md"
  else
    cp "$claude_template" "$claude_dest"
    success "CLAUDE.md creado en el proyecto"
  fi

  echo ""
  success "Proyecto inicializado correctamente."
  echo ""
  echo "  Próximos pasos:"
  echo "  1. Abre Claude Code en este directorio"
  echo "  2. Rellena tech_architecture.md con tu stack"
  echo "  3. Rellena project_state.md con tus tareas iniciales"
  echo ""
}

# ─── Subcomando: status ───────────────────────────────────────────
cmd_status() {
  echo ""
  echo "  claude-workflow v${CW_VERSION}"
  echo ""

  # Memoria global
  echo "  Memoria global (~/.claude/memory/):"
  local global_mem="${CW_GLOBAL_DIR}/memory"
  if [[ -d "$global_mem" ]]; then
    for f in "${global_mem}"/*.md; do
      [[ -f "$f" ]] && echo "     ✓ $(basename "$f")"
    done
  else
    echo "     ✗ No existe — ejecuta el install.sh"
  fi

  echo ""

  # CLAUDE.md global
  echo "  CLAUDE.md global (~/.claude/CLAUDE.md):"
  if [[ -f "${CW_GLOBAL_DIR}/CLAUDE.md" ]]; then
    echo "     ✓ Existe"
  else
    echo "     ✗ No existe — ejecuta el install.sh"
  fi

  echo ""

  # Memoria del proyecto actual
  local project_hash
  project_hash="$(compute_project_hash)"
  local memory_dir="${CW_GLOBAL_DIR}/projects/${project_hash}/memory"

  echo "  Memoria del proyecto ($(pwd)):"
  echo "     Hash: ${project_hash}"
  if [[ -d "$memory_dir" ]]; then
    for f in "${memory_dir}"/*.md; do
      [[ -f "$f" ]] && echo "     ✓ $(basename "$f")"
    done
  else
    echo "     ✗ No inicializado — ejecuta 'cw init'"
  fi

  echo ""

  # CLAUDE.md del proyecto
  echo "  CLAUDE.md del proyecto:"
  if [[ -f "$(pwd)/CLAUDE.md" ]]; then
    echo "     ✓ Existe"
  else
    echo "     ✗ No existe — ejecuta 'cw init'"
  fi

  echo ""
}

# ─── Subcomando: update ───────────────────────────────────────────
cmd_update() {
  info "Actualizando templates desde GitHub..."
  if [[ ! -d "$CW_REPO_DIR" ]]; then
    error "Repo no encontrado en ${CW_REPO_DIR}. Ejecuta el install.sh primero."
  fi

  cd "$CW_REPO_DIR"
  git pull origin main
  success "Templates actualizados a la última versión."
  echo ""
  warn "Nota: Los archivos de memoria existentes NO se sobrescriben."
  warn "      Solo afecta nuevos proyectos inicializados con 'cw init'."
  echo ""
}

# ─── Subcomando: onboard ─────────────────────────────────────────
cmd_onboard() {
  local onboard_script="${CW_REPO_DIR}/install.sh"
  if [[ ! -f "$onboard_script" ]]; then
    error "No se encontró install.sh en ${CW_REPO_DIR}. Ejecuta: curl -fsSL https://raw.githubusercontent.com/Diego31-10/claude-workflow/main/install.sh | bash"
  fi
  bash "$onboard_script"
}

# ─── Subcomando: help ─────────────────────────────────────────────
cmd_help() {
  echo ""
  echo "  cw — claude-workflow CLI v${CW_VERSION}"
  echo ""
  echo "  Comandos:"
  echo "    cw init      Inicializa memoria Claude para el proyecto actual"
  echo "    cw onboard   Re-ejecuta el onboarding interactivo"
  echo "    cw status    Muestra estado de memoria global y del proyecto"
  echo "    cw update    Actualiza templates desde GitHub"
  echo "    cw help      Muestra esta ayuda"
  echo ""
}

# ─── Router ───────────────────────────────────────────────────────
case "${1:-help}" in
  init)    cmd_init ;;
  status)  cmd_status ;;
  update)  cmd_update ;;
  onboard) cmd_onboard ;;
  help|--help|-h) cmd_help ;;
  *)
    error "Comando desconocido: '${1}'. Usa 'cw help'."
    ;;
esac
