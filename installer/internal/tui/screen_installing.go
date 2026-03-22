package tui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// RenderInstalling displays the installation progress screen with spinner
func RenderInstalling(m *Model) string {
	var s strings.Builder

	s.WriteString(RosePineStyle.Title.Render("🚀 Installing mi-config"))
	s.WriteString("\n\n")

	for i, step := range m.Steps {
		var icon string
		var style lipgloss.Style

		switch step.Status {
		case StatusPending:
			icon = "○"
			style = RosePineStyle.Muted
		case StatusRunning:
			icon = spinnerFrames[m.SpinnerFrame%len(spinnerFrames)]
			style = RosePineStyle.Warning
		case StatusDone:
			icon = "✓"
			style = RosePineStyle.Success
		case StatusFailed:
			icon = "✗"
			style = RosePineStyle.Error
		case StatusSkipped:
			icon = "⊘"
			style = RosePineStyle.Muted
		}

		line := fmt.Sprintf("%s %s", icon, step.Name)
		s.WriteString(style.Render(line))
		s.WriteString("\n")

		if i == m.CurrentStep && step.Status == StatusRunning {
			s.WriteString(RosePineStyle.Muted.Render("   " + step.Description))
			s.WriteString("\n")
		}
	}

	if m.ShowDetails && len(m.LogLines) > 0 {
		s.WriteString("\n")
		s.WriteString(RosePineStyle.Box.Render(strings.Join(m.LogLines[maxInt(0, len(m.LogLines)-10):], "\n")))
	}

	s.WriteString("\n")
	s.WriteString(RosePineStyle.Help.Render("[d] toggle details"))

	return s.String()
}
