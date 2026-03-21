# Tasks: tui-multiplatform

## Phase 1: System Detection

- [x] 1.1 Agregar `HasPacman` field en `installer/internal/system/system.go`
- [x] 1.2 Agregar detección de pacman en `Detect()`: `info.HasPacman = CommandExists("pacman")`
- [x] 1.3 Agregar función `GetPackageManager()` que retorne struct con Name y InstallCmd según OS

## Phase 2: Installer Logic

- [x] 2.1 Modificar `installOpencode()` en `installer/internal/tui/installer.go` para usar `sysInfo.GetPackageManager()`
- [x] 2.2 Actualizar lógica de Neovim installation para usar brew (macOS) y apt (Linux)
- [x] 2.3 Actualizar lógica de Docker installation para usar brew (macOS) y apt (Linux)

## Phase 3: Script Execution

- [x] 3.1 Verificar que `scripts/*.sh` se llaman correctamente en Linux/macOS para skills
- [x] 3.2 Agregar fallback si bash no está disponible (recomendado)

## Phase 4: Verification

- [x] 4.1 Compilar: `cd installer && GOOS=linux go build ./...`
- [x] 4.2 Compilar: `cd installer && GOOS=darwin go build ./...`
- [x] 4.3 Verificar que Windows sigue funcionando