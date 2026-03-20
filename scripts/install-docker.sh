#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

install_docker() {
    log_info "Installing Docker stack..."

    if [[ "$OS" == "darwin" ]]; then
        if ! command -v docker &> /dev/null; then
            log_info "Installing Docker Desktop for macOS..."
            brew install --cask docker
        fi

        if ! command -v colima &> /dev/null; then
            log_info "Installing colima..."
            brew install colima
        fi

        if ! command -v lazydocker &> /dev/null; then
            log_info "Installing lazydocker..."
            brew install lazydocker
        fi

        if ! command -v lima &> /dev/null; then
            brew install lima
        fi

        if [[ -d "$REPO_ROOT/configs/docker" ]]; then
            mkdir -p "$HOME/.config/lazydocker"
            cp -r "$REPO_ROOT/configs/docker/"* "$HOME/.config/lazydocker/"
            log_success "Copied lazydocker config"
        fi

        log_info "Starting colima..."
        colima start 2>/dev/null || log_warn "colima already running or failed to start"

    elif [[ "$OS" == "linux" ]]; then
        if ! command -v docker &> /dev/null; then
            log_info "Installing Docker..."
            curl -fsSL https://get.docker.com | sh
            sudo usermod -aG docker "$USER"
            log_warn "You may need to logout/login for docker group to take effect"
        fi

        if ! command -v docker-compose &> /dev/null; then
            log_info "Installing docker-compose..."
            sudo curl -fsSL "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi

        if ! command -v lazydocker &> /dev/null; then
            log_info "Installing lazydocker..."
            curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        fi

    elif [[ "$WSL" == "true" ]]; then
        log_info "WSL detected - Docker Desktop integration recommended"
        log_info "Install Docker Desktop for Windows and enable WSL2 integration"
    fi

    log_success "Docker stack installation complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_docker
fi