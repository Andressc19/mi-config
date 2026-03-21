# Proposal: tui-skill-cursor

## Intent

El TUI no muestra visualmente cuál es el item activo con el cursor en ninguna lista. El usuario no puede saber en qué posición está al navegar con ↑/↓. Este problema aplica a TODOS los selectores del instalador.

## Scope

### In Scope
- Agregar indicador visual de cursor (`> `) en TODAS las listas del TUI
- Mantener consistencia visual en todos los selectores

### Out of Scope
- Cambios en funcionalidad de selección
- Modificaciones en lógica de instalación

## Approach

En Bubble Tea, el cursor se marca típicamente con un prefijo como "> " antes del item activo. Revisar `installer/internal/tui/view.go` y modificar todas las funciones `render*()` que renderizan listas para agregar este indicador.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `installer/internal/tui/view.go` | Modified | Agregar prefijo "> " en todas las listas renderizadas |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Ninguno | - | Cambio visual simple |

## Rollback Plan

Revertir cambios con `git revert` del commit.

## Dependencies

Ninguna.

## Success Criteria

- [ ] Al navegar con ↑/↓ en CUALQUIER lista del TUI, se ve claramente cuál está seleccionado
- [ ] El indicador de cursor es consistente en todos los selectores
