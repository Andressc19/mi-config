# Tasks: skill-selection

## Phase 1: Infrastructure

- [x] 1.1 Crear `configs/opencode/skills-manifest.json` con schema: id, name, required, description, source, path
- [x] 1.2 Agregar todos los skills existentes (sdd-*, mermaid-diagrams, readme-docs, skill-registry) al manifest
- [x] 1.3 Definir grupos en manifest: "sdd-workflow" y "utilities"

## Phase 2: Shell Scripts

- [x] 2.1 Agregar función `parse_skills_manifest()` en `scripts/lib-detect.sh`
- [x] 2.2 Agregar función `filter_skills()` que filtra por flags
- [x] 2.3 Implementar parseo de `--skills` y `--exclude-skills` en `scripts/install-opencode.sh`
- [x] 2.4 Modificar copy logic para usar filtrado de skills
- [x] 2.5 Implementar instalación de skills `source: "local"` (copiar de repo)
- [x] 2.6 Implementar instalación de skills `source: "url"` (curl download)
- [x] 2.7 Repetir 2.1-2.6 para `windows/scripts/install-opencode.ps1`

## Phase 3: TUI (Go)

- [x] 3.1 Agregar `SkillChoice` struct en `installer/internal/tui/model.go`
- [x] 3.2 Agregar `ScreenSkillSelect` constant en `installer/internal/tui/model.go`
- [x] 3.3 Crear `renderSkillSelection()` en `installer/internal/tui/view.go` con grupos SDD/Utilities
- [x] 3.4 Implementar keypress handling para toggle, select all, deselect all en `installer/internal/tui/interactive.go`
- [x] 3.5 Agregar skill selection en flow de install (después de Component selection)
- [x] 3.6 Modificar `installer/internal/tui/installer.go` para pasar skills seleccionados al script

## Phase 4: Testing

- [x] 4.1 ✅ jq disponible
- [x] 4.2 ✅ JSON manifest válido
- [x] 4.3 ✅ Scripts bash sintaxis OK
- [x] 4.4 ✅ Scripts PowerShell sintaxis OK
- [x] 4.5 ✅ Go build exitoso
- [x] 4.6 ✅ Test integration: manifest parsing OK

## Phase 5: Cleanup

- [ ] 5.1 Commit de cambios
- [ ] 5.2 Push y merge
