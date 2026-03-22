package tui

import (
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// RenderSelect displays the OS/component selection screen
func RenderSelect(m *Model) string {
	var s strings.Builder

	s.WriteString(m.renderStepProgress())
	s.WriteString("\n\n")

	s.WriteString(RosePineStyle.Title.Render(m.GetScreenTitle()))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Muted.Render(m.GetScreenDescription()))
	s.WriteString("\n\n")

	options := m.GetCurrentOptions()
	for i, opt := range options {
		cursor := "  "
		style := RosePineStyle.Unselected
		if i == m.Cursor {
			cursor = "▸ "
			style = RosePineStyle.Selected
		}
		s.WriteString(style.Render(cursor + opt))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(RosePineStyle.Help.Render("↑/k up • ↓/j down • [Enter] select • [Esc] back"))

	return s.String()
}

// renderStepProgress returns the step progress indicator
func (m *Model) renderStepProgress() string {
	steps := []string{"OS", "Components"}
	currentIdx := 0

	switch m.Screen {
	case ScreenOSSelect:
		currentIdx = 0
	case ScreenOptions:
		currentIdx = 1
	case ScreenEngramMigrate:
		currentIdx = 2
	}

	var parts []string
	for i, step := range steps {
		var style lipgloss.Style
		if i < currentIdx {
			style = RosePineStyle.StepDone
			parts = append(parts, style.Render(" "+step))
		} else if i == currentIdx {
			style = RosePineStyle.StepActive
			parts = append(parts, style.Render("● "+step))
		} else {
			style = RosePineStyle.StepPending
			parts = append(parts, style.Render("○ "+step))
		}
	}

	return strings.Join(parts, RosePineStyle.Muted.Render(" → "))
}
