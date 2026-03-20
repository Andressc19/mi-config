#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

install_shell() {
    log_info "Installing shell configurations..."

    local shell_choice="${1:-zsh}"

    if [[ "$shell_choice" == "bash" ]]; then
        install_bash
    elif [[ "$shell_choice" == "zsh" ]]; then
        install_zsh
    else
        install_zsh
        install_bash
    fi
}

install_bash() {
    log_info "Setting up Bash..."

    local bashrc_src="$REPO_ROOT/configs/bashrc"
    local bashrc_dest="$HOME/.bashrc"
    local bash_it_dir="$HOME/.bash_it"

    if [[ -f "$bashrc_dest" ]] && [[ ! -L "$bashrc_dest" ]]; then
        backup_config "$bashrc_dest"
    fi

    if [[ -f "$bashrc_src" ]]; then
        cp "$bashrc_src" "$bashrc_dest"
        log_success "Installed .bashrc"
    fi

    if [[ -d "$bash_it_dir" ]]; then
        log_info "Bash-it already installed"
    else
        log_info "Installing Bash-it..."
        git clone --depth=1 https://github.com/Bash-it/bash-it.git "$bash_it_dir"
    fi
}

install_zsh() {
    log_info "Setting up Zsh..."

    local zshrc_src="$REPO_ROOT/configs/zshrc"
    local zshrc_dest="$HOME/.zshrc"
    local omz_dir="$HOME/.oh-my-zsh"

    if [[ -f "$zshrc_dest" ]] && [[ ! -L "$zshrc_dest" ]]; then
        backup_config "$zshrc_dest"
    fi

    if ! command -v zsh &> /dev/null; then
        log_info "Installing zsh..."
        if [[ "$OS" == "darwin" ]]; then
            brew install zsh
        elif [[ "$OS" == "linux" ]]; then
            sudo apt-get install -y zsh
        fi
    fi

    if [[ -d "$omz_dir" ]]; then
        log_info "Oh-My-Zsh already installed"
    else
        log_info "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    if [[ -f "$zshrc_src" ]]; then
        cp "$zshrc_src" "$zshrc_dest"
        log_success "Installed .zshrc"
    fi

    if ! command -v oh-my-posh &> /dev/null; then
        log_info "Installing Oh-My-Posh..."
        if [[ "$OS" == "darwin" ]]; then
            brew install oh-my-posh
        else
            curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o /usr/local/bin/oh-my-posh
            chmod +x /usr/local/bin/oh-my-posh
        fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_shell "${1:-zsh}"
fi