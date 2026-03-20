#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

install_devtools() {
    log_info "Installing development tools..."

    if [[ "$OS" == "darwin" ]]; then
        install_homebrew
    elif [[ "$OS" == "linux" ]] || [[ "$WSL" == "true" ]]; then
        install_linux_devtools
    fi

    install_nvm
    install_sdkman

    log_success "Development tools installation complete"
}

install_homebrew() {
    if command -v brew &> /dev/null; then
        log_info "Homebrew already installed"
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$OS" == "linux" ]]; then
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

install_linux_devtools() {
    log_info "Installing development tools for Linux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            curl \
            git \
            build-essential \
            wget \
            unzip \
            git-lfs \
            fzf \
            ripgrep \
            bat \
            exa \
            tree \
            htop \
            vim \
            tmux
    fi

    if command -v dnf &> /dev/null; then
        sudo dnf install -y \
            curl \
            git \
            gcc \
            gcc-c++ \
            make \
            wget \
            unzip \
            fzf \
            ripgrep \
            bat \
            tree \
            htop \
            vim
    fi
}

install_nvm() {
    local nvm_dir="$HOME/.nvm"

    if [[ -d "$nvm_dir" ]]; then
        log_info "NVM already installed"
        return 0
    fi

    log_info "Installing NVM..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    nvm install --lts
    nvm alias default lts/*
    nvm use default

    log_success "NVM installed"
}

install_sdkman() {
    if command -v sdk &> /dev/null; then
        log_info "SDKMAN already installed"
        return 0
    fi

    log_info "Installing SDKMAN..."
    curl -fsSL "https://get.sdkman.io" | bash

    if [[ -n "$ZSH_VERSION" ]]; then
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    sdk install java 2>/dev/null || true

    log_success "SDKMAN installed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_devtools
fi