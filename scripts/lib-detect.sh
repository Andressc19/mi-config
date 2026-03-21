#!/bin/bash

OS="$(uname -s)"
WSL="false"
DRY_RUN="false"

if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
    WSL="true"
fi

log_info() {
    echo -e "\033[1;34m[INFO]\033[0m $*"
}

log_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $*"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $*"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $*" >&2
}

backup_config() {
    local path="$1"
    local backup_dir="$HOME/backup-config-$(date +%Y%m%d-%H%M%S)"

    if [[ -e "$path" ]]; then
        mkdir -p "$backup_dir"
        cp -r "$path" "$backup_dir/"
        log_info "Backed up $path to $backup_dir/"
    fi
}

show_banner() {
    cat << 'EOF'

   ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗ ███╗   ██╗
  ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗████╗  ██║
  ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║██╔██╗ ██║
  ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║██║╚██╗██║
  ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║██║ ╚████║
   ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝

              Multi-Platform Development Environment Installer

EOF
}

show_help() {
    cat << EOF

Usage: $0 [OPTIONS]

Options:
    --all          Install everything
    --opencode     Install opencode + engram + skills + MCP
    --nvim         Install LazyVim + plugins
    --docker       Install Docker, Colima, LazyDocker
    --shell        Install shell configurations (bash/zsh)
    --devtools     Install Homebrew, NVM, SDKMAN
    --link         Link config files (symlinks)
    --engram           Install engram (from fork or upstream)
    --engram-source    Choose source: fork or upstream (default: fork, or TUI if omitted)
    --dry-run      Show what would be installed without executing
    --help         Show this help message

Examples:
    $0 --all                    # Full installation
    $0 --opencode --nvim       # Install only opencode and neovim
    $0 --dry-run --all         # Preview full installation

EOF
}

get_engram_source() {
    if [[ "$1" == "--fork" ]]; then
        echo "fork"
        return 0
    fi

    if [[ "$1" == "--upstream" ]]; then
        echo "upstream"
        return 0
    fi

    echo "Select engram source:"
    echo "  1) fork"
    echo "  2) upstream"
    echo ""
    read -p "Enter option (1/2/q): " option

    case "$option" in
        1) echo "fork" ;;
        2) echo "upstream" ;;
        q|Q) return 1 ;;
        *) echo "upstream" ;;
    esac
}

get_engram_repo_url() {
    local source="$1"
    case "$source" in
        fork) echo "git@github.com:Andressc19/engram.git" ;;
        upstream) echo "https://github.com/Gentleman-Programming/engram.git" ;;
        *) echo "https://github.com/Gentleman-Programming/engram.git" ;;
    esac
}

parse_skills_manifest() {
    local manifest_path="$1"
    
    if [[ ! -f "$manifest_path" ]]; then
        log_error "skills-manifest.json not found at $manifest_path"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for skills manifest parsing. Install with: brew install jq"
        return 1
    fi
    
    echo "$manifest_path"
}

get_skill_ids() {
    local manifest_path="$1"
    jq -r '.skills[].id' "$manifest_path"
}

get_skill_by_id() {
    local manifest_path="$1"
    local skill_id="$2"
    jq -r ".skills[] | select(.id == \"$skill_id\")" "$manifest_path"
}

skill_exists() {
    local manifest_path="$1"
    local skill_id="$2"
    jq -e ".skills[] | select(.id == \"$skill_id\")" "$manifest_path" &> /dev/null
}

filter_skills() {
    local manifest_path="$1"
    local mode="$2"
    local skill_list="$3"
    
    local result=""
    IFS=',' read -ra SKILLS_ARRAY <<< "$skill_list"
    
    for skill_id in "${SKILLS_ARRAY[@]}"; do
        if ! skill_exists "$manifest_path" "$skill_id"; then
            echo "Invalid skill ID: $skill_id" >&2
            result="invalid"
        fi
    done
    
    if [[ "$result" == "invalid" ]]; then
        return 1
    fi
    
    if [[ "$mode" == "include" ]]; then
        jq -r "[.skills[] | select(.id | IN(\"${SKILLS_ARRAY[@]}\"))]" "$manifest_path"
    else
        jq -r "[.skills[] | select(.id | IN(\"${SKILLS_ARRAY[@]}\") | not)]" "$manifest_path"
    fi
}

get_default_skills() {
    local manifest_path="$1"
    jq -r '[.skills[] | select(.required == false)]' "$manifest_path"
}
