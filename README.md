# mi-config

> Multi-platform development environment installer for opencode, Neovim/LazyVim, Docker, and shell configurations.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/Andressc19/mi-config/main/install.sh | bash -s -- --all
```

## Features

- **opencode**: AI coding assistant with engram memory, SDD skills, and MCP integrations
- **LazyVim**: Opinionated Neovim config with Tokyo Night theme and 30+ plugins
- **Docker Stack**: Docker, Colima, LazyDocker for container management
- **Shell Setup**: Bash-it, Oh-My-Zsh, Oh-My-Posh prompts
- **Dev Tools**: Homebrew, NVM, SDKMAN for Java

## Supported Platforms

| Platform | Status |
|----------|--------|
| macOS | ✅ Fully supported |
| Linux (Ubuntu/Debian/Fedora) | ✅ Fully supported |
| WSL (Windows Subsystem for Linux) | ✅ Supported |
| Windows (Git Bash/Cygwin) | ⚠️ Partial |

## Installation Options

### Full Installation

```bash
./install.sh --all
```

### Selective Installation

```bash
# Install only opencode
./install.sh --opencode

# Install only LazyVim
./install.sh --nvim

# Install Docker stack
./install.sh --docker

# Install shell configs
./install.sh --shell

# Install dev tools
./install.sh --devtools

# Link config files
./install.sh --link

# Multiple components
./install.sh --opencode --nvim --docker
```

### Dry Run

Preview what would be installed without executing:

```bash
./install.sh --all --dry-run
```

## Requirements

### Linux/macOS
- `curl` or `wget`
- `git`
- `bash` 4.0+

### macOS
- [Homebrew](https://brew.sh)

### WSL
- Docker Desktop for Windows (with WSL2 integration)

## Directory Structure

```
mi-config/
├── install.sh              # Main installer
├── scripts/
│   ├── lib-detect.sh       # Detection utilities
│   ├── install-opencode.sh # opencode + engram
│   ├── install-neovim.sh    # LazyVim
│   ├── install-docker.sh    # Docker + Colima
│   ├── install-shell.sh     # Shell configs
│   ├── install-devtools.sh   # Dev tools
│   └── link-configs.sh     # Symlink configs
├── configs/
│   ├── opencode/           # opencode configuration
│   ├── nvim/               # LazyVim configuration
│   ├── docker/             # Docker configs
│   ├── bashrc              # Bash configuration
│   ├── zshrc               # Zsh configuration
│   └── profile             # Profile configuration
└── Brewfile                # Homebrew package list
```

## What Gets Installed

### opencode
- opencode AI assistant
- engram persistent memory
- SDD skills (sdd-init, sdd-spec, sdd-design, etc.)
- MCP integrations (engram, blender, instantmesh)
- Mermaid diagrams support

### LazyVim
- Neovim with LazyVim starter
- Tokyo Night theme (moon style with transparency)
- 30+ plugins including:
  - Telescope (fuzzy finder)
  - Treesitter (syntax highlighting)
  - LSP Zero (language servers)
  - gitsigns (git integration)
  - nvim-cmp (autocompletion)

### Docker Stack
- Docker Engine
- Colima (Linux/macOS container runtime)
- docker-compose
- LazyDocker (terminal UI)

### Shell
- Bash-it (bash framework)
- Oh-My-Zsh (zsh framework)
- Oh-My-Posh (prompts)
- NVM (Node version manager)
- SDKMAN (Java version manager)

## Configuration Files

The installer will backup and replace existing configurations:

| Source | Destination |
|--------|-------------|
| configs/bashrc | ~/.bashrc |
| configs/zshrc | ~/.zshrc |
| configs/profile | ~/.profile |
| configs/nvim/* | ~/.config/nvim/ |
| configs/opencode/* | ~/.config/opencode/ |
| configs/docker/* | ~/.config/lazydocker/ |

Backups are created at `~/backup-config-{timestamp}/`

## Troubleshooting

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

## License

MIT
