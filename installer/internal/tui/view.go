package tui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

func (m Model) View() string {
	if m.Quitting {
		return ""
	}

	var s strings.Builder

	switch m.Screen {
	case ScreenWelcome:
		s.WriteString(m.renderWelcome())
	case ScreenMainMenu:
		s.WriteString(m.renderMainMenu())
	case ScreenOSSelect:
		s.WriteString(m.renderSelection())
	case ScreenOptions:
		s.WriteString(m.renderOptions())
	case ScreenInstalling:
		s.WriteString(m.renderInstalling())
	case ScreenComplete:
		s.WriteString(m.renderComplete())
	case ScreenError:
		s.WriteString(m.renderError())
	}

	paddedStyle := lipgloss.NewStyle().Padding(1, 2, 0, 2)
	return paddedStyle.Render(s.String())
}

func (m Model) renderWelcome() string {
	var s strings.Builder

	s.WriteString(LogoStyle.Render(logo))
	s.WriteString("\n\n")

	info := fmt.Sprintf("Detected: %s", m.SystemInfo.OSName)
	if m.SystemInfo.HasBrew {
		info += " | Homebrew ✓"
	}
	if m.SystemInfo.HasGit {
		info += " | Git ✓"
	}
	s.WriteString(InfoStyle.Render(info))
	s.WriteString("\n\n")

	s.WriteString(SubtitleStyle.Render(banner))
	s.WriteString("\n\n")
	s.WriteString(HelpStyle.Render("Press [Enter] to start • [q] to quit"))

	return CenterBoth(s.String(), m.Width, m.Height)
}

func (m Model) renderMainMenu() string {
	var s strings.Builder

	s.WriteString(TitleStyle.Render("mi-config"))
	s.WriteString("\n")
	s.WriteString(MutedStyle.Render("What would you like to do?"))
	s.WriteString("\n\n")

	options := m.GetCurrentOptions()
	for i, opt := range options {
		cursor := "  "
		style := UnselectedStyle
		if i == m.Cursor {
			cursor = "▸ "
			style = SelectedStyle
		}
		s.WriteString(style.Render(cursor + opt))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(HelpStyle.Render("↑/k up • ↓/j down • [Enter] select • [q] quit"))

	return s.String()
}

func (m Model) renderSelection() string {
	var s strings.Builder

	s.WriteString(m.renderStepProgress())
	s.WriteString("\n\n")

	s.WriteString(TitleStyle.Render(m.GetScreenTitle()))
	s.WriteString("\n")
	s.WriteString(MutedStyle.Render(m.GetScreenDescription()))
	s.WriteString("\n\n")

	options := m.GetCurrentOptions()
	for i, opt := range options {
		cursor := "  "
		style := UnselectedStyle
		if i == m.Cursor {
			cursor = "▸ "
			style = SelectedStyle
		}
		s.WriteString(style.Render(cursor + opt))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(HelpStyle.Render("↑/k up • ↓/j down • [Enter] select • [Esc] back"))

	return s.String()
}

func (m Model) renderOptions() string {
	var s strings.Builder

	s.WriteString(m.renderStepProgress())
	s.WriteString("\n\n")

	s.WriteString(TitleStyle.Render(m.GetScreenTitle()))
	s.WriteString("\n")
	s.WriteString(MutedStyle.Render(m.GetScreenDescription()))
	s.WriteString("\n\n")

	options := []struct {
		Name     string
		Selected bool
	}{
		{"opencode + Engram", m.Choices.Component.Opencode},
		{"LazyVim (Neovim)", m.Choices.Component.LazyVim},
		{"Docker", m.Choices.Component.Docker},
		{"Shell (PowerShell + oh-my-posh)", m.Choices.Component.Shell},
		{"DevTools (Git, VS Code, etc)", m.Choices.Component.DevTools},
	}

	for i, opt := range options {
		checkbox := "[ ]"
		style := UnselectedStyle
		if opt.Selected {
			checkbox = "[✓]"
			style = SelectedStyle
		}
		if i == m.Cursor {
			style = SelectedStyle
		}
		s.WriteString(style.Render(fmt.Sprintf("  %s %s", checkbox, opt.Name)))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(MutedStyle.Render("Use [Space] to toggle, [Enter] to continue"))
	s.WriteString("\n")
	s.WriteString(HelpStyle.Render("↑/k up • ↓/j down • [Space] toggle • [Enter] continue • [Esc] back"))

	return s.String()
}

func (m Model) renderStepProgress() string {
	steps := []string{"OS", "Components"}
	currentIdx := 0

	switch m.Screen {
	case ScreenOSSelect:
		currentIdx = 0
	case ScreenOptions:
		currentIdx = 1
	}

	var parts []string
	for i, step := range steps {
		var style lipgloss.Style
		if i < currentIdx {
			style = StepDoneStyle
			parts = append(parts, style.Render("✓ "+step))
		} else if i == currentIdx {
			style = StepActiveStyle
			parts = append(parts, style.Render("● "+step))
		} else {
			style = StepPendingStyle
			parts = append(parts, style.Render("○ "+step))
		}
	}

	return strings.Join(parts, MutedStyle.Render(" → "))
}

var spinnerFrames = []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}

func (m Model) renderInstalling() string {
	var s strings.Builder

	s.WriteString(TitleStyle.Render("🚀 Installing mi-config"))
	s.WriteString("\n\n")

	for i, step := range m.Steps {
		var icon string
		var style lipgloss.Style

		switch step.Status {
		case StatusPending:
			icon = "○"
			style = MutedStyle
		case StatusRunning:
			icon = spinnerFrames[m.SpinnerFrame%len(spinnerFrames)]
			style = WarningStyle
		case StatusDone:
			icon = "✓"
			style = SuccessStyle
		case StatusFailed:
			icon = "✗"
			style = ErrorStyle
		case StatusSkipped:
			icon = "⊘"
			style = MutedStyle
		}

		line := fmt.Sprintf("%s %s", icon, step.Name)
		s.WriteString(style.Render(line))
		s.WriteString("\n")

		if i == m.CurrentStep && step.Status == StatusRunning {
			s.WriteString(MutedStyle.Render("   " + step.Description))
			s.WriteString("\n")
		}
	}

	if m.ShowDetails && len(m.LogLines) > 0 {
		s.WriteString("\n")
		s.WriteString(BoxStyle.Render(strings.Join(m.LogLines[maxInt(0, len(m.LogLines)-10):], "\n")))
	}

	s.WriteString("\n")
	s.WriteString(HelpStyle.Render("[d] toggle details"))

	return s.String()
}

func (m Model) renderComplete() string {
	var s strings.Builder

	s.WriteString(SuccessStyle.Render("✨ Installation Complete! ✨"))
	s.WriteString("\n\n")

	s.WriteString(TitleStyle.Render("Summary"))
	s.WriteString("\n")

	s.WriteString(InfoStyle.Render(fmt.Sprintf("  • OS: %s", m.Choices.OS)))
	s.WriteString("\n")

	if m.Choices.Component.Opencode {
		s.WriteString(InfoStyle.Render("  • opencode + Engram"))
		s.WriteString("\n")
	}
	if m.Choices.Component.LazyVim {
		s.WriteString(InfoStyle.Render("  • LazyVim (Neovim)"))
		s.WriteString("\n")
	}
	if m.Choices.Component.Docker {
		s.WriteString(InfoStyle.Render("  • Docker"))
		s.WriteString("\n")
	}
	if m.Choices.Component.Shell {
		s.WriteString(InfoStyle.Render("  • Shell (PowerShell + oh-my-posh)"))
		s.WriteString("\n")
	}
	if m.Choices.Component.DevTools {
		s.WriteString(InfoStyle.Render("  • DevTools (Git, VS Code)"))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(TitleStyle.Render("Next Steps"))
	s.WriteString("\n\n")
	s.WriteString(InfoStyle.Render("1. Restart your terminal"))
	s.WriteString("\n")
	s.WriteString(InfoStyle.Render("2. Run 'opencode --help' to get started"))
	s.WriteString("\n")
	s.WriteString(InfoStyle.Render("3. Visit https://github.com/mi-config for docs"))
	s.WriteString("\n\n")

	s.WriteString(HelpStyle.Render("Press [Enter] or [q] to exit"))

	return s.String()
}

func (m Model) renderError() string {
	var s strings.Builder

	s.WriteString(ErrorStyle.Render("❌ Installation Failed"))
	s.WriteString("\n\n")

	s.WriteString(MutedStyle.Render("Error:"))
	s.WriteString("\n")
	s.WriteString(ErrorStyle.Render(m.ErrorMsg))
	s.WriteString("\n\n")

	if len(m.LogLines) > 0 {
		s.WriteString(MutedStyle.Render("Recent logs:"))
		s.WriteString("\n")
		startIdx := len(m.LogLines) - 5
		if startIdx < 0 {
			startIdx = 0
		}
		for _, line := range m.LogLines[startIdx:] {
			s.WriteString(InfoStyle.Render("  " + line))
			s.WriteString("\n")
		}
		s.WriteString("\n")
	}

	s.WriteString(HelpStyle.Render("[r] retry • [q] quit"))

	return s.String()
}

func maxInt(a, b int) int {
	if a > b {
		return a
	}
	return b
}
