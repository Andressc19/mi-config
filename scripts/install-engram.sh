#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-detect.sh"

REPO_TYPE="${1:---fork}"

ENGRAM_BIN_DIR="$HOME/.local/bin"
ENGRAM_BIN="$ENGRAM_BIN_DIR/engram"
INSTALL_DIR="$HOME/.local/src/engram"
CONFIG_DIR="$HOME/.config/opencode/plugins"

get_engram_from_release() {
    local source="$1"
    local repo="Andressc19/mi-config"
    
    if [[ "$source" == "upstream" ]]; then
        repo="Gentleman-Programming/engram"
    fi
    
    log_info "Fetching latest release from $repo..."
    
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    local response=$(curl -fsSL "$api_url")
    local version=$(echo "$response" | grep -o '"tag_name":[^,]*' | sed 's/"tag_name": "//;s/"//' | sed 's/^v//')
    
    log_info "Latest version: $version"
    
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        arm64) arch="arm64" ;;
    esac
    
    case "$os" in
        darwin) os="darwin" ;;
        linux) os="linux" ;;
        mingw*|msys*|cygwin) os="windows" ;;
        *) log_error "Unsupported OS: $os"; return 1 ;;
    esac
    
    local ext="tar.gz"
    local filename="engram_${os}_${arch}.${ext}"
    
    if [[ "$os" == "windows" ]]; then
        ext="zip"
        filename="engram_${os}_${arch}.${ext}"
    fi
    
    local download_url="https://github.com/$repo/releases/download/v${version}/$filename"
    
    log_info "Downloading: $filename"
    
    local temp_file="/tmp/$filename"
    curl -fsSL "$download_url" -o "$temp_file"
    
    mkdir -p "$ENGRAM_BIN_DIR"
    
    if [[ "$ext" == "zip" ]]; then
        unzip -o "$temp_file" -d "$ENGRAM_BIN_DIR"
    else
        tar -xzf "$temp_file" -C "$ENGRAM_BIN_DIR"
    fi
    
    chmod +x "$ENGRAM_BIN"
    
    rm -f "$temp_file"
    
    log_success "Engram installed to $ENGRAM_BIN"
}

log_info "Starting engram installation (mode: ${REPO_TYPE#--})"

if ! command -v git &> /dev/null; then
    log_error "git is not installed"
    exit 1
fi

if ! command -v bun &> /dev/null; then
    log_error "bun is not installed. Please install bun for plugin installation"
    exit 1
fi

log_success "bun detected"

if [[ -f "$ENGRAM_BIN" ]]; then
    log_warn "engram binary already exists at $ENGRAM_BIN"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    backup_config "$ENGRAM_BIN"
fi

if [[ "$REPO_TYPE" == "--fork" ]]; then
    log_info "Installing engram from fork release..."
    
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed"
        exit 1
    fi
    
    get_engram_from_release "fork"
    
    if [[ ! -f "$ENGRAM_BIN" ]]; then
        log_error "Download failed"
        exit 1
    fi
    
    PLUGIN_REPO_URL="https://github.com/Andressc19/engram.git"
else
    log_info "Installing engram from upstream source..."
    
    if ! command -v go &> /dev/null; then
        log_error "Go is not installed. Please install Go 1.25+"
        exit 1
    fi
    
    GO_VERSION=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+')
    GO_MAJOR=$(echo "$GO_VERSION" | cut -d. -f1)
    GO_MINOR=$(echo "$GO_VERSION" | cut -d. -f2)
    
    if [[ "$GO_MAJOR" -lt 1 || ("$GO_MAJOR" -eq 1 && "$GO_MINOR" -lt 25) ]]; then
        log_error "Go version $GO_VERSION is too old. Please install Go 1.25+"
        exit 1
    fi
    
    log_success "Go version $GO_VERSION detected"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        log_warn "Directory $INSTALL_DIR already exists"
        read -p "Remove and re-clone? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Using existing directory"
        else
            rm -rf "$INSTALL_DIR"
        fi
    fi
    
    REPO_URL="https://github.com/Gentleman-Programming/engram.git"
    
    log_info "Cloning $REPO_URL..."
    mkdir -p "$INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR"
    log_success "Repository cloned"
    
    log_info "Building engram..."
    cd "$INSTALL_DIR"
    go build -o "$ENGRAM_BIN" ./cmd/engram
    
    if [[ ! -f "$ENGRAM_BIN" ]]; then
        log_error "Build failed"
        exit 1
    fi
    
    chmod +x "$ENGRAM_BIN"
    log_success "Binary built successfully"
    
    PLUGIN_REPO_URL="https://github.com/Gentleman-Programming/engram.git"
fi

log_info "Verifying installation..."
if ! engram version; then
    log_error "Verification failed"
    exit 1
fi

log_success "engram is installed"

log_info "Running engram setup opencode..."
if ! engram setup opencode; then
    log_error "engram setup opencode failed"
    exit 1
fi

log_success "engram setup completed"

log_info "Installing plugin..."
PLUGIN_REPO_DIR="/tmp/engram-plugin-source"

if [[ -d "$PLUGIN_REPO_DIR" ]]; then
    rm -rf "$PLUGIN_REPO_DIR"
fi

git clone "$PLUGIN_REPO_URL" "$PLUGIN_REPO_DIR"
log_success "Plugin repository cloned"

cd "$PLUGIN_REPO_DIR/plugin"
bun install
bun build engram.ts -o "$CONFIG_DIR/engram.js"

rm -rf "$PLUGIN_REPO_DIR"

if [[ ! -f "$CONFIG_DIR/engram.js" ]]; then
    log_error "Plugin build failed"
    exit 1
fi

log_success "Plugin installed successfully"

log_success "Engram installation completed!"
log_info "Run 'engram version' to verify"