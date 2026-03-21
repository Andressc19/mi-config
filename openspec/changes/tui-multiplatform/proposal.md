# Proposal: tui-multiplatform

## Intent

El Go TUI installer (`installer/`) solo funciona en Windows porque está hardcoded para usar `winget` y PowerShell scripts. El código debería funcionar en Linux y macOS ya que Bubble Tea es multiplataforma. Actualmente los usuarios de Linux/macOS deben usar los scripts `.sh` en vez del TUI.

## Scope

### In Scope
- Agregar detección de OS en el installer (Linux, macOS, Windows)
- Usar `brew` en macOS para instalar paquetes
- Usar `apt`/`dnf`/`pacman` en Linux para instalar paquetes
- Llamar a scripts bash en `scripts/` para Linux/macOS
- Mantener funcionalidad existente en Windows

### Out of Scope
- Cambiar Bubble Tea framework
- Agregar nuevas funcionalidades al TUI
- Modificar los scripts bash/PowerShell existentes

## Approach

Usar `runtime.GOOS` para detectar la plataforma y abstraer la lógica de instalación en funciones separadas por OS. Crear una interfaz `PackageManager` que implemente `winget` (Windows), `brew` (macOS), y `apt`/`dnf`/`pacman` (Linux).

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `installer/internal/system/system.go` | Modified | Agregar detección de package manager por OS |
| `installer/internal/tui/installer.go` | Modified | Usar package manager correcto según OS |
| `installer/internal/tui/installer.go` | Modified | Llamar a scripts bash en Linux/macOS |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Scripts bash no disponibles | Low | Verificar existencia antes de ejecutar |
| Diferentes nombres de paquetes | Medium | Tabla de mapeo por distro Linux |

## Rollback Plan

Revertir cambios con `git revert`.

## Dependencies

- Scripts bash existentes en `scripts/`
- Detección de OS ya existe en `system.go`

## Success Criteria

- [ ] TUI compila y ejecuta en Linux
- [ ] TUI compila y ejecuta en macOS
- [ ] Instalación de paquetes funciona en cada plataforma
- [ ] Scripts bash se llaman correctamente en Linux/macOS