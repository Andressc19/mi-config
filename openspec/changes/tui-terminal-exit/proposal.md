# Proposal: tui-terminal-exit

## Intent

El instalador de mi-config bloquea la terminal y no la devuelve al usuario después de ejecutarse. El usuario queda atrapado en el TUI sin poder recuperar el prompt.

## Scope

### In Scope
- Asegurar que el TUI libere la terminal al salir
- Verificar cleanup correcto de recursos de Bubble Tea

### Out of Scope
- Cambios en lógica de instalación
- Modificaciones en el flujo del TUI

## Approach

Revisar el main loop en `cmd/mi-config-installer/main.go` para asegurar que el programa termine correctamente después de que el usuario salga del TUI.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `installer/cmd/mi-config-installer/main.go` | Modified | Asegurar exit limpio del programa |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Terminal quede en modo raw | Low | Reset terminal con defer |

## Rollback Plan

Revertir cambios con `git revert`.

## Dependencies

Ninguna.

## Success Criteria

- [ ] El exe muestra el TUI correctamente
- [ ] Al salir (completar o [q]), el terminal devuelve el prompt
- [ ] No queda en modo raw