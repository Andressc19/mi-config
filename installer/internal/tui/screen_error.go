package tui

import (
	"strings"
)

// RenderError displays the error screen with logs
func RenderError(m *Model) string {
	var s strings.Builder

	s.WriteString(RosePineStyle.Error.Render("❌ Installation Failed"))
	s.WriteString("\n\n")

	s.WriteString(RosePineStyle.Muted.Render("Error:"))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Error.Render(m.ErrorMsg))
	s.WriteString("\n\n")

	if len(m.LogLines) > 0 {
		s.WriteString(RosePineStyle.Muted.Render("Recent logs:"))
		s.WriteString("\n")
		startIdx := len(m.LogLines) - 5
		if startIdx < 0 {
			startIdx = 0
		}
		for _, line := range m.LogLines[startIdx:] {
			s.WriteString(RosePineStyle.Info.Render("  " + line))
			s.WriteString("\n")
		}
		s.WriteString("\n")
	}

	s.WriteString(RosePineStyle.Help.Render("[r] retry • [q] quit"))

	return s.String()
}
