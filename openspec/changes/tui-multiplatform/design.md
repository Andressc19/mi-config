# Design: tui-multiplatform

## Technical Approach

El código ya tiene estructura multiplataforma con `runtime.GOOS` switch. Necesitamos extender la lógica para:
1. Usar package managers nativos de cada OS (apt/dnf/pacman/brew)
2. Llamar scripts bash en Linux/macOS y PowerShell en Windows

## Architecture Decisions

### Decision: Package Manager Abstraction

**Choice**: Usar struct `PackageManager` con campos por OS
**Alternatives considered**: Interface con métodos
**Rationale**: Más simple para este caso, ya existe detección en `system.go`

### Decision: Script Path Convention

**Choice**: Mantener estructura actual: `scripts/` para bash, `windows/scripts/` para PowerShell
**Alternatives considered**: Unificar en `scripts/{os}/`
**Rationale**: Ya funciona, no romper compatibilidad

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `installer/internal/system/system.go` | Modify | Agregar `HasPacman` y `PackageManager` field |
| `installer/internal/tui/installer.go` | Modify | Usar package manager correcto por OS |

## Interfaces / Contracts

```go
type PackageManager struct {
    Name        string  // "winget", "brew", "apt", "dnf", "pacman"
    InstallCmd  string  // "install", "install -y"
    HasPkgMgr   bool    // Si está disponible
}

// En system.go, agregar:
func (s *SystemInfo) GetPackageManager() *PackageManager
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Manual | TUI en cada plataforma | Compilar y ejecutar |

## Open Questions

- [ ] ¿Soportar todas las distros o solo las principales (Debian, Fedora, Arch)?