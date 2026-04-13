#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import os from 'os';
import { execSync, spawnSync } from 'child_process';
import readline from 'readline';

// ─── Config ───────────────────────────────────────────────────────
const REPO_URL = 'https://github.com/Diego31-10/claude-workflow.git';
const INSTALL_DIR = path.join(os.homedir(), '.claude-workflow');
const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const BIN_DIR = path.join(os.homedir(), '.local', 'bin');
const CW_VERSION = '2.0.0';

// ─── Colores ──────────────────────────────────────────────────────
const colors = {
  GREEN: '\x1b[0;32m',
  BLUE: '\x1b[0;34m',
  YELLOW: '\x1b[1;33m',
  RED: '\x1b[0;31m',
  BOLD: '\x1b[1m',
  RESET: '\x1b[0m',
};

// ─── Helper Functions ──────────────────────────────────────────────
/**
 * @param {string} msg
 */
const info = (msg) => console.log(`${colors.BLUE}→${colors.RESET} ${msg}`);

/**
 * @param {string} msg
 */
const success = (msg) => console.log(`${colors.GREEN}✓${colors.RESET} ${msg}`);

/**
 * @param {string} msg
 */
const warn = (msg) => console.log(`${colors.YELLOW}!${colors.RESET} ${msg}`);

/**
 * @param {string} msg
 */
const error = (msg) => {
  console.error(`${colors.RED}✗${colors.RESET} ${msg}`);
  process.exit(1);
};

/**
 * @param {string} msg
 */
const header = (msg) => console.log(`\n${colors.BOLD}${msg}${colors.RESET}`);

/**
 * @param {string} msg
 */
const ask = (msg) => process.stdout.write(`${colors.BLUE}?${colors.RESET} ${msg}`);

// ─── Detectar OS ──────────────────────────────────────────────────
/**
 * @returns {'windows' | 'mac' | 'linux' | 'unknown'}
 */
function detectOS() {
  const platform = os.platform();
  if (platform === 'win32') return 'windows';
  if (platform === 'darwin') return 'mac';
  if (platform === 'linux') return 'linux';
  return 'unknown';
}

const OS = detectOS();

// ─── Función: leer respuesta con readline ──────────────────────────
/**
 * @returns {readline.Interface}
 */
function createReadlineInterface() {
  return readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
}

/**
 * @param {string} prompt
 * @param {'y' | 'n'} defaultAnswer
 * @returns {Promise<boolean>}
 */
async function confirm(prompt, defaultAnswer = 'n') {
  const rl = createReadlineInterface();
  const hint = defaultAnswer === 'y' ? '[Y/n]' : '[y/N]';

  return new Promise((resolve) => {
    ask(`${prompt} ${hint} `);
    rl.once('line', (reply) => {
      rl.close();
      const answer = reply.trim().toLowerCase() || defaultAnswer;
      resolve(answer === 'y');
    });
  });
}

/**
 * @returns {Promise<string>}
 */
async function readProjectPath() {
  const rl = createReadlineInterface();

  return new Promise((resolve) => {
    ask('Ruta del proyecto (absoluta, ej: /home/user/myapp o C:/Users/user/myapp): ');
    rl.once('line', (reply) => {
      rl.close();
      // Normalizar: eliminar trailing slash
      const normalized = reply.trim().replace(/[\/\\]$/, '');
      resolve(normalized);
    });
  });
}

// ─── Función: compute hash igual que cw.sh ────────────────────────
/**
 * @param {string} absPath
 * @returns {string}
 */
function computeHashForPath(absPath) {
  let normalized = absPath;

  // Normalizar separadores
  normalized = normalized.replace(/\\/g, '/');

  // Manejo de rutas WSL (/mnt/c/...)
  if (normalized.startsWith('/mnt/')) {
    normalized = normalized.substring(5);
    const drive = normalized[0].toUpperCase();
    normalized = `${drive}--${normalized.substring(2)}`;
  }
  // Manejo de rutas Unix (/c/...) comunes en Git Bash
  else if (/^\/[a-zA-Z]\//.test(normalized)) {
    const drive = normalized[1].toUpperCase();
    normalized = `${drive}--${normalized.substring(3)}`;
  }
  // Manejo de rutas Windows nativas (C:/... o C:\...)
  else if (/^[A-Za-z]:/.test(normalized)) {
    const drive = normalized[0].toUpperCase();
    normalized = `${drive}--${normalized.substring(3)}`;
  }
  // Manejo de rutas Unix absolutas (/)
  else if (normalized.startsWith('/')) {
    normalized = normalized.substring(1);
  }

  // Convertir separadores a guiones y simplificar múltiples guiones
  let hashed = normalized.replace(/[\/\\]/g, '-').replace(/-{2,}/g, '--');

  return hashed;
}

// ─── Función: copiar archivo sin sobrescribir ──────────────────────
/**
 * @param {string} src
 * @param {string} dst
 * @param {boolean} force
 */
function copyIfNeeded(src, dst, force = false) {
  if (fs.existsSync(dst) && !force) {
    warn(`  Ya existe (sin cambios): ${path.basename(dst)}`);
  } else {
    fs.copyFileSync(src, dst);
    success(`  Copiado: ${path.basename(dst)}`);
  }
}

// ─── Función: ensure directory exists ──────────────────────────────
/**
 * @param {string} dirPath
 */
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

// ─── Función: instalar comando cw ─────────────────────────────────
function installCwCommand() {
  ensureDir(BIN_DIR);
  const cwLink = path.join(BIN_DIR, 'cw');

  // Eliminar symlink/archivo previo
  try {
    if (fs.existsSync(cwLink)) {
      fs.unlinkSync(cwLink);
    }
  } catch (e) {
    // silenciar errores
  }

  // En Windows: crear cw.bat para PowerShell/CMD
  if (OS === 'windows') {
    const batPath = path.join(BIN_DIR, 'cw.bat');
    const winScript = path.join(INSTALL_DIR, 'cw.sh').replace(/\//g, '\\');
    const batContent = `@echo off\r\nbash "${winScript}" %*\r\n`;
    fs.writeFileSync(batPath, batContent);
    success('Wrapper cw.bat creado para PowerShell/CMD');
  } else {
    // En Unix: crear symlink o copiar
    try {
      fs.symlinkSync(path.join(INSTALL_DIR, 'cw.sh'), cwLink);
      success("Comando 'cw' instalado (symlink) en ~/.local/bin/");
    } catch {
      fs.copyFileSync(path.join(INSTALL_DIR, 'cw.sh'), cwLink);
      warn('Symlink no disponible — se copió cw.sh directamente');
    }
    try {
      fs.chmodSync(path.join(INSTALL_DIR, 'cw.sh'), 0o755);
    } catch {
      // silenciar
    }
  }

  // Agregar BIN_DIR al PATH de shells Unix
  addToPath(path.join(os.homedir(), '.bashrc'));
  addToPath(path.join(os.homedir(), '.bash_profile'));
  const zshrc = path.join(os.homedir(), '.zshrc');
  if (fs.existsSync(zshrc)) {
    addToPath(zshrc);
  }

  // En Windows: agregar al PATH del sistema
  if (OS === 'windows') {
    const winBin = BIN_DIR.replace(/\//g, '\\');
    try {
      // Intentar agregar al PATH via PowerShell
      const psCommand = `
        $bin = '${winBin}'
        $current = [Environment]::GetEnvironmentVariable('PATH', 'User')
        if ($current -notlike "*$bin*") {
          [Environment]::SetEnvironmentVariable('PATH', $current + ';' + $bin, 'User')
          exit 0
        }
        exit 1
      `;
      execSync(`powershell.exe -NoProfile -Command "${psCommand.replace(/"/g, '\\"')}"`, {
        stdio: 'ignore',
      });
      success('PATH agregado a Windows (abre una terminal nueva para que funcione)');
    } catch {
      warn('No se pudo actualizar PATH. Reinicia la terminal o agrega manualmente:');
      warn(`  Ruta: ${winBin}`);
    }
  }
}

/**
 * @param {string} rcPath
 */
function addToPath(rcPath) {
  const line = 'export PATH="$HOME/.local/bin:$PATH"';
  try {
    if (!fs.existsSync(rcPath)) {
      return;
    }
    const content = fs.readFileSync(rcPath, 'utf-8');
    if (!content.includes('.local/bin')) {
      fs.appendFileSync(rcPath, `\n\n# claude-workflow\n${line}\n`);
      info(`  PATH agregado en ${rcPath}`);
    }
  } catch {
    // silenciar
  }
}

// ─── Función: clonar/actualizar repo ──────────────────────────────
function setupRepository() {
  try {
    execSync('git --version', { stdio: 'ignore' });
  } catch {
    error('git no está instalado.');
  }

  if (fs.existsSync(INSTALL_DIR)) {
    info(`Actualizando repo en ${INSTALL_DIR}...`);
    try {
      execSync(`git -C "${INSTALL_DIR}" pull origin main --quiet`);
      success('Repo actualizado');
    } catch {
      warn('No se pudo actualizar el repo, continuando...');
    }
  } else {
    info(`Clonando repo en ${INSTALL_DIR}...`);
    try {
      execSync(`git clone "${REPO_URL}" "${INSTALL_DIR}" --quiet`);
      success('Repo clonado');
    } catch {
      error('No se pudo clonar el repositorio.');
    }
  }
}

// ─── Función: setup global CLAUDE.md ────────────────────────────────
/**
 * @returns {Promise<boolean>}
 */
async function setupGlobalClaude() {
  header('2/4  CLAUDE.md global (~/.claude/CLAUDE.md)');
  console.log('  Configura tus reglas personales para Claude Code.');
  console.log('  Aplica a TODOS tus proyectos.');
  console.log('');

  if (!(await confirm('¿Configurar CLAUDE.md global?', 'y'))) {
    info('CLAUDE.md global omitida');
    return false;
  }

  ensureDir(CLAUDE_DIR);
  const globalClaudePath = path.join(INSTALL_DIR, 'global', 'CLAUDE.md');
  const destPath = path.join(CLAUDE_DIR, 'CLAUDE.md');

  if (fs.existsSync(globalClaudePath)) {
    copyIfNeeded(globalClaudePath, destPath);
    success('CLAUDE.md global lista');
  } else {
    warn('No se encontró la plantilla global/CLAUDE.md');
  }

  return true;
}

// ─── Función: setup proyecto ──────────────────────────────────────
/**
 * @returns {Promise<{path: string, hash: string} | null>}
 */
async function setupProject() {
  header('3/4  Configurar proyecto');
  console.log('  Crea CLAUDE.md en el proyecto + memoria en ~/.claude/projects/');
  console.log('');

  if (!(await confirm('¿Configurar un proyecto?', 'y'))) {
    return null;
  }

  let projectPath = '';
  while (true) {
    projectPath = await readProjectPath();
    if (!projectPath) {
      warn('La ruta no puede estar vacía.');
      continue;
    }
    if (!fs.existsSync(projectPath)) {
      warn(`El directorio '${projectPath}' no existe.`);
      if (!(await confirm('¿Usar esa ruta de todas formas?', 'n'))) {
        continue;
      }
    }
    break;
  }

  const projectHash = computeHashForPath(projectPath);
  const projectMemDir = path.join(CLAUDE_DIR, 'projects', projectHash, 'memory');

  info(`  Ruta: ${projectPath}`);
  info(`  Hash: ${projectHash}`);
  info(`  Memory dir: ${projectMemDir}`);

  return { path: projectPath, hash: projectHash };
}

// ─── Función: crear CLAUDE.md del proyecto + memory ─────────────────
/**
 * @param {{path: string, hash: string}} projectInfo
 */
function setupProjectFiles(projectInfo) {
  const { path: projectPath, hash: projectHash } = projectInfo;
  const claudeDest = path.join(projectPath, 'CLAUDE.md');
  const projectMemDir = path.join(CLAUDE_DIR, 'projects', projectHash, 'memory');

  // CLAUDE.md en el proyecto
  const templatePath = path.join(INSTALL_DIR, 'templates', 'CLAUDE.md');
  if (fs.existsSync(claudeDest)) {
    warn(`  CLAUDE.md ya existe en ${projectPath} — sin cambios`);
  } else if (fs.existsSync(templatePath)) {
    fs.copyFileSync(templatePath, claudeDest);
    success(`CLAUDE.md creado en ${projectPath}`);
  }

  // Memory dir
  ensureDir(projectMemDir);

  // Copiar templates de memory
  const memoryTemplatesDir = path.join(INSTALL_DIR, 'templates', 'memory');
  if (fs.existsSync(memoryTemplatesDir)) {
    const templates = fs.readdirSync(memoryTemplatesDir);
    for (const file of templates) {
      const src = path.join(memoryTemplatesDir, file);
      const dst = path.join(projectMemDir, file);
      copyIfNeeded(src, dst);
    }
  }

  // settings.json del proyecto
  const localSettings = path.join(CLAUDE_DIR, 'projects', projectHash, 'settings.json');
  if (!fs.existsSync(localSettings)) {
    ensureDir(path.dirname(localSettings));
    const settingsContent = {
      autoMemoryEnabled: true,
      autoMemoryDirectory: `~/.claude/projects/${projectHash}/memory`,
    };
    fs.writeFileSync(localSettings, JSON.stringify(settingsContent, null, 2));
    success('settings.json creado');
  } else {
    info('  settings.json ya existe');
  }

  success('Proyecto configurado');
}

// ═══════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════

async function main() {
  console.clear();
  console.log('');
  console.log(`${colors.BOLD}  claude-workflow onboarding v${CW_VERSION}${colors.RESET}`);
  console.log('  ────────────────────────────────────────');
  console.log('  Sistema de memoria y workflows para Claude Code');
  console.log('');

  // 1. Setup repositorio
  header('1/5  Repositorio');
  setupRepository();

  // 2. Setup global CLAUDE.md
  const setupGlobal = await setupGlobalClaude();

  // 3. Setup proyecto
  const projectInfo = await setupProject();

  // 4. Crear archivos del proyecto
  if (projectInfo) {
    setupProjectFiles(projectInfo);
  }

  // 5. Instalar comando cw
  header('4/4  Instalación del comando cw');
  installCwCommand();

  // Resumen
  console.log('');
  console.log('  ─────────────────────────────────────────────');
  success('Instalación completa.');
  console.log('');

  if (setupGlobal) {
    console.log('  ✓ CLAUDE.md global instalado en:');
    console.log('    ~/.claude/CLAUDE.md');
  }

  if (projectInfo) {
    console.log('  ✓ Proyecto configurado:');
    console.log(`    CLAUDE.md en: ${projectInfo.path}`);
    console.log(
      `    Memory en:    ~/.claude/projects/${projectInfo.hash}/memory/`,
    );
  }

  console.log('');
  console.log('  Próximos pasos:');
  console.log('    1. Abre una terminal NUEVA');
  console.log('    2. Corre: cw help');
  console.log('    3. Abre Claude Code en tu proyecto');
  console.log('');
  console.log('  Para otros proyectos:');
  console.log('    cd mi-proyecto && cw init');
  console.log('  ─────────────────────────────────────────────');
  console.log('');

  process.exit(0);
}

main().catch((err) => {
  error(`Error: ${err.message}`);
});
