# Delta for Installer

## ADDED Requirements

### Requirement: Multi-Platform Package Manager

The installer MUST detect the operating system and use the appropriate package manager.

The system MUST:
- Use `winget` on Windows
- Use `brew` on macOS
- Use `apt`, `dnf`, or `pacman` on Linux (in that priority order)

#### Scenario: Windows package installation

- GIVEN the installer is running on Windows
- WHEN installing opencode
- THEN it MUST use `winget install --id Ananace.Opencode -e --silent`

#### Scenario: macOS package installation

- GIVEN the installer is running on macOS
- WHEN installing opencode
- THEN it MUST use `brew install opencode`

#### Scenario: Linux package installation (Debian/Ubuntu)

- GIVEN the installer is running on Debian-based Linux
- WHEN installing opencode
- THEN it MUST use the appropriate install script from `scripts/`

### Requirement: Platform-Specific Script Execution

The installer MUST call platform-specific scripts for installation steps.

The system MUST:
- Call `scripts/*.sh` on Linux and macOS
- Call `windows/scripts/*.ps1` on Windows

#### Scenario: Install opencode on Linux

- GIVEN the installer is running on Linux
- AND user selects opencode installation
- THEN it MUST execute `scripts/install-opencode.sh`

#### Scenario: Install opencode on Windows

- GIVEN the installer is running on Windows
- AND user selects opencode installation
- THEN it MUST execute `windows/scripts/install-opencode.ps1`

## MODIFIED Requirements

### Requirement: System Detection

The system detection MUST include package manager availability for each OS.

(Previously: Only detected OS type)

#### Scenario: Detect package manager on macOS

- GIVEN the installer starts on macOS
- THEN it MUST detect if `brew` is installed
- AND set `HasBrew` flag accordingly

#### Scenario: Detect package manager on Linux

- GIVEN the installer starts on Linux
- THEN it MUST detect available package manager (apt/dnf/pacman)
- AND store the first available one