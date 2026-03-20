# mi-config Installer

A TUI installer for setting up your development environment with mi-config.

## Features

- **opencode + Engram** - AI-powered coding assistant with persistent memory
- **LazyVim** - Modern Neovim configuration with LSP, Treesitter, and more
- **Docker** - Container platform for development
- **Shell** - PowerShell with oh-my-posh for beautiful prompts
- **DevTools** - Git, VS Code, and other essential tools

## Installation

### Interactive Mode (TUI)

```bash
mi-config-installer
```

### Non-Interactive Mode (CLI)

```bash
# Install all components
mi-config-installer --non-interactive --opencode --lazvim --docker --shell --devtools

# Install specific components
mi-config-installer --non-interactive --opencode --nvim
```

## Supported Platforms

- Windows (winget)
- macOS (Homebrew)
- Linux (apt, dnf, pacman)
- WSL

## Flags

| Flag | Description |
|------|-------------|
| `-h, --help` | Show help message |
| `-v, --version` | Show version |
| `--dry-run` | Preview without installing |
| `--non-interactive` | CLI mode |
| `--opencode` | Install opencode + Engram |
| `--nvim, --lazvim` | Install LazyVim |
| `--docker` | Install Docker |
| `--shell` | Install PowerShell + oh-my-posh |
| `--devtools` | Install Git, VS Code |

## Building from Source

```bash
cd installer
go build -o mi-config-installer ./cmd/mi-config-installer
```

## License

MIT
