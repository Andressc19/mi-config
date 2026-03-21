# Tasks: tui-terminal-exit

## Phase 1: Investigation

- [x] 1.1 Verificar si el problema es con `tea.WithAltScreen()` o con el programa no terminando
- [x] 1.2 Revisar si Bubble Tea maneja cleanup automáticamente al salir

## Phase 2: Implementation

- [x] 2.1 Agregar `defer` para resetear terminal si es necesario
- [x] 2.2 Verificar que `p.Run()` devuelve sin error y el programa hace `os.Exit(0)`
- [x] 2.3 Retornar `tea.Quit` cuando `m.Quitting` es true

## Phase 3: Verification

- [x] 3.1 Compilar: `cd installer && go build ./...`
- [x] 3.2 Ejecutar exe en Windows y verificar que devuelve el prompt al salir