#!/bin/bash

# verify-install.sh - Verify installer file structure
# Usage: ./verify-install.sh [--all] [--opencode] [--nvim] [--docker] [--shell] [--devtools] [--engram]
# Exit codes: 0 = all passed, 1 = some failed, 2 = usage error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
TOTAL=0

# Print functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info() {
    echo "  $1"
}

# Check if file exists
check_file() {
    local file="$1"
    local desc="${2:-}"
    TOTAL=$((TOTAL + 1))
    if [[ -f "$REPO_ROOT/$file" ]]; then
        pass "$file${desc:+ - $desc}"
    else
        fail "$file${desc:+ - $desc} (NOT FOUND)"
    fi
}

# Check if directory exists
check_dir() {
    local dir="$1"
    local desc="${2:-}"
    TOTAL=$((TOTAL + 1))
    if [[ -d "$REPO_ROOT/$dir" ]]; then
        pass "$dir/${desc:+ - $desc}"
    else
        fail "$dir/${desc:+ - $desc} (NOT FOUND)"
    fi
}

# Check if content exists in file
check_content() {
    local file="$1"
    local pattern="$2"
    local desc="${3:-}"
    TOTAL=$((TOTAL + 1))
    if [[ -f "$REPO_ROOT/$file" ]] && grep -q "$pattern" "$REPO_ROOT/$file"; then
        pass "$file${desc:+ - $desc}"
    else
        fail "$file${desc:+ - $desc} (pattern not found)"
    fi
}

# Verify opencode
verify_opencode() {
    echo ""
    echo "=== OpenCode ==="
    check_dir "configs/opencode" "config directory"
    check_file "configs/opencode/orchestrator.md" "main config"
    check_dir "configs/opencode/skills" "skills directory"
}

# Verify nvim
verify_nvim() {
    echo ""
    echo "=== Neovim (LazyVim) ==="
    check_dir "configs/nvim" "nvim directory"
    check_file "configs/nvim/init.lua" "init file"
    check_file "configs/nvim/lua/plugins/themery.lua" "themery plugin"
    check_file "configs/nvim/lua/config/nodejs.lua" "nodejs config"
    check_file "configs/nvim/lazyvim.json" "lazyvim config"
}

# Verify docker
verify_docker() {
    echo ""
    echo "=== Docker ==="
    check_dir "configs/docker" "docker directory"
    check_file "configs/docker/lazydocker.yml" "lazydocker config" || true
    check_dir "configs/docker" "has configs"
}

# Verify shell
verify_shell() {
    echo ""
    echo "=== Shell ==="
    check_file "configs/bashrc" "bashrc"
    check_file "configs/zshrc" "zshrc"
    check_file "configs/profile" "profile"
}

# Verify devtools
verify_devtools() {
    echo ""
    echo "=== DevTools ==="
    # Check if Brewfile exists (indicates devtools config)
    check_file "Brewfile" "Brewfile (macOS devtools)" || true
    info "DevTools verification is basic"
}

# Verify engram (shares structure with opencode)
verify_engram() {
    echo ""
    echo "=== Engram ==="
    check_dir "configs/opencode" "engram requires opencode structure"
    check_file "configs/opencode/orchestrator.md" "orchestrator for engram"
}

# Verify installer scripts have correct code
verify_installer_code() {
    echo ""
    echo "=== Installer Code Verification ==="
    
    # Check nvim installer has XDG_CONFIG_HOME
    check_content "windows/scripts/install-neovim.ps1" "XDG_CONFIG_HOME" "XDG config in nvim installer"
    
    # Check link-configs has XDG support
    check_content "windows/scripts/link-configs.ps1" "\.config" "XDG path in link-configs"
}

# Print summary
print_summary() {
    echo ""
    echo "========================================"
    echo "Summary: $PASSED/$TOTAL passed, $FAILED failed"
    echo "========================================"
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}All checks passed!${NC}"
        return 0
    else
        echo -e "${RED}Some checks failed!${NC}"
        return 1
    fi
}

# Usage
usage() {
    echo "Usage: $0 [--all] [--opencode] [--nvim] [--docker] [--shell] [--devtools] [--engram] [--installer]"
    echo ""
    echo "Options:"
    echo "  --all       Verify all components"
    echo "  --opencode  Verify opencode config"
    echo "  --nvim      Verify neovim config"
    echo "  --docker    Verify docker config"
    echo "  --shell     Verify shell config"
    echo "  --devtools  Verify devtools"
    echo "  --engram    Verify engram"
    echo "  --installer Verify installer scripts"
    echo "  --help      Show this help"
    exit 0
}

# Main
main() {
    local verify_all=false
    
    if [[ $# -eq 0 ]]; then
        verify_all=true
    fi
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)       verify_all=true ;;
            --opencode)  verify_opencode ;;
            --nvim)      verify_nvim ;;
            --docker)    verify_docker ;;
            --shell)     verify_shell ;;
            --devtools)  verify_devtools ;;
            --engram)    verify_engram ;;
            --installer) verify_installer_code ;;
            --help)      usage ;;
            *)           echo "Unknown option: $1"; usage ;;
        esac
        shift
    done
    
    if [[ $verify_all == true ]]; then
        verify_opencode
        verify_nvim
        verify_docker
        verify_shell
        verify_devtools
        verify_engram
        verify_installer_code
    fi
    
    print_summary
}

main "$@"
