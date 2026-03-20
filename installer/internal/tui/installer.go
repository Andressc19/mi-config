package tui

import (
	"fmt"
	"os"
	"runtime"
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

	switch runtime.GOOS {
	case "windows":
		if sysInfo.HasWinget {
			SendLog(stepID, "Installing opencode via winget...")
			installCmd = "winget install --id Ananace.Opencode -e --silent"
		} else {
			SendLog(stepID, "winget not found. Please install opencode manually from https://opencode.ai")
			return nil
		}
	case "darwin":
		if sysInfo.HasBrew {
			SendLog(stepID, "Installing opencode via Homebrew...")
			installCmd = "brew install --cask opencode"
		} else {
			SendLog(stepID, "Homebrew not found. Please install opencode manually from https://opencode.ai")
			return nil
		}
	case "linux":
		SendLog(stepID, "Installing opencode via script...")
		installCmd = "curl -fsSL https://opencode.ai/install | bash"
	default:
		SendLog(stepID, "Unsupported platform for automatic installation")
		return nil
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

	SendLog(stepID, "✓ opencode installation complete")
	return nil
}

func stepInstallLazyVim(m *Model) error {
	stepID := "lazvim"
	homeDir := os.Getenv("HOME")

	SendLog(stepID, "Installing LazyVim (Neovim + configs)...")

	// Check for Neovim
	if !commandExists("nvim") {
		SendLog(stepID, "Installing Neovim...")
		switch runtime.GOOS {
		case "windows":
			if m.SystemInfo.HasWinget {
				runCommand("winget install --id Neovim.Neovim -e --silent")
			}
		case "darwin":
			if m.SystemInfo.HasBrew {
				runCommand("brew install neovim")
			}
		case "linux":
			if m.SystemInfo.HasApt {
				runCommand("sudo apt install -y neovim")
			} else if m.SystemInfo.HasDnf {
				runCommand("sudo dnf install -y neovim")
			} else {
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

	switch runtime.GOOS {
	case "windows":
		SendLog(stepID, "Please install Docker Desktop from https://docker.com/products/docker-desktop")
		return nil
	case "darwin":
		if m.SystemInfo.HasBrew {
			SendLog(stepID, "Installing Docker Desktop via Homebrew...")
			runCommand("brew install --cask docker")
		} else {
			SendLog(stepID, "Please install Docker Desktop from https://docker.com/products/docker-desktop")
			return nil
		}
	case "linux":
		if m.SystemInfo.HasApt {
			SendLog(stepID, "Installing Docker via apt...")
			runCommand("sudo apt-get update")
			runCommand("sudo apt-get install -y docker.io docker-compose")
			runCommand("sudo systemctl start docker")
			runCommand("sudo systemctl enable docker")
		} else if m.SystemInfo.HasDnf {
			SendLog(stepID, "Installing Docker via dnf...")
			runCommand("sudo dnf install -y docker docker-compose")
			runCommand("sudo systemctl start docker")
			runCommand("sudo systemctl enable docker")
		} else {
			SendLog(stepID, "Please install Docker manually from https://docs.docker.com/engine/install/")
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
		ohMyPoshCmd = "curl -s https://ohmyposh.dev/install.sh | bash"
	}

	runCommand(ohMyPoshCmd)

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
	exec := os.Executable
	if runtime.GOOS == "windows" {
		exec = "cmd.exe"
		cmd = "/c " + cmd
	} else {
		exec = "/bin/sh"
		cmd = "-c " + cmd
	}

	process := os.Command(exec, cmd)
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
