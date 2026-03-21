# Design: tui-skill-cursor

## Technical Approach

Agregar indicador visual de cursor ("▸ ") al item activo en la función `renderSkillSelection()`, siguiendo el mismo patrón existente en `renderSelection()`.

## Architecture Decisions

### Decision: Cursor Prefix Character

**Choice**: Usar "▸ " (triangular filled) como prefijo de cursor
**Alternatives considered**: "> " (ASCII), "→ " (arrow)
**Rationale**: Ya existe en `renderSelection()` con "▸ ", mantener consistencia visual en toda la app

## Data Flow

No hay cambio en data flow. El cursor ya está disponible en `m.Cursor` y el código ya calcula `globalIdx` correctamente. Solo falta agregar el prefijo visual.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `installer/internal/tui/view.go` | Modify | Agregar cursor prefix en renderSkillSelection() para items activos |

## Interfaces / Contracts

Cambio simple en render function existente. No hay cambios en interfaces.

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Manual | Verificar cursor visible en skill selection | Ejecución del installer |

## Migration / Rollout

No migration required. Cambio visual puro.

## Open Questions

- [ ] None