#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/lib-detect.sh"

SKILLS_MODE=""
SKILLS_LIST=""

parse_skills_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skills)
                SKILLS_MODE="include"
                SKILLS_LIST="$2"
                shift 2
                ;;
            --exclude-skills)
                SKILLS_MODE="exclude"
                SKILLS_LIST="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
}

install_opencode() {
    log_info "Installing opencode..."

    local opencode_dir="$HOME/.config/opencode"
    local opencode_bin="$HOME/.local/bin/opencode"
    local manifest_path="$REPO_ROOT/configs/opencode/skills-manifest.json"

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
        
        if [[ -f "$manifest_path" ]] && [[ -n "$SKILLS_MODE" ]]; then
            install_skills_with_filter "$opencode_dir" "$manifest_path"
        else
            cp -r "$REPO_ROOT/configs/opencode/"* "$opencode_dir/"
            log_success "Copied opencode config to $opencode_dir"
        fi
    fi

    mkdir -p "$HOME/.local/bin"
    if [[ ! -f "$opencode_bin" ]]; then
        ln -sf "$(which opencode)" "$opencode_bin" 2>/dev/null || true
    fi

    log_success "opencode installation complete"
}

install_skills_with_filter() {
    local opencode_dir="$1"
    local manifest_path="$2"
    
    if ! command -v jq &> /dev/null; then
        log_warn "jq not found, installing all skills"
        cp -r "$REPO_ROOT/configs/opencode/"* "$opencode_dir/"
        return
    fi
    
    if [[ -n "$SKILLS_MODE" ]]; then
        if [[ -n "$SKILLS_LIST" ]]; then
            IFS=',' read -ra SKILLS_ARRAY <<< "$SKILLS_LIST"
            
            for skill_id in "${SKILLS_ARRAY[@]}"; do
                if ! skill_exists "$manifest_path" "$skill_id"; then
                    log_error "Invalid skill ID: $skill_id"
                    return 1
                fi
            done
            
            if [[ "$SKILLS_MODE" == "include" ]]; then
                log_info "Installing selected skills: $SKILLS_LIST"
                local skill_ids_pattern=$(IFS='|'; echo "${SKILLS_ARRAY[*]}")
                jq -r ".skills[] | select(.id | inside(\"${skill_ids_pattern// /|}\")) | .path" "$manifest_path"
            else
                log_info "Excluding skills: $SKILLS_LIST"
                local skill_ids_pattern=$(IFS='|'; echo "${SKILLS_ARRAY[*]}")
                jq -r ".skills[] | select(.id | inside(\"${skill_ids_pattern// /|}\") | not) | .path" "$manifest_path"
            fi
        else
            log_error "No skills specified with --skills or --exclude-skills"
            return 1
        fi
    fi
    
    install_selected_skills "$opencode_dir" "$manifest_path"
}

install_selected_skills() {
    local opencode_dir="$1"
    local manifest_path="$2"
    local skills_json=""
    
    if [[ "$SKILLS_MODE" == "include" ]]; then
        IFS=',' read -ra SKILLS_ARRAY <<< "$SKILLS_LIST"
        local skill_ids_pattern=$(IFS='|'; echo "${SKILLS_ARRAY[*]}")
        skills_json=$(jq -r ".skills[] | select(.id | inside(\"${skill_ids_pattern// /|}\"))" "$manifest_path")
    elif [[ "$SKILLS_MODE" == "exclude" ]]; then
        IFS=',' read -ra SKILLS_ARRAY <<< "$SKILLS_LIST"
        local skill_ids_pattern=$(IFS='|'; echo "${SKILLS_ARRAY[*]}")
        skills_json=$(jq -r ".skills[] | select(.id | inside(\"${skill_ids_pattern// /|}\") | not)" "$manifest_path")
    else
        skills_json=$(jq -r ".skills[] | select(.required == false)" "$manifest_path")
    fi
    
    local required_skills=$(jq -r ".skills[] | select(.required == true)" "$manifest_path")
    
    while IFS= read -r skill_json; do
        [[ -z "$skill_json" ]] && continue
        
        local skill_id=$(echo "$skill_json" | jq -r '.id')
        local skill_source=$(echo "$skill_json" | jq -r '.source')
        local skill_path=$(echo "$skill_json" | jq -r '.path')
        
        install_skill "$opencode_dir" "$skill_id" "$skill_source" "$skill_path"
    done <<< "$skills_json"
    
    while IFS= read -r skill_json; do
        [[ -z "$skill_json" ]] && continue
        
        local skill_id=$(echo "$skill_json" | jq -r '.id')
        local skill_source=$(echo "$skill_json" | jq -r '.source')
        local skill_path=$(echo "$skill_json" | jq -r '.path')
        
        install_skill "$opencode_dir" "$skill_id" "$skill_source" "$skill_path"
    done <<< "$required_skills"
}

install_skill() {
    local opencode_dir="$1"
    local skill_id="$2"
    local skill_source="$3"
    local skill_path="$4"
    
    mkdir -p "$opencode_dir/skills/$skill_id"
    
    case "$skill_source" in
        local)
            local src_path="$REPO_ROOT/configs/opencode/$skill_path"
            if [[ -f "$src_path" ]]; then
                cp -r "$src_path" "$opencode_dir/skills/$skill_id/SKILL.md"
                log_info "Installed skill: $skill_id (local)"
            elif [[ -d "$src_path" ]]; then
                cp -r "$src_path"/* "$opencode_dir/skills/$skill_id/"
                log_info "Installed skill: $skill_id (local)"
            fi
            ;;
        url)
            log_info "Downloading skill: $skill_id from $skill_path"
            if curl -fsSL "$skill_path" -o "$opencode_dir/skills/$skill_id/SKILL.md"; then
                log_info "Installed skill: $skill_id (url)"
            else
                log_error "Failed to download skill $skill_id from $skill_path"
            fi
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_skills_args "$@"
    install_opencode
fi