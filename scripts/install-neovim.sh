#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

install_neovim() {
    log_info "Installing LazyVim (Neovim)..."

    local nvim_dir="$HOME/.config/nvim"

    if [[ -d "$nvim_dir" ]]; then
        log_warn "nvim config already exists at $nvim_dir"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping neovim installation"
            return 0
        fi
        backup_config "$nvim_dir"
    fi

    if ! command -v nvim &> /dev/null; then
        log_info "Installing neovim..."
        if [[ "$OS" == "darwin" ]]; then
            brew install neovim
        elif [[ "$OS" == "linux" ]] || [[ "$WSL" == "true" ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y neovim
            fi
        fi
    else
        log_info "neovim already installed: $(nvim --version | head -1)"
    fi

    if [[ -d "$REPO_ROOT/configs/nvim" ]]; then
        mkdir -p "$nvim_dir"
        cp -r "$REPO_ROOT/configs/nvim/"* "$nvim_dir/"
        log_success "Copied nvim config to $nvim_dir"
    fi

    log_info "Installing LazyVim plugins (this may take a while)..."
    NVIM_APPNAME=nvim nvim --headless +Lazy! sync +qa 2>/dev/null || true

    log_success "LazyVim installation complete"
    log_info "Run 'nvim' to complete setup"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_neovim
fi