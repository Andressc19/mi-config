#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

link_configs() {
    log_info "Linking configuration files..."

    local configs=(
        "bashrc:.bashrc"
        "zshrc:.zshrc"
        "profile:.profile"
    )

    for config in "${configs[@]}"; do
        local src="$REPO_ROOT/configs/${config%%:*}"
        local dest="$HOME/.${config##*:}"

        if [[ -f "$src" ]]; then
            if [[ -f "$dest" ]] && [[ ! -L "$dest" ]]; then
                backup_config "$dest"
            fi

            rm -f "$dest"
            ln -sf "$src" "$dest"
            log_success "Linked $dest -> $src"
        fi
    done

    if [[ -d "$REPO_ROOT/configs/nvim" ]]; then
        mkdir -p "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim"
        ln -sf "$REPO_ROOT/configs/nvim" "$HOME/.config/nvim"
        log_success "Linked nvim config"
    fi

    if [[ -d "$REPO_ROOT/configs/opencode" ]]; then
        mkdir -p "$HOME/.config/opencode"
        rm -rf "$HOME/.config/opencode"
        ln -sf "$REPO_ROOT/configs/opencode" "$HOME/.config/opencode"
        log_success "Linked opencode config"
    fi

    if [[ -d "$REPO_ROOT/configs/docker" ]]; then
        mkdir -p "$HOME/.config/lazydocker"
        rm -rf "$HOME/.config/lazydocker"
        ln -sf "$REPO_ROOT/configs/docker" "$HOME/.config/lazydocker"
        log_success "Linked lazydocker config"
    fi

    log_success "Config linking complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    link_configs
fi