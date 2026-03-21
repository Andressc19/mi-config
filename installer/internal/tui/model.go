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
	ScreenSkillSelect
	ScreenEngramMigrate
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
	Opencode       bool
	LazyVim       bool
	Docker        bool
	Shell         bool
	DevTools      bool
	EngramMigrate bool
}

type SkillChoice struct {
	ID          string
	Name        string
	Group       string
	Required    bool
	Description string
	Source      string
	Path        string
	Selected    bool
}

type SkillManifest struct {
	Skills []SkillChoice
}

type EngramMigrateChoice int

const (
	EngramMigrateImportDetected EngramMigrateChoice = iota
	EngramMigrateSkip
	EngramMigrateManual
)

type UserChoices struct {
	OS               string
	Component        ComponentSelection
	CreateBackup     bool
	EngramChoice     EngramMigrateChoice
	EngramSourcePath string
	SelectedSkills   []string
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
	Skills      []SkillChoice
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
			"💾 Engram Migration",
		}
	case ScreenSkillSelect:
		options := []string{}
		for _, skill := range m.Skills {
			options = append(options, skill.Name)
		}
		return options
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
	case ScreenSkillSelect:
		return "Step 2b: Select Skills"
	case ScreenEngramMigrate:
		return "Step 3: Migrate Engram"
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
	case ScreenSkillSelect:
		return "Select skills to install"
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

	if m.Choices.Component.EngramMigrate {
		m.Steps = append(m.Steps, InstallStep{
			ID:          "engram-migrate",
			Name:        "Migrate Engram",
			Description: "Importing from backup",
			Status:      StatusPending,
		})
	}
}

func (m *Model) LoadSkillsFromManifest() {
	m.Skills = []SkillChoice{
		{ID: "sdd-init", Name: "SDD Init", Group: "sdd-workflow", Required: false, Description: "Initialize SDD context", Source: "local", Path: "skills/sdd-init/SKILL.md", Selected: true},
		{ID: "sdd-explore", Name: "SDD Explore", Group: "sdd-workflow", Required: false, Description: "Explore and investigate ideas", Source: "local", Path: "skills/sdd-explore/SKILL.md", Selected: true},
		{ID: "sdd-propose", Name: "SDD Propose", Group: "sdd-workflow", Required: false, Description: "Create change proposals", Source: "local", Path: "skills/sdd-propose/SKILL.md", Selected: true},
		{ID: "sdd-spec", Name: "SDD Spec", Group: "sdd-workflow", Required: false, Description: "Write specifications", Source: "local", Path: "skills/sdd-spec/SKILL.md", Selected: true},
		{ID: "sdd-design", Name: "SDD Design", Group: "sdd-workflow", Required: false, Description: "Create technical design", Source: "local", Path: "skills/sdd-design/SKILL.md", Selected: true},
		{ID: "sdd-tasks", Name: "SDD Tasks", Group: "sdd-workflow", Required: false, Description: "Break down into tasks", Source: "local", Path: "skills/sdd-tasks/SKILL.md", Selected: true},
		{ID: "sdd-apply", Name: "SDD Apply", Group: "sdd-workflow", Required: false, Description: "Implement code changes", Source: "local", Path: "skills/sdd-apply/SKILL.md", Selected: true},
		{ID: "sdd-verify", Name: "SDD Verify", Group: "sdd-workflow", Required: false, Description: "Validate implementation", Source: "local", Path: "skills/sdd-verify/SKILL.md", Selected: true},
		{ID: "sdd-archive", Name: "SDD Archive", Group: "sdd-workflow", Required: false, Description: "Archive completed changes", Source: "local", Path: "skills/sdd-archive/SKILL.md", Selected: true},
		{ID: "mermaid-diagrams", Name: "Mermaid Diagrams", Group: "utilities", Required: false, Description: "Render Mermaid diagrams", Source: "local", Path: "skills/mermaid-diagrams/SKILL.md", Selected: false},
		{ID: "readme-docs", Name: "Readme Docs", Group: "utilities", Required: false, Description: "Generate README docs", Source: "local", Path: "skills/readme-docs/SKILL.md", Selected: false},
		{ID: "skill-registry", Name: "Skill Registry", Group: "utilities", Required: true, Description: "Update skill registry", Source: "local", Path: "skills/skill-registry/SKILL.md", Selected: true},
		{ID: "issue-creation", Name: "Issue Creation", Group: "utilities", Required: false, Description: "Issue creation workflow", Source: "local", Path: "skills/issue-creation/SKILL.md", Selected: false},
		{ID: "branch-pr", Name: "Branch PR", Group: "utilities", Required: false, Description: "PR creation workflow", Source: "local", Path: "skills/branch-pr/SKILL.md", Selected: false},
	}
}
