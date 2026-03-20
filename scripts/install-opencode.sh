#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

install_opencode() {
    log_info "Installing opencode..."

    local opencode_dir="$HOME/.config/opencode"
    local opencode_bin="$HOME/.local/bin/opencode"

    if [[ -d "$opencode_dir" ]]; then
        log_warn "opencode config already exists at $opencode_dir"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping opencode installation"
            return 0
        fi
        backup_config "$opencode_dir"
    fi

    if command -v opencode &> /dev/null; then
        log_info "opencode already installed: $(opencode --version 2>/dev/null || echo 'unknown')"
    else
        log_info "Installing opencode..."
        if [[ "$OS" == "darwin" ]]; then
            brew install opencode || log_error "Failed to install opencode via brew"
        elif [[ "$OS" == "linux" ]] || [[ "$WSL" == "true" ]]; then
            curl -fsSL https://get.opencode.ai | sh || log_error "Failed to install opencode"
        fi
    fi

    if [[ -d "$REPO_ROOT/configs/opencode" ]]; then
        mkdir -p "$opencode_dir"
        cp -r "$REPO_ROOT/configs/opencode/"* "$opencode_dir/"
        log_success "Copied opencode config to $opencode_dir"
    fi

    mkdir -p "$HOME/.local/bin"
    if [[ ! -f "$opencode_bin" ]]; then
        ln -sf "$(which opencode)" "$opencode_bin" 2>/dev/null || true
    fi

    log_success "opencode installation complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_opencode
fi