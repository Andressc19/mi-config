package tui

import (
	"fmt"
	"os"

	"github.com/mi-config/installer/internal/system"
	tea "github.com/charmbracelet/bubbletea"
)

type Screen int

const (
	ScreenWelcome Screen = iota
	ScreenMainMenu
	ScreenOSSelect
	ScreenOptions
	ScreenInstalling
	ScreenComplete
	ScreenError
)

type InstallStep struct {
	ID          string
	Name        string
	Description string
	Status      StepStatus
	Progress    float64
	Error       error
}

type StepStatus int

const (
	StatusPending StepStatus = iota
	StatusRunning
	StatusDone
	StatusFailed
	StatusSkipped
)

type ComponentSelection struct {
	Opencode bool
	LazyVim  bool
	Docker   bool
	Shell    bool
	DevTools bool
}

type UserChoices struct {
	OS         string
	Component  ComponentSelection
	CreateBackup bool
}

type Model struct {
	Screen      Screen
	PrevScreen  Screen
	Width       int
	Height      int
	SystemInfo  *system.SystemInfo
	Choices     UserChoices
	Steps       []InstallStep
	CurrentStep int
	Cursor      int
	ErrorMsg    string
	ShowDetails bool
	LogLines    []string
	Quitting    bool
	Program     *tea.Program
	SpinnerFrame int
}

func NewModel() Model {
	return Model{
		Screen:        ScreenWelcome,
		PrevScreen:    ScreenWelcome,
		Width:         80,
		Height:        24,
		SystemInfo:    system.Detect(),
		Choices:       UserChoices{},
		Steps:         []InstallStep{},
		CurrentStep:   0,
		Cursor:        0,
		ShowDetails:   false,
		LogLines:      []string{},
		SpinnerFrame:  0,
	}
}

// Init implements tea.Model - required method
func (m Model) Init() tea.Cmd {
	return nil
}

func (m *Model) SetProgram(p *tea.Program) {
	m.Program = p
}

var globalProgram *tea.Program

func SetGlobalProgram(p *tea.Program) {
	globalProgram = p
}

var nonInteractiveMode bool

func SetNonInteractiveMode(enabled bool) {
	nonInteractiveMode = enabled
}

func SendLog(stepID string, log string) {
	if nonInteractiveMode {
		if os.Getenv("MI_CONFIG_VERBOSE") == "1" {
			fmt.Printf("    %s\n", log)
		}
		return
	}
	if globalProgram != nil {
		globalProgram.Send(stepProgressMsg{
			stepID: stepID,
			log:    log,
		})
	}
}

func (m *Model) SendLog(stepID string, log string) {
	SendLog(stepID, log)
}

func (m Model) GetCurrentOptions() []string {
	switch m.Screen {
	case ScreenMainMenu:
		return []string{
			"🚀 Start Installation",
			"📚 Learn More",
			"❌ Exit",
		}
	case ScreenOSSelect:
		options := []string{"Windows", "macOS", "Linux", "WSL"}
		if m.SystemInfo.OS == system.OSWindows {
			options[0] = "Windows (detected)"
		} else if m.SystemInfo.OS == system.OSMac {
			options[1] = "macOS (detected)"
		} else if m.SystemInfo.OS == system.OSLinux {
			options[2] = "Linux (detected)"
		} else if m.SystemInfo.OS == system.OSWSL {
			options[3] = "WSL (detected)"
		}
		return options
	case ScreenOptions:
		return []string{
			"⏣  opencode + Engram",
			"⌨️  LazyVim (Neovim)",
			"🐳 Docker",
			"🐚 Shell (PowerShell + oh-my-posh)",
			"🔧 DevTools (Git, VS Code, etc)",
		}
	default:
		return []string{}
	}
}

func (m Model) GetScreenTitle() string {
	switch m.Screen {
	case ScreenWelcome:
		return "Welcome to mi-config Installer"
	case ScreenMainMenu:
		return "Main Menu"
	case ScreenOSSelect:
		return "Step 1: Select Your Operating System"
	case ScreenOptions:
		return "Step 2: Choose Components to Install"
	case ScreenInstalling:
		return "Installing..."
	case ScreenComplete:
		return "Installation Complete!"
	case ScreenError:
		return "Error"
	default:
		return ""
	}
}

func (m Model) GetScreenDescription() string {
	switch m.Screen {
	case ScreenOSSelect:
		detected := m.SystemInfo.OSName
		return "Detected: " + detected
	case ScreenOptions:
		return "Select the components you want to install"
	default:
		return ""
	}
}

func (m *Model) SetupInstallSteps() {
	m.Steps = []InstallStep{}

	if m.Choices.Component.Opencode {
		m.Steps = append(m.Steps, InstallStep{
			ID:          "opencode",
			Name:        "Install opencode + Engram",
			Description: "Downloading from GitHub releases",
			Status:      StatusPending,
		})
	}

	if m.Choices.Component.LazyVim {
		m.Steps = append(m.Steps, InstallStep{
			ID:          "lazvim",
			Name:        "Install LazyVim",
			Description: "Installing Neovim with config",
			Status:      StatusPending,
		})
	}

	if m.Choices.Component.Docker {
		m.Steps = append(m.Steps, InstallStep{
			ID:          "docker",
			Name:        "Install Docker",
			Description: "Setting up Docker Desktop",
			Status:      StatusPending,
		})
	}

	if m.Choices.Component.Shell {
		m.Steps = append(m.Steps, InstallStep{
			ID:          "shell",
			Name:        "Install Shell",
			Description: "PowerShell + oh-my-posh",
			Status:      StatusPending,
		})
	}

	if m.Choices.Component.DevTools {
		m.Steps = append(m.Steps, InstallStep{
			ID:          "devtools",
			Name:        "Install DevTools",
			Description: "Git, VS Code, etc",
			Status:      StatusPending,
		})
	}
}
