# Design: skill-selection

## Technical Approach

Agregar selección granular de skills mediante un manifest JSON compartido entre scripts (bash/powershell) y TUI (Go). Los scripts copian solo skills seleccionados; la TUI muestra checkbox list.

## Architecture Decisions

### Decision: Shared JSON Manifest

**Choice**: Crear `configs/opencode/skills-manifest.json` que definirá los skills disponibles
**Alternatives considered**: Hardcodear en cada script, leer directorios dinámicamente
**Rationale**: Single source of truth para CLI y TUI; fácil de mantener; permite metadata (description, required)

### Decision: Flags --skills y --exclude-skills mutuamente excluyentes

**Choice**: Error si se usan ambos flags simultáneamente
**Alternatives considered**: --skills tiene precedencia, merge de ambas listas
**Rationale**: Evita confusión; UX más predecible; error temprano

## Data Flow

```
skills-manifest.json
        │
        ├──► scripts/install-opencode.sh ──► cp skills filtrados
        │              │
        ├──► scripts/install-opencode.ps1 ──► Copy-Item skills filtrados
        │
        └──► TUI (Go) ──► checkbox selection ──► skills seleccionados
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `configs/opencode/skills-manifest.json` | Create | Manifest con id, name, required, description |
| `scripts/install-opencode.sh` | Modify | Parse --skills/--exclude-skills, filtrar antes de copiar |
| `windows/scripts/install-opencode.ps1` | Modify | Parse -Skills/-ExcludeSkills, filtrar antes de copiar |
| `installer/internal/tui/model.go` | Modify | Agregar SkillSelection state + screen constant |
| `installer/internal/tui/view.go` | Modify | Agregar renderSkillSelection() con checkboxes |
| `installer/internal/tui/update.go` | Modify | Handle keypresses para toggle/check/select all |
| `installer/internal/tui/types.go` | Modify | Agregar SkillChoice struct |
| `installer/internal/tui/install.go` | Modify | Llamar install-opencode.ps1 con flags según selección |

## Interfaces / Contracts

### skills-manifest.json Schema

```json
{
  "skills": [
    {
      "id": "string",
      "name": "string",
      "required": false,
      "description": "string",
      "source": "local | url",
      "path": "string"
    }
  ]
}
```

### Go Types

```go
type SkillChoice struct {
    ID          string
    Name        string
    Required    bool
    Description string
    Source      string  // "local" or "url"
    Path        string
    Selected    bool
}

const ScreenSkillSelect Screen = "skill-select"
```

### Installation Logic

```
For each selected skill:
  IF source == "local":
    cp REPO_ROOT/configs/opencode/{path} → opencode_dir/skills/{id}/
  IF source == "url":
    curl {path} → opencode_dir/skills/{id}/SKILL.md
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | parseSkillsFlag, filterSkills | Tabler tests en scripts |
| Integration | manifest parsing | Test con manifest válido e inválido |
| E2E | TUI checkbox selection | Manual test + integration con Bubble Tea test utils |

## Migration / Rollout

No migration required. Comportamiento default (`--skills=all`) preserva backwards compatibility.

## Open Questions

Ninguna.

## TUI Layout

Skills organizados en grupos:

```
┌─ SDD Workflow ──────────────────────┐
│  ☑ sdd-init                          │
│  ☑ sdd-explore                       │
│  ☑ sdd-propose                       │
│  ...                                 │
└──────────────────────────────────────┘

┌─ Utilities ─────────────────────────┐
│  ☐ mermaid-diagrams                 │
│  ☐ readme-docs                      │
│  ☐ skill-registry                   │
└──────────────────────────────────────┘

[ Select All ]  [ Deselect All ]
```

- Todos los skills son deseleccionables
- sdd-* van en grupo "SDD Workflow"
- El resto en "Utilities"
