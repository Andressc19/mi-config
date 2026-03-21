package tui

import (
	"strings"
)

// RenderError displays the error screen with logs
func RenderError(m *Model) string {
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
