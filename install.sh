#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
cd "$SCRIPT_DIR"

source "$SCRIPT_DIR/scripts/lib-detect.sh"

INSTALL_OPENCODE="false"
INSTALL_NVIM="false"
INSTALL_DOCKER="false"
INSTALL_SHELL="false"
INSTALL_DEVTOOLS="false"
INSTALL_LINK="false"

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                INSTALL_OPENCODE="true"
                INSTALL_NVIM="true"
                INSTALL_DOCKER="true"
                INSTALL_SHELL="true"
                INSTALL_DEVTOOLS="true"
                INSTALL_LINK="true"
                shift
                ;;
            --opencode)    INSTALL_OPENCODE="true";  shift ;;
            --nvim)        INSTALL_NVIM="true";      shift ;;
            --docker)      INSTALL_DOCKER="true";    shift ;;
            --shell)       INSTALL_SHELL="true";     shift ;;
            --devtools)    INSTALL_DEVTOOLS="true";  shift ;;
            --link)        INSTALL_LINK="true";      shift ;;
            --dry-run)     DRY_RUN="true";           shift ;;
            --help)        show_help; exit 0 ;;
            *)             log_error "Unknown option: $1"; show_help; exit 1 ;;
        esac
    done
}

show_menu() {
    cat << 'EOF'

  ╔═══════════════════════════════════════════════════════════╗
  ║              Development Environment Installer             ║
  ║                                                           ║
  ║  Select components to install:                           ║
  ║                                                           ║
  ║    [1] All components                                     ║
  ║    [2] opencode + engram + skills + MCP                   ║
  ║    [3] LazyVim (Neovim) + plugins                         ║
  ║    [4] Docker + Colima + LazyDocker                       ║
  ║    [5] Shell configs (bash/zsh)                           ║
  ║    [6] Dev tools (Homebrew, NVM, SDKMAN)                  ║
  ║    [7] Link all configs                                   ║
  ║                                                           ║
  ║    [Q] Quit                                               ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝

EOF
}

show_system_info() {
    echo "  Detected OS: $OS"
    if [[ "$WSL" == "true" ]]; then
        echo "  WSL: Enabled (Windows Subsystem for Linux)"
    fi
    echo ""
}

run_install() {
    local script="$1"
    local name="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would execute: $script"
        return 0
    fi

    log_info "Installing $name..."
    bash "$script"
}

main() {
    show_banner
    show_system_info

    parse_args "$@"

    if [[ "$INSTALL_OPENCODE" == "false" ]] && \
       [[ "$INSTALL_NVIM" == "false" ]] && \
       [[ "$INSTALL_DOCKER" == "false" ]] && \
       [[ "$INSTALL_SHELL" == "false" ]] && \
       [[ "$INSTALL_DEVTOOLS" == "false" ]] && \
       [[ "$INSTALL_LINK" == "false" ]]; then
        log_error "No components selected. Use --help for usage."
        exit 1
    fi

    log_info "Starting installation..."

    if [[ "$INSTALL_LINK" == "true" ]]; then
        run_install "$SCRIPT_DIR/scripts/link-configs.sh" "config symlinks"
    fi

    if [[ "$INSTALL_DEVTOOLS" == "true" ]]; then
        run_install "$SCRIPT_DIR/scripts/install-devtools.sh" "development tools"
    fi

    if [[ "$INSTALL_SHELL" == "true" ]]; then
        run_install "$SCRIPT_DIR/scripts/install-shell.sh" "shell configurations"
    fi

    if [[ "$INSTALL_OPENCODE" == "true" ]]; then
        run_install "$SCRIPT_DIR/scripts/install-opencode.sh" "opencode"
    fi

    if [[ "$INSTALL_NVIM" == "true" ]]; then
        run_install "$SCRIPT_DIR/scripts/install-neovim.sh" "LazyVim"
    fi

    if [[ "$INSTALL_DOCKER" == "true" ]]; then
        run_install "$SCRIPT_DIR/scripts/install-docker.sh" "Docker stack"
    fi

    echo ""
    log_success "Installation complete!"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "This was a dry run. Run without --dry-run to execute."
    fi

    echo ""
    log_info "Next steps:"
    log_info "  - Restart your shell"
    log_info "  - Run 'nvim' to complete LazyVim setup"
    log_info "  - Run 'opencode' to start using opencode"
}

main "$@"
