package tui

import (
	"time"

	"github.com/mi-config/installer/internal/system"
	tea "github.com/charmbracelet/bubbletea"
)

type tickMsg struct{}

func tick() tea.Cmd {
	return tea.Tick(time.Second/10, func(t time.Time) tea.Msg {
		return tickMsg{}
	})
}

type stepProgressMsg struct {
	stepID string
	log    string
}

type execFinishedMsg struct {
	stepID string
	err    error
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {

	case tea.WindowSizeMsg:
		m.Width = msg.Width
		m.Height = msg.Height
		return m, nil

	case tickMsg:
		m.SpinnerFrame++
		return m, tick()

	case stepProgressMsg:
		m.LogLines = append(m.LogLines, msg.log)
		if len(m.LogLines) > 100 {
			m.LogLines = m.LogLines[len(m.LogLines)-100:]
		}
		return m, nil

	case execFinishedMsg:
		for i, step := range m.Steps {
			if step.ID == msg.stepID {
				if msg.err != nil {
					m.Steps[i].Status = StatusFailed
					m.Steps[i].Error = msg.err
					m.ErrorMsg = msg.err.Error()
					m.Screen = ScreenError
				} else {
					m.Steps[i].Status = StatusDone
					m.CurrentStep++
					if m.CurrentStep < len(m.Steps) {
						m.Steps[m.CurrentStep].Status = StatusRunning
						return m, m.runNextStep()
					} else {
						m.Screen = ScreenComplete
					}
				}
				break
			}
		}
		return m, nil

	case tea.KeyMsg:
		s := msg.String()
		switch m.Screen {
		case ScreenWelcome:
			if msg.Type == tea.KeyEnter || msg.Type == tea.KeySpace {
				m.Screen = ScreenMainMenu
				m.Cursor = 0
			} else if msg.Type == tea.KeyRunes && (s == "q" || s == "Q") {
				m.Quitting = true
			}

		case ScreenMainMenu:
			switch msg.Type {
			case tea.KeyUp:
				if m.Cursor > 0 {
					m.Cursor--
				}
			case tea.KeyDown:
				if m.Cursor < len(m.GetCurrentOptions())-1 {
					m.Cursor++
				}
			case tea.KeyEnter, tea.KeySpace:
				switch m.Cursor {
				case 0:
					m.Screen = ScreenOSSelect
					m.Cursor = 0
				case 1:
				case 2:
					m.Quitting = true
				}
			case tea.KeyRunes:
				if s == "q" || s == "Q" {
					m.Quitting = true
				}
			}

		case ScreenOSSelect:
			switch msg.Type {
			case tea.KeyUp:
				if m.Cursor > 0 {
					m.Cursor--
				}
			case tea.KeyDown:
				if m.Cursor < len(m.GetCurrentOptions())-1 {
					m.Cursor++
				}
			case tea.KeyEnter, tea.KeySpace:
				options := []string{"windows", "macos", "linux", "wsl"}
				if m.Cursor < len(options) {
					m.Choices.OS = options[m.Cursor]
					m.Screen = ScreenOptions
					m.Cursor = 0
				}
			case tea.KeyEscape:
				m.Screen = ScreenMainMenu
				m.Cursor = 0
			}

		case ScreenOptions:
			s := msg.String()
			switch msg.Type {
			case tea.KeyUp:
				if m.Cursor > 0 {
					m.Cursor--
				}
			case tea.KeyDown:
				if m.Cursor < len(m.GetCurrentOptions())-1 {
					m.Cursor++
				}
			case tea.KeySpace, tea.KeyRunes:
				if msg.Type == tea.KeySpace || s == " " {
					switch m.Cursor {
					case 0:
						m.Choices.Component.Opencode = !m.Choices.Component.Opencode
					case 1:
						m.Choices.Component.LazyVim = !m.Choices.Component.LazyVim
					case 2:
						m.Choices.Component.Docker = !m.Choices.Component.Docker
					case 3:
						m.Choices.Component.Shell = !m.Choices.Component.Shell
					case 4:
						m.Choices.Component.DevTools = !m.Choices.Component.DevTools
					case 5:
						m.Choices.Component.EngramMigrate = !m.Choices.Component.EngramMigrate
					}
				}
			case tea.KeyEnter:
				hasSelection := m.Choices.Component.Opencode ||
					m.Choices.Component.LazyVim ||
					m.Choices.Component.Docker ||
					m.Choices.Component.Shell ||
					m.Choices.Component.DevTools

				if hasSelection {
					if m.Choices.Component.EngramMigrate {
						m.Screen = ScreenEngramMigrate
						m.Cursor = 0
					} else {
						m.SetupInstallSteps()
						m.Screen = ScreenInstalling
						m.CurrentStep = 0
						if len(m.Steps) > 0 {
							m.Steps[0].Status = StatusRunning
							return m, m.startInstallation()
						} else {
							m.Screen = ScreenComplete
						}
					}
				}
			case tea.KeyEscape:
				m.Screen = ScreenOSSelect
				m.Cursor = 0
			}

		case ScreenEngramMigrate:
			switch msg.Type {
			case tea.KeyUp:
				if m.Cursor > 0 {
					m.Cursor--
				}
			case tea.KeyDown:
				if m.Cursor < 2 {
					m.Cursor++
				}
			case tea.KeyEnter, tea.KeySpace:
				m.Choices.EngramChoice = EngramMigrateChoice(m.Cursor)
				if m.Cursor == EngramMigrateImportDetected {
					if m.SystemInfo.Engram.HasEngram {
						m.Choices.EngramSourcePath = m.SystemInfo.Engram.EngramPath
					} else if m.SystemInfo.Engram.HasBackup {
						m.Choices.EngramSourcePath = m.SystemInfo.Engram.BackupPath
					}
				} else if m.Cursor == EngramMigrateSkip {
					m.Choices.Component.EngramMigrate = false
				}
				m.SetupInstallSteps()
				m.Screen = ScreenInstalling
				m.CurrentStep = 0
				if len(m.Steps) > 0 {
					m.Steps[0].Status = StatusRunning
					return m, m.startInstallation()
				} else {
					m.Screen = ScreenComplete
				}
			case tea.KeyEscape:
				m.Screen = ScreenOptions
				m.Cursor = 0
			}

		case ScreenInstalling:
			if msg.Type == tea.KeyRunes && s == "d" {
				m.ShowDetails = !m.ShowDetails
			}

		case ScreenComplete:
			if msg.Type == tea.KeyEnter || (msg.Type == tea.KeyRunes && (s == "q" || s == "Q")) {
				m.Quitting = true
			}

		case ScreenError:
			if msg.Type == tea.KeyRunes {
				if s == "r" || s == "R" {
					m.Screen = ScreenInstalling
					m.CurrentStep = 0
					if len(m.Steps) > 0 {
						m.Steps[0].Status = StatusRunning
						return m, m.startInstallation()
					}
				} else if s == "q" || s == "Q" {
					m.Quitting = true
				}
			}
		}
	}

	return m, nil
}

func (m *Model) startInstallation() tea.Cmd {
	return tea.Batch(tick(), m.runNextStep())
}

func (m *Model) runNextStep() tea.Cmd {
	if m.CurrentStep >= len(m.Steps) {
		return func() tea.Msg {
			return execFinishedMsg{stepID: "", err: nil}
		}
	}

	stepID := m.Steps[m.CurrentStep].ID
	return func() tea.Msg {
		err := executeStep(stepID, m)
		return execFinishedMsg{stepID: stepID, err: err}
	}
}

func InitSystem() *system.SystemInfo {
	return system.Detect()
}