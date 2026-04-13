#!/usr/bin/env bash
set -euo pipefail

# ─── Config ───────────────────────────────────────────────────────
REPO_URL="https://github.com/Diego31-10/claude-workflow.git"
INSTALL_DIR="${HOME}/.claude-workflow"
CLAUDE_DIR="${HOME}/.claude"
BIN_DIR="${HOME}/.local/bin"
CW_VERSION="2.0.0"

# ─── Colores ──────────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${BLUE}→${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }
warn()    { echo -e "${YELLOW}!${RESET} $1"; }
error()   { echo -e "${RED}✗${RESET} $1"; exit 1; }
header()  { echo -e "\n${BOLD}$1${RESET}"; }
ask()     { echo -e "${BLUE}?${RESET} $1"; }

# ─── Detectar entorno ─────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    Darwin)               echo "mac" ;;
    Linux)                echo "linux" ;;
    *)                    echo "unknown" ;;
  esac
}
OS="$(detect_os)"

# ─── Función: leer respuesta y/n ──────────────────────────────────
confirm() {
  local prompt="$1"
  local default="${2:-n}"
  local hint
  [[ "$default" == "y" ]] && hint="[Y/n]" || hint="[y/N]"
  ask "$prompt $hint "
  read -r reply
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ─── Función: leer ruta de proyecto ───────────────────────────────
read_project_path() {
  ask "Ruta del proyecto (absoluta, ej: /home/user/myapp o C:/Users/user/myapp): "
  read -r project_path
  # Normalizar: eliminar trailing slash
  project_path="${project_path%/}"
  echo "$project_path"
}

# ─── Función: compute hash igual que cw.sh ────────────────────────
compute_hash_for_path() {
  local abs_path="$1"
  if [[ "$abs_path" == /mnt/* ]]; then
    abs_path="${abs_path#/mnt/}"
    local drive="${abs_path:0:1}"
    abs_path="${drive^^}--${abs_path:2}"
  elif [[ "$abs_path" == /[a-zA-Z]/* ]]; then
    local drive="${abs_path:1:1}"
    abs_path="${drive^^}--${abs_path:3}"
  elif [[ "$abs_path" == [A-Za-z]:* ]]; then
    # Ruta Windows nativa: C:/Users/... o C:\Users\...
    local drive="${abs_path:0:1}"
    abs_path="${drive^^}--${abs_path:3}"
  elif [[ "$abs_path" == /* ]]; then
    abs_path="${abs_path:1}"
  fi
  echo "$abs_path" | sed 's|[/\\]|-|g' | sed 's|-\{2,\}|--|g'
}

# ─── Función: copiar archivo sin sobrescribir (a menos que FORCE) ──
copy_if_needed() {
  local src="$1" dst="$2"
  if [[ -f "$dst" && "${FORCE:-false}" != "true" ]]; then
    warn "  Ya existe (sin cambios): $(basename "$dst")"
  else
    cp "$src" "$dst"
    success "  Copiado: $(basename "$dst")"
  fi
}

# ─── Función: instalar comando cw ─────────────────────────────────
install_cw_command() {
  mkdir -p "$BIN_DIR"
  local cw_link="${BIN_DIR}/cw"

  # Eliminar symlink/archivo previo
  [[ -L "$cw_link" || -f "$cw_link" ]] && rm -f "$cw_link"

  # Intentar symlink, si falla copiar
  if ln -s "${INSTALL_DIR}/cw.sh" "$cw_link" 2>/dev/null; then
    success "Comando 'cw' instalado (symlink) en ${BIN_DIR}"
  else
    cp "${INSTALL_DIR}/cw.sh" "$cw_link"
    warn "Symlink falló — se copió cw.sh directamente. Corre 'cw update' tras actualizar el repo."
  fi
  chmod +x "${INSTALL_DIR}/cw.sh" 2>/dev/null || true

  # En Windows: crear cw.bat para PowerShell/CMD
  if [[ "$OS" == "windows" ]]; then
    local bat_path="${BIN_DIR}/cw.bat"
    # cygpath convierte /home/user/.claude-workflow a ruta Windows
    local win_script
    win_script="$(cygpath -w "${INSTALL_DIR}/cw.sh" 2>/dev/null || echo "${INSTALL_DIR}/cw.sh")"
    printf '@echo off\r\nbash "%s" %%*\r\n' "$win_script" > "$bat_path"
    success "Wrapper cw.bat creado para PowerShell/CMD"
  fi

  # Agregar BIN_DIR al PATH del shell si no está
  add_to_path "${HOME}/.bashrc"
  add_to_path "${HOME}/.bash_profile"
  [[ -f "${HOME}/.zshrc" ]] && add_to_path "${HOME}/.zshrc"

  # En Windows: agregar al PATH de Windows vía PowerShell
  if [[ "$OS" == "windows" ]]; then
    local win_bin
    win_bin="$(cygpath -w "$BIN_DIR" 2>/dev/null || echo "$BIN_DIR")"
    powershell.exe -Command "
      \$current = [Environment]::GetEnvironmentVariable('PATH','User')
      if (\$current -notlike '*${win_bin}*') {
        [Environment]::SetEnvironmentVariable('PATH', \$current + ';${win_bin}', 'User')
        Write-Host 'PATH de Windows actualizado'
      }
    " 2>/dev/null && success "PATH de Windows actualizado para PowerShell" || \
      warn "No se pudo actualizar PATH de Windows. Agrega ${win_bin} manualmente."
  fi
}

add_to_path() {
  local rc="$1"
  local line='export PATH="$HOME/.local/bin:$PATH"'
  if [[ -f "$rc" ]] && ! grep -q '.local/bin' "$rc" 2>/dev/null; then
    { echo ""; echo "# claude-workflow"; echo "$line"; } >> "$rc"
    info "  PATH agregado en ${rc}"
  fi
}

# ═══════════════════════════════════════════════════════════════════
# ONBOARDING
# ═══════════════════════════════════════════════════════════════════

clear
echo ""
echo -e "${BOLD}  claude-workflow onboarding v${CW_VERSION}${RESET}"
echo "  ────────────────────────────────────────"
echo "  Sistema de memoria y workflows para Claude Code"
echo ""

# ─── 1. Clonar/actualizar repo ────────────────────────────────────
header "1/5  Repositorio"
command -v git >/dev/null 2>&1 || error "git no está instalado."

if [[ -d "$INSTALL_DIR" ]]; then
  info "Actualizando repo en ${INSTALL_DIR}..."
  git -C "$INSTALL_DIR" pull origin main --quiet
  success "Repo actualizado"
else
  info "Clonando repo en ${INSTALL_DIR}..."
  git clone "$REPO_URL" "$INSTALL_DIR" --quiet
  success "Repo clonado"
fi

# ─── 2. Memoria global ────────────────────────────────────────────
header "2/5  Memoria global (~/.claude/)"
echo "  Instala CLAUDE.md y perfiles en ~/.claude/"
echo "  Aplica a TODOS tus proyectos con Claude Code."
echo ""

SETUP_GLOBAL=false
if confirm "¿Configurar memoria global?" "y"; then
  SETUP_GLOBAL=true
  mkdir -p "${CLAUDE_DIR}/memory"
  copy_if_needed "${INSTALL_DIR}/global/CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md"
  for f in "${INSTALL_DIR}/global/memory/"*.md; do
    copy_if_needed "$f" "${CLAUDE_DIR}/memory/$(basename "$f")"
  done
  success "Memoria global lista"
else
  info "Memoria global omitida"
fi

# ─── 3. Memoria de proyecto ───────────────────────────────────────
header "3/5  Memoria de proyecto"
echo "  Crea archivos de memoria para un proyecto específico."
echo "  Se guardará en ~/.claude/projects/<hash>/memory/"
echo ""

SETUP_PROJECT=false
PROJECT_PATH=""
if confirm "¿Configurar memoria para un proyecto?" "y"; then
  SETUP_PROJECT=true

  while true; do
    PROJECT_PATH="$(read_project_path)"
    if [[ -z "$PROJECT_PATH" ]]; then
      warn "La ruta no puede estar vacía."
    elif [[ ! -d "$PROJECT_PATH" ]]; then
      warn "El directorio '${PROJECT_PATH}' no existe."
      if confirm "¿Usar esa ruta de todas formas?" "n"; then
        break
      fi
    else
      break
    fi
  done

  PROJECT_HASH="$(compute_hash_for_path "$PROJECT_PATH")"
  PROJECT_MEM_DIR="${CLAUDE_DIR}/projects/${PROJECT_HASH}/memory"
  info "  Hash: ${PROJECT_HASH}"
  info "  Memoria: ${PROJECT_MEM_DIR}"
fi

# ─── 4. Elegir template ───────────────────────────────────────────
if [[ "$SETUP_PROJECT" == "true" ]]; then
  header "4/5  Template de memoria"
  echo "  1) Full   — tech_architecture + project_state + errors (recomendado)"
  echo "  2) Minimal — solo project_state"
  echo ""
  ask "Elige template [1/2] (default: 1): "
  read -r tmpl_choice
  tmpl_choice="${tmpl_choice:-1}"

  mkdir -p "$PROJECT_MEM_DIR"

  case "$tmpl_choice" in
    2)
      copy_if_needed "${INSTALL_DIR}/templates/memory/project_state.md" "${PROJECT_MEM_DIR}/project_state.md"
      ;;
    *)
      for f in "${INSTALL_DIR}/templates/memory/"*.md; do
        copy_if_needed "$f" "${PROJECT_MEM_DIR}/$(basename "$f")"
      done
      ;;
  esac

  # settings.json del proyecto
  local_settings="${CLAUDE_DIR}/projects/${PROJECT_HASH}/settings.json"
  if [[ ! -f "$local_settings" ]]; then
    cat > "$local_settings" <<EOF
{
  "autoMemoryEnabled": true,
  "autoMemoryDirectory": "~/.claude/projects/${PROJECT_HASH}/memory"
}
EOF
    success "settings.json creado para el proyecto"
  else
    info "  settings.json ya existe — sin cambios"
  fi

  # CLAUDE.md en el proyecto
  claude_dest="${PROJECT_PATH}/CLAUDE.md"
  if [[ -f "$claude_dest" ]]; then
    warn "CLAUDE.md ya existe en ${PROJECT_PATH} — sin cambios"
  else
    cp "${INSTALL_DIR}/templates/CLAUDE.md" "$claude_dest"
    success "CLAUDE.md creado en ${PROJECT_PATH}"
  fi

  success "Memoria del proyecto lista"
else
  header "4/5  Template"
  info "Omitido (no se configuró proyecto)"
fi

# ─── 5. Instalar comando cw ───────────────────────────────────────
header "5/5  Comando cw"
install_cw_command

# ─── Resumen ──────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────"
success "Onboarding completo."
echo ""
echo "  Para usar 'cw' en esta sesión:"
echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
if [[ "$SETUP_GLOBAL" == "true" ]]; then
  echo "  Memoria global:"
  echo "    Edita ~/.claude/memory/user_profile.md con tu info"
fi
if [[ "$SETUP_PROJECT" == "true" ]]; then
  echo "  Proyecto: ${PROJECT_PATH}"
  echo "    Edita ${PROJECT_MEM_DIR}/tech_architecture.md con tu stack"
fi
echo ""
echo "  Próximos proyectos:"
echo "    cd mi-proyecto && cw init"
echo "  ─────────────────────────────────────────────"
echo ""
