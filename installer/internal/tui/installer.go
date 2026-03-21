package tui

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/mi-config/installer/internal/system"
)

type StepError struct {
	StepID      string
	StepName    string
	Description string
	Cause       error
}

func (e *StepError) Error() string {
	return fmt.Sprintf("Step '%s' failed: %v", e.StepName, e.Cause)
}

func executeStep(stepID string, m *Model) error {
	switch stepID {
	case "opencode":
		return stepInstallOpencode(m)
	case "lazvim":
		return stepInstallLazyVim(m)
	case "docker":
		return stepInstallDocker(m)
	case "shell":
		return stepInstallShell(m)
	case "devtools":
		return stepInstallDevTools(m)
	case "engram-migrate":
		return stepEngramMigrate(m)
	default:
		return fmt.Errorf("unknown step: %s", stepID)
	}
}

func stepInstallOpencode(m *Model) error {
	stepID := "opencode"
	sysInfo := m.SystemInfo

	if sysInfo.HasOpencode {
		SendLog(stepID, "opencode already installed, skipping...")
		return nil
	}

	SendLog(stepID, "Detecting platform...")

	var installCmd string
	pkgMgr := sysInfo.GetPackageManager()
	if pkgMgr.HasPkgMgr {
		switch pkgMgr.Name {
		case "winget":
			SendLog(stepID, "Installing opencode via winget...")
			installCmd = "winget install --id Ananace.Opencode -e --silent"
		case "brew":
			SendLog(stepID, "Installing opencode via Homebrew...")
			installCmd = "brew install --cask opencode"
		case "apt", "dnf", "pacman":
			// For Linux, we still use the official script
			SendLog(stepID, "Installing opencode via script...")
			if !system.CommandExists("bash") {
				SendLog(stepID, "bash not found. Please install bash to install opencode.")
				installCmd = ""
			} else {
				installCmd = "curl -fsSL https://opencode.ai/install | bash"
			}
		default:
			SendLog(stepID, fmt.Sprintf("Unsupported package manager %s, falling back to script...", pkgMgr.Name))
			if !system.CommandExists("bash") {
				SendLog(stepID, "bash not found. Please install bash to install opencode.")
				installCmd = ""
			} else {
				installCmd = "curl -fsSL https://opencode.ai/install | bash"
			}
		}
	} else {
		// No package manager, fallback to script for Linux, else manual
		if runtime.GOOS == "linux" {
			SendLog(stepID, "Installing opencode via script...")
			if !system.CommandExists("bash") {
				SendLog(stepID, "bash not found. Please install bash to install opencode.")
				installCmd = ""
			} else {
				installCmd = "curl -fsSL https://opencode.ai/install | bash"
			}
		} else {
			SendLog(stepID, "Package manager not found. Please install opencode manually from https://opencode.ai")
			return nil
		}
	}

	SendLog(stepID, "Installing Engram...")
	engramCmd := "go install github.com/anomalyco/engram/cmd/engram@latest"
	if err := runCommand(engramCmd); err != nil {
		SendLog(stepID, fmt.Sprintf("Warning: Could not install Engram: %v", err))
	}

	if installCmd != "" {
		SendLog(stepID, fmt.Sprintf("Running: %s", installCmd))
		if err := runCommand(installCmd); err != nil {
			SendLog(stepID, fmt.Sprintf("Warning: %v", err))
		}
	}

	// Install skills
	if len(m.Choices.SelectedSkills) > 0 {
		skillsList := strings.Join(m.Choices.SelectedSkills, ",")
		SendLog(stepID, fmt.Sprintf("Installing selected skills: %s", skillsList))

		repoRoot := getRepoRoot()
		var skillsCmd string
		switch runtime.GOOS {
		case "windows":
			skillsCmd = fmt.Sprintf(`pwsh -File "%s/windows/scripts/install-opencode.ps1" -Skills %s`, repoRoot, skillsList)
		default:
			if !system.CommandExists("bash") {
				SendLog(stepID, "bash not found. Please install bash to install skills.")
			} else {
				skillsCmd = fmt.Sprintf(`bash "%s/scripts/install-opencode.sh" --skills %s`, repoRoot, skillsList)
			}
		}

		if skillsCmd != "" {
			if err := runCommand(skillsCmd); err != nil {
				SendLog(stepID, fmt.Sprintf("Warning: Skills installation had issues: %v", err))
			}
		}
	}

	SendLog(stepID, "✓ opencode installation complete")
	return nil
}

func getRepoRoot() string {
	// Try to find the repo root
	dir, _ := os.Getwd()
	for {
		if _, err := os.Stat(filepath.Join(dir, "configs", "opencode", "skills-manifest.json")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}
	return ""
}

func stepInstallLazyVim(m *Model) error {
	stepID := "lazvim"
	homeDir := os.Getenv("HOME")

	SendLog(stepID, "Installing LazyVim (Neovim + configs)...")

	// Check for Neovim
	if !commandExists("nvim") {
		SendLog(stepID, "Installing Neovim...")
		pkgMgr := m.SystemInfo.GetPackageManager()
		if pkgMgr.HasPkgMgr {
			switch pkgMgr.Name {
			case "winget":
				runCommand("winget install --id Neovim.Neovim -e --silent")
			case "brew":
				runCommand("brew install neovim")
			case "apt":
				runCommand("sudo apt install -y neovim")
			case "dnf":
				runCommand("sudo dnf install -y neovim")
			case "pacman":
				runCommand("sudo pacman -S neovim")
			default:
				// Unknown package manager, fallback to manual
				if runtime.GOOS == "linux" {
					runCommand("curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz")
					runCommand("sudo tar -C /usr/local --strip-components=1 -xzf nvim-linux64.tar.gz")
				}
			}
		} else {
			// No package manager
			if runtime.GOOS == "linux" {
				runCommand("curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz")
				runCommand("sudo tar -C /usr/local --strip-components=1 -xzf nvim-linux64.tar.gz")
			}
		}
	}

	// Install LazyVim
	SendLog(stepID, "Downloading LazyVim starter...")
	lazyVimDir := fmt.Sprintf("%s/.config/nvim", homeDir)
	os.MkdirAll(lazyVimDir, 0755)

	// Clone LazyVim
	runCommand(fmt.Sprintf("git clone --depth 1 https://github.com/LazyVim/starter %s", lazyVimDir))
	runCommand(fmt.Sprintf("mv %s/init.lua.tpl %s/init.lua 2>/dev/null || true", lazyVimDir, lazyVimDir))

	SendLog(stepID, "✓ LazyVim installation complete")
	return nil
}

func stepInstallDocker(m *Model) error {
	stepID := "docker"

	if m.SystemInfo.HasDocker {
		SendLog(stepID, "Docker already installed, skipping...")
		return nil
	}

	SendLog(stepID, "Installing Docker...")

	pkgMgr := m.SystemInfo.GetPackageManager()
	if pkgMgr.HasPkgMgr {
		switch pkgMgr.Name {
		case "winget":
			SendLog(stepID, "Please install Docker Desktop from https://docker.com/products/docker-desktop")
			return nil
		case "brew":
			SendLog(stepID, "Installing Docker Desktop via Homebrew...")
			runCommand("brew install --cask docker")
		case "apt":
			SendLog(stepID, "Installing Docker via apt...")
			runCommand("sudo apt-get update")
			runCommand("sudo apt-get install -y docker.io docker-compose")
			runCommand("sudo systemctl start docker")
			runCommand("sudo systemctl enable docker")
		case "dnf":
			SendLog(stepID, "Installing Docker via dnf...")
			runCommand("sudo dnf install -y docker docker-compose")
			runCommand("sudo systemctl start docker")
			runCommand("sudo systemctl enable docker")
		case "pacman":
			SendLog(stepID, "Installing Docker via pacman...")
			runCommand("sudo pacman -S docker docker-compose")
			runCommand("sudo systemctl start docker")
			runCommand("sudo systemctl enable docker")
		default:
			SendLog(stepID, "Please install Docker manually from https://docs.docker.com/engine/install/")
			return nil
		}
	} else {
		// No package manager
		if runtime.GOOS == "linux" {
			SendLog(stepID, "Please install Docker manually from https://docs.docker.com/engine/install/")
			return nil
		} else {
			SendLog(stepID, "Please install Docker Desktop from https://docker.com/products/docker-desktop")
			return nil
		}
	}

	SendLog(stepID, "✓ Docker installation complete")
	return nil
}

func stepInstallShell(m *Model) error {
	stepID := "shell"

	SendLog(stepID, "Installing PowerShell...")

	switch runtime.GOOS {
	case "windows":
		if !m.SystemInfo.HasPowerShell {
			SendLog(stepID, "PowerShell should be pre-installed on Windows 10/11")
		}
	case "darwin":
		if !m.SystemInfo.HasPowerShell && m.SystemInfo.HasBrew {
			runCommand("brew install --cask powershell")
		}
	case "linux":
		if m.SystemInfo.HasApt {
			runCommand("sudo apt-get update")
			runCommand("sudo apt-get install -y powershell")
		} else if m.SystemInfo.HasDnf {
			runCommand("sudo dnf install -y powershell")
		}
	}

	SendLog(stepID, "Installing oh-my-posh...")
	ohMyPoshCmd := "winget install --id OhMyPosh.OhMyPosh -e --silent"
	if runtime.GOOS == "darwin" && m.SystemInfo.HasBrew {
		ohMyPoshCmd = "brew install oh-my-posh"
	} else if runtime.GOOS == "linux" {
		if !system.CommandExists("bash") {
			SendLog(stepID, "bash not found. Please install bash to install oh-my-posh.")
			ohMyPoshCmd = ""
		} else {
			ohMyPoshCmd = "curl -s https://ohmyposh.dev/install.sh | bash"
		}
	}

	if ohMyPoshCmd != "" {
		runCommand(ohMyPoshCmd)
	}

	// Create default PowerShell profile
	homeDir := os.Getenv("HOME")
	psProfileDir := fmt.Sprintf("%s/.config/powershell", homeDir)
	os.MkdirAll(psProfileDir, 0755)

	profileContent := `# mi-config PowerShell Profile
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/paradox.omp.json" | Invoke-Expression

# Aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String

# Functions
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
`

	profilePath := fmt.Sprintf("%s/Microsoft.PowerShell_profile.ps1", psProfileDir)
	os.WriteFile(profilePath, []byte(profileContent), 0644)

	SendLog(stepID, "✓ Shell installation complete")
	return nil
}

func stepInstallDevTools(m *Model) error {
	stepID := "devtools"

	SendLog(stepID, "Installing DevTools...")

	switch runtime.GOOS {
	case "windows":
		if m.SystemInfo.HasWinget {
			SendLog(stepID, "Installing Git via winget...")
			runCommand("winget install --id Git.Git -e --source winget --silent")

			SendLog(stepID, "Installing VS Code via winget...")
			runCommand("winget install --id Microsoft.VisualStudioCode -e --source winget --silent")
		} else {
			SendLog(stepID, "winget not found. Please install Git and VS Code manually.")
		}

	case "darwin":
		if m.SystemInfo.HasBrew {
			SendLog(stepID, "Installing Git via Homebrew...")
			runCommand("brew install git")

			SendLog(stepID, "Installing VS Code via Homebrew...")
			runCommand("brew install --cask visual-studio-code")
		}

	case "linux":
		if m.SystemInfo.HasApt {
			SendLog(stepID, "Installing Git and VS Code via apt...")
			runCommand("sudo apt-get update")
			runCommand("sudo apt-get install -y git curl wget")
			runCommand("sudo snap install --classic code")
		} else if m.SystemInfo.HasDnf {
			SendLog(stepID, "Installing Git via dnf...")
			runCommand("sudo dnf install -y git curl wget")
			runCommand("sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc")
			runCommand("sudo sh -c 'echo -e \"[code]\\nname=Visual Studio Code\\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\\nenabled=1\\ngpgcheck=1\\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" > /etc/yum.repos.d/vscode.repo'")
			runCommand("sudo dnf check-update && sudo dnf install -y code")
		} else {
			SendLog(stepID, "Installing Git...")
			runCommand("sudo pacman -S git curl wget")
		}
	}

	SendLog(stepID, "✓ DevTools installation complete")
	return nil
}

func runCommand(cmd string) error {
	var shell string
	var shellArg string
	if runtime.GOOS == "windows" {
		shell = "cmd.exe"
		shellArg = "/c"
	} else {
		shell = "/bin/sh"
		shellArg = "-c"
	}

	process := exec.Command(shell, shellArg, cmd)
	process.Stdout = os.Stdout
	process.Stderr = os.Stderr
	process.Stdin = os.Stdin

	return process.Run()
}

func commandExists(cmd string) bool {
	_, err := os.Stat(cmd)
	if err == nil {
		return true
	}
	return false
}

func stepEngramMigrate(m *Model) error {
	stepID := "engram-migrate"

	sourcePath := m.Choices.EngramSourcePath
	if sourcePath == "" {
		engramInfo := m.SystemInfo.Engram
		if engramInfo.HasEngram {
			sourcePath = engramInfo.EngramPath
		} else if engramInfo.HasBackup {
			sourcePath = engramInfo.BackupPath
		}
	}

	if sourcePath == "" {
		SendLog(stepID, "No Engram installation or backup found, skipping...")
		return nil
	}

	SendLog(stepID, fmt.Sprintf("Migrating Engram from: %s", sourcePath))

	isWSLPath := strings.HasPrefix(sourcePath, `\\wsl$`) || strings.Contains(sourcePath, "/mnt/c/")
	isWindowsToWSL := runtime.GOOS == "linux" && m.SystemInfo.IsWSL && strings.Contains(sourcePath, "/mnt/c/")

	if isWSLPath || isWindowsToWSL {
		SendLog(stepID, "Detected cross-OS migration, copying files...")
		tempDir := os.TempDir()
		tempPath := filepath.Join(tempDir, "engram-migrate-temp")
		os.MkdirAll(tempPath, 0755)

		var copyCmd string
		if isWSLPath {
			copyCmd = fmt.Sprintf("cp \"%s\" \"%s/\" 2>/dev/null || cp %s/* \"%s/\" 2>/dev/null || true", sourcePath, tempPath, filepath.Dir(sourcePath), tempPath)
		} else {
			copyCmd = fmt.Sprintf("cp -r %s \"%s/\"", sourcePath, tempPath)
		}
		runCommand(copyCmd)

		sourcePath = tempPath
	}

	if !commandExists("engram") {
		SendLog(stepID, "Installing Engram CLI first...")
		installCmd := "go install github.com/anomalyco/engram/cmd/engram@latest"
		if err := runCommand(installCmd); err != nil {
			SendLog(stepID, fmt.Sprintf("Warning: Could not install Engram CLI: %v", err))
		}
	}

	SendLog(stepID, "Importing Engram data...")
	importCmd := fmt.Sprintf("engram import \"%s\"", sourcePath)
	if err := runCommand(importCmd); err != nil {
		SendLog(stepID, fmt.Sprintf("Warning: Import may have had issues: %v", err))
	}

	sessionCount := countEngramItems(sourcePath, "sessions")
	obsCount := countEngramItems(sourcePath, "observations")
	SendLog(stepID, fmt.Sprintf("✓ Engram migration complete: %d sessions, %d observations imported", sessionCount, obsCount))

	return nil
}

func countEngramItems(path string, itemType string) int {
	if _, err := os.Stat(path); err != nil {
		return 0
	}

	switch itemType {
	case "sessions":
		if files, err := filepath.Glob(filepath.Join(path, "*.session*")); err == nil {
			return len(files)
		}
	case "observations":
		if files, err := filepath.Glob(filepath.Join(path, "*.obs*")); err == nil {
			return len(files)
		}
	}

	entries, err := os.ReadDir(path)
	if err != nil {
		return 0
	}
	count := 0
	for _, entry := range entries {
		if !entry.IsDir() {
			count++
		}
	}
	return count
}
