# Tasks: tui-skill-cursor

## Phase 1: Implementation

- [x] 1.1 Modificar `renderSkillSelection()` en `installer/internal/tui/view.go` para agregar "▸ " prefix al item con cursor activo (igual que en `renderSelection()`)
- [x] 1.2 Compilar el proyecto para verificar sintaxis: `cd installer && go build ./...`
- [x] 1.3 Agregar cursor prefix en `renderOptions()` (step 2 - component selection)

## Phase 2: Verification

- [ ] 2.1 Ejecutar installer y verificar que el cursor es visible al navegar skills con ↑/↓
- [ ] 2.2 Verificar que el cursor sigue siendo visible al navegar entre grupos SDD/Utilities