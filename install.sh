#!/usr/bin/env bash
set -euo pipefail

# ─── Configuración ────────────────────────────────────────────────
REPO_URL="https://github.com/Diego31-10/claude-workflow.git"
INSTALL_DIR="${HOME}/.claude-workflow"
CLAUDE_DIR="${HOME}/.claude"
BIN_DIR="${HOME}/.local/bin"

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

# ─── Verificar dependencias ───────────────────────────────────────
command -v git >/dev/null 2>&1 || error "git no está instalado. Instálalo primero."

echo ""
echo "  claude-workflow installer"
echo "  ─────────────────────────────"
echo ""

# ─── 1. Clonar/actualizar el repo ─────────────────────────────────
if [[ -d "$INSTALL_DIR" ]]; then
  warn "Ya existe una instalación en ${INSTALL_DIR}"
  info "Actualizando..."
  cd "$INSTALL_DIR" && git pull origin main
  cd - > /dev/null
else
  info "Clonando claude-workflow en ${INSTALL_DIR}..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi
success "Repo disponible en ${INSTALL_DIR}"

# ─── 2. Copiar archivos globales a ~/.claude/ ─────────────────────
mkdir -p "${CLAUDE_DIR}/memory"

FORCE="${FORCE:-false}"

copy_if_needed() {
  local src="$1"
  local dst="$2"
  if [[ -f "$dst" && "$FORCE" != "true" ]]; then
    warn "  Ya existe (sin cambios): $(basename "$dst")"
  else
    cp "$src" "$dst"
    success "  Copiado: $(basename "$dst")"
  fi
}

info "Instalando archivos globales en ${CLAUDE_DIR}..."

copy_if_needed "${INSTALL_DIR}/global/CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md"

for f in "${INSTALL_DIR}/global/memory/"*.md; do
  copy_if_needed "$f" "${CLAUDE_DIR}/memory/$(basename "$f")"
done

success "Archivos globales instalados"

# ─── 3. Instalar comando cw ───────────────────────────────────────
mkdir -p "$BIN_DIR"

CW_LINK="${BIN_DIR}/cw"
if [[ -L "$CW_LINK" ]]; then
  rm "$CW_LINK"
fi

ln -s "${INSTALL_DIR}/cw.sh" "$CW_LINK"
chmod +x "${INSTALL_DIR}/cw.sh"
success "Comando 'cw' instalado en ${BIN_DIR}"

# ─── 4. Agregar BIN_DIR al PATH si no está ────────────────────────
add_to_path() {
  local shell_rc="$1"
  local path_line='export PATH="$HOME/.local/bin:$PATH"'

  if [[ -f "$shell_rc" ]] && ! grep -q '.local/bin' "$shell_rc" 2>/dev/null; then
    echo "" >> "$shell_rc"
    echo "# claude-workflow" >> "$shell_rc"
    echo "$path_line" >> "$shell_rc"
    info "  PATH actualizado en ${shell_rc}"
  fi
}

if [[ -f "${HOME}/.zshrc" ]]; then
  add_to_path "${HOME}/.zshrc"
elif [[ -f "${HOME}/.bashrc" ]]; then
  add_to_path "${HOME}/.bashrc"
fi

# ─── Resumen ──────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────"
success "Instalación completa."
echo ""
echo "  Para activar 'cw' en esta sesión:"
echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "  Próximos pasos:"
echo "    1. Edita ~/.claude/memory/user_profile.md con tu info"
echo "    2. Ve a cualquier proyecto: cd mi-proyecto"
echo "    3. Ejecuta: cw init"
echo "  ─────────────────────────────────────────────"
echo ""
