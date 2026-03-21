# mi-config

> 🚀 Multi-platform installer for your development environment: opencode, Neovim/LazyVim, Docker, and more.

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20WSL-blue.svg)](https://github.com/Andressc19/mi-config)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/Andressc19/mi-config?style=social)](https://github.com/Andressc19/mi-config/stargazers)

---

## ✨ What's included?

| Tool | Description |
|------|-------------|
| **opencode** | AI assistant with persistent memory (Engram), SDD skills, and MCP integrations |
| **LazyVim** | Opinionated Neovim config with Tokyo Night theme and 30+ plugins |
| **Docker Stack** | Docker, Colima, LazyDocker for container management |
| **Shell Setup** | Bash-it, Oh-My-Zsh, Oh-My-Posh for modern prompts |
| **Dev Tools** | Homebrew, NVM, SDKMAN for version management |

---

## ⚡ Quick Install

### Windows (PowerShell)

```powershell
# Option 1: Download and run the TUI installer (recommended)
irm https://github.com/Andressc19/mi-config/releases/latest/download/mi-config-installer-windows.exe -OutFile mi-config-installer.exe
.\mi-config-installer.exe

# Option 2: PowerShell one-liner
irm https://raw.githubusercontent.com/Andressc19/mi-config/main/windows/bootstrap.ps1 | iex

# Option 3: Cross-platform TUI installer (recommended - works on all platforms)
## Windows
go run ./installer
## Linux/macOS
go run ./installer

# Option 4: Full installer (after cloning)
git clone https://github.com/Andressc19/mi-config.git
cd mi-config\windows
.\install.ps1 -All
```

### Linux / macOS / WSL

```bash
# Option 1: One-liner
curl -fsSL https://raw.githubusercontent.com/Andressc19/mi-config/main/install.sh | bash -s -- --all

# Option 2: Manual
git clone https://github.com/Andressc19/mi-config.git
cd mi-config
chmod +x install.sh
./install.sh --all
```

---

## 📋 Supported Platforms

| Platform | Status | Installer |
|----------|--------|-------------|
| Windows Native | ✅ | `windows/install.ps1` |
| macOS | ✅ | `install.sh` (Bash) |
| Linux (Ubuntu/Debian/Fedora) | ✅ | `install.sh` (Bash) |
| WSL (Windows Subsystem for Linux) | ✅ | `install.sh` (Bash) |

---

## 🎯 Selective Installation

### Linux / macOS / WSL

```bash
# opencode only
./install.sh --opencode

# Neovim only
./install.sh --nvim

# Docker only
./install.sh --docker

# Multiple components
./install.sh --opencode --nvim --docker

# Preview (no execution)
./install.sh --all --dry-run
```

### Windows (PowerShell)

```powershell
# opencode only
.\install.ps1 -Opencode

# Neovim only
.\install.ps1 -Nvim

# Multiple components
.\install.ps1 -Opencode -Nvim -Docker

# Preview (no execution)
.\install.ps1 -All -DryRun
```

---

## 🖥️ Interactive TUI Installer

The Go-based TUI installer provides an interactive interface for selecting components:

```bash
# Run the TUI installer
go run ./installer
```

### Features
- **Cross-platform**: Works on Windows, macOS, and Linux
- **Rose Pine dark theme**: Modern terminal aesthetics
- **Vim-style navigation**: Use `j/k` or arrow keys, `Enter` to select, `Esc` to go back
- **Step-by-step workflow**: Welcome → Select agent → Choose components → Review → Install

### TUI Screens
| Screen | Description |
|--------|-------------|
| Welcome | ASCII logo and intro |
| Agent Selection | Choose AI assistant (opencode, Claude Code, etc.) |
| Component Selection | Pick tools to install (opencode, Neovim, Docker, etc.) |
| Review | Review installation plan |
| Installing | Progress display with spinner |
| Complete | Success summary |

### Requirements
- Go 1.21+

---

### Available Flags

| Flag | Description |
|------|-------------|
| `--all` / `-All` | Install everything |
| `--opencode` / `-Opencode` | opencode + Engram + skills |
| `--nvim` / `-Nvim` | Neovim + LazyVim |
| `--docker` / `-Docker` | Docker + LazyDocker |
| `--shell` / `-Shell` | Shell configuration |
| `--devtools` / `-DevTools` | Git, Python, Node, etc |
| `--link` / `-Link` | Copy/link configs |
| `--dry-run` / `-DryRun` | Preview without executing |
| `--help` / `-Help` | Show help |

---

## 🛠️ Requirements

### Windows
- PowerShell 7+ (or 5.1)
- Git
- A package manager: **winget**, **scoop**, or **chocolatey**

### Linux / macOS / WSL
- `curl` or `wget`
- `git`
- `bash` 4.0+

### macOS
- [Homebrew](https://brew.sh)

### WSL
- Docker Desktop for Windows (with WSL2 integration)

---

## 💾 Engram Backup

Engram is opencode's persistent memory. To back it up:

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

Backups are saved to:
- **Linux/WSL**: `~/engram-backups/`
- **Windows**: `%USERPROFILE%\engram-backups\`

---

## 📁 Project Structure

```
mi-config/
├── install.sh                    # Main installer (Bash)
├── installer/                    # Go TUI installer (cross-platform)
│   └── internal/tui/
│       ├── main.go              # TUI entry point
│       ├── model.go             # State management
│       ├── router.go            # Screen navigation router
│       ├── styles.go            # Rose Pine theme styles
│       ├── screen_*.go          # Individual screen renderers
│       └── interactive.go      # Keyboard input handling
├── scripts/
│   ├── lib-detect.sh             # Detection utilities
│   ├── install-opencode.sh       # opencode + Engram
│   ├── install-neovim.sh         # LazyVim
│   ├── install-docker.sh         # Docker + Colima
│   ├── install-shell.sh          # Shell configs
│   ├── install-devtools.sh       # Dev tools
│   ├── backup-engram.sh          # Engram backup
│   └── link-configs.sh           # Link configs
├── windows/
│   ├── install.ps1               # Windows installer (PowerShell)
│   ├── scripts/
│   │   ├── lib-detect.ps1        # Detection utilities
│   │   ├── install-opencode.ps1
│   │   ├── install-neovim.ps1
│   │   ├── install-docker.ps1
│   │   ├── install-shell.ps1
│   │   ├── install-devtools.ps1
│   │   ├── backup-engram.ps1
│   │   └── link-configs.ps1
│   └── configs/                  # Windows-specific configs
├── configs/
│   ├── opencode/                 # opencode configuration
│   ├── nvim/                     # LazyVim configuration
│   ├── docker/                   # Docker configuration
│   ├── bashrc                    # Bash configuration
│   ├── zshrc                     # Zsh configuration
│   └── profile                   # Shell profile
├── Brewfile                      # Homebrew packages
└── .github/
    └── workflows/
        └── test-install.yml      # CI for testing
```

---

## 🔧 Installed Configurations

The installer backs up your existing configs before installing:

| Source | Destination |
|--------|-------------|
| `configs/bashrc` | `~/.bashrc` |
| `configs/zshrc` | `~/.zshrc` |
| `configs/profile` | `~/.profile` |
| `configs/nvim/*` | `~/.config/nvim/` |
| `configs/opencode/*` | `~/.config/opencode/` |
| `configs/docker/*` | `~/.config/lazydocker/` |

> **Auto-backup:** Backups are saved to `~/backup-config-{timestamp}/`

---

## 🐛 Troubleshooting

### Docker not starting on Linux

```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in
```

### Colima not starting on macOS

```bash
colima stop
colima delete
colima start
```

### Neovim plugins not loading

```bash
nvim --headless +Lazy! sync +qa
```

### Windows: Script execution error

```powershell
# If PowerShell blocks scripts:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### WSL: Docker not responding

```powershell
# In PowerShell (Windows):
Restart-Service Docker
# Or from Docker Desktop
```

---

## 📚 Resources

- [opencode Documentation](https://github.com/opencode-ai/opencode)
- [LazyVim](https://lazyvim.org)
- [Engram](https://github.com/engramhq/engram)
- [Homebrew](https://brew.sh)
- [Oh My Posh](https://ohmyposh.dev)

---

## 🤝 Contributing

1. Fork the repository
2. Create a branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Andressc19">Andressc19</a>
</p>
