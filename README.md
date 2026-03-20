# mi-config

> 🚀 Instalador multiplataforma para tu entorno de desarrollo: opencode, Neovim/LazyVim, Docker, y más.

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20WSL-blue.svg)](https://github.com/Andressc19/mi-config)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/Andressc19/mi-config?style=social)](https://github.com/Andressc19/mi-config/stargazers)

---

## ✨ ¿Qué incluye?

| Herramienta | Descripción |
|-------------|-------------|
| **opencode** | Asistente IA con memoria persistente (Engram), SDD skills, e integraciones MCP |
| **LazyVim** | Configuración opinionada de Neovim con tema Tokyo Night y 30+ plugins |
| **Docker Stack** | Docker, Colima, LazyDocker para gestión de contenedores |
| **Shell Setup** | Bash-it, Oh-My-Zsh, Oh-My-Posh para prompts modernos |
| **Dev Tools** | Homebrew, NVM, SDKMAN para gestión de versiones |

---

## ⚡ Instalación rápida

### Windows (PowerShell)

```powershell
# Opción 1: One-liner (PowerShell 7+)
irm https://raw.githubusercontent.com/Andressc19/mi-config/main/windows/install.ps1 | iex

# Opción 2: Manual
git clone https://github.com/Andressc19/mi-config.git
cd mi-config\windows
.\install.ps1 -All
```

### Linux / macOS / WSL

```bash
# Opción 1: One-liner
curl -fsSL https://raw.githubusercontent.com/Andressc19/mi-config/main/install.sh | bash -s -- --all

# Opción 2: Manual
git clone https://github.com/Andressc19/mi-config.git
cd mi-config
chmod +x install.sh
./install.sh --all
```

---

## 📋 Plataformas soportadas

| Plataforma | Estado | Instalador |
|-------------|--------|-------------|
| Windows Native | ✅ | `windows/install.ps1` |
| macOS | ✅ | `install.sh` (Bash) |
| Linux (Ubuntu/Debian/Fedora) | ✅ | `install.sh` (Bash) |
| WSL (Windows Subsystem for Linux) | ✅ | `install.sh` (Bash) |

---

## 🎯 Instalación selectiva

### Linux / macOS / WSL

```bash
# Solo opencode
./install.sh --opencode

# Solo Neovim
./install.sh --nvim

# Solo Docker
./install.sh --docker

# Multiple componentes
./install.sh --opencode --nvim --docker

# Preview (no ejecuta)
./install.sh --all --dry-run
```

### Windows (PowerShell)

```powershell
# Solo opencode
.\install.ps1 -Opencode

# Solo Neovim
.\install.ps1 -Nvim

# Multiple componentes
.\install.ps1 -Opencode -Nvim -Docker

# Preview (no ejecuta)
.\install.ps1 -All -DryRun
```

### Flags disponibles

| Flag | Descripción |
|------|-------------|
| `--all` / `-All` | Instalar todo |
| `--opencode` / `-Opencode` | opencode + Engram + skills |
| `--nvim` / `-Nvim` | Neovim + LazyVim |
| `--docker` / `-Docker` | Docker + LazyDocker |
| `--shell` / `-Shell` | Configuración de shell |
| `--devtools` / `-DevTools` | Git, Python, Node, etc |
| `--link` / `-Link` | Copiar/vincular configs |
| `--dry-run` / `-DryRun` | Preview sin ejecutar |
| `--help` / `-Help` | Mostrar ayuda |

---

## 🛠️ Requisitos

### Windows
- PowerShell 7+ (o 5.1)
- Git
- Un package manager: **winget**, **scoop**, o **chocolatey**

### Linux / macOS / WSL
- `curl` o `wget`
- `git`
- `bash` 4.0+

### macOS
- [Homebrew](https://brew.sh)

### WSL
- Docker Desktop para Windows (con integración WSL2)

---

## 💾 Backup de Engram

Engram es la memoria persistente de opencode. Para respaldarla:

### Linux / macOS / WSL

```bash
./scripts/backup-engram.sh -backup
./scripts/backup-engram.sh -list
./scripts/backup-engram.sh -stats
```

### Windows

```powershell
.\windows\scripts\backup-engram.ps1 -Backup
.\windows\scripts\backup-engram.ps1 -List
.\windows\scripts\backup-engram.ps1 -Stats
```

Los backups se guardan en:
- **Linux/WSL**: `~/engram-backups/`
- **Windows**: `%USERPROFILE%\engram-backups\`

---

## 📁 Estructura del proyecto

```
mi-config/
├── install.sh                    # Instalador principal (Bash)
├── scripts/
│   ├── lib-detect.sh             # Utilidades de detección
│   ├── install-opencode.sh       # opencode + Engram
│   ├── install-neovim.sh         # LazyVim
│   ├── install-docker.sh         # Docker + Colima
│   ├── install-shell.sh          # Shell configs
│   ├── install-devtools.sh       # Dev tools
│   ├── backup-engram.sh          # Backup de Engram
│   └── link-configs.sh           # Vincular configs
├── windows/
│   ├── install.ps1               # Instalador Windows (PowerShell)
│   ├── scripts/
│   │   ├── lib-detect.ps1        # Utilidades de detección
│   │   ├── install-opencode.ps1
│   │   ├── install-neovim.ps1
│   │   ├── install-docker.ps1
│   │   ├── install-shell.ps1
│   │   ├── install-devtools.ps1
│   │   ├── backup-engram.ps1
│   │   └── link-configs.ps1
│   └── configs/                  # Configs específicas de Windows
├── configs/
│   ├── opencode/                 # Configuración de opencode
│   ├── nvim/                     # Configuración de LazyVim
│   ├── docker/                   # Configuración de Docker
│   ├── bashrc                    # Configuración de Bash
│   ├── zshrc                     # Configuración de Zsh
│   └── profile                   # Profile shell
├── Brewfile                      # Paquetes Homebrew
└── .github/
    └── workflows/
        └── test-install.yml      # CI para pruebas
```

---

## 🔧 Configuraciones instaladas

El instalador respalda tus configs actuales antes de instalar:

| Source | Destination |
|--------|-------------|
| `configs/bashrc` | `~/.bashrc` |
| `configs/zshrc` | `~/.zshrc` |
| `configs/profile` | `~/.profile` |
| `configs/nvim/*` | `~/.config/nvim/` |
| `configs/opencode/*` | `~/.config/opencode/` |
| `configs/docker/*` | `~/.config/lazydocker/` |

> **Backup automático:** Los respaldos se guardan en `~/backup-config-{timestamp}/`

---

## 🐛 Solución de problemas

### Docker no inicia en Linux

```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar
```

### Colima no inicia en macOS

```bash
colima stop
colima delete
colima start
```

### Plugins de Neovim no cargan

```bash
nvim --headless +Lazy! sync +qa
```

### Windows: Error de ejecución de scripts

```powershell
# Si PowerShell bloquea los scripts:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### WSL: Docker no responde

```powershell
# En PowerShell (Windows):
Restart-Service Docker
# O desde Docker Desktop
```

---

## 📚 Recursos

- [Documentación de opencode](https://github.com/opencode-ai/opencode)
- [LazyVim](https://lazyvim.org)
- [Engram](https://github.com/engramhq/engram)
- [Homebrew](https://brew.sh)
- [Oh My Posh](https://ohmyposh.dev)

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcion`)
3. Commit tus cambios (`git commit -am 'Agrega nueva función'`)
4. Push a la rama (`git push origin feature/nueva-funcion`)
5. Abre un Pull Request

---

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles.

---

<p align="center">
  Hecho con ❤️ por <a href="https://github.com/Andressc19">Andressc19</a>
</p>
