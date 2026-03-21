# Design: tui-terminal-exit

## Technical Approach

Asegurar que el programa restablezca el terminal correctamente al salir, usando las herramientas proporcionadas por Bubble Tea y un deferred cleanup.

## Architecture Decisions

### Decision: Terminal Restoration Method

**Choice**: Usar `tea.WithAltScreen()` correctamente y garantizar que el programa termine limpiamente
**Alternatives considered**: Manual terminal reset con `fmt.Print("\033[?1049l")`
**Rationale**: Bubble Tea ya maneja esto internamente; el problema puede ser que el programa no sale limpiamente

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `installer/cmd/mi-config-installer/main.go` | Modified | Agregar cleanup explícito y asegurar exit(0) |

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Manual | Ejecutar exe y verificar prompt | Verificar que terminal se restaura |

## Open Questions

- [ ] ¿El problema es en Windows específico o跨平台?