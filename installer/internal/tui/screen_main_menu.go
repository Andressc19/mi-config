package tui

import (
	"strings"
)

// RenderMainMenu displays the main menu screen
func RenderMainMenu(m *Model) string {
	var s strings.Builder

	s.WriteString(RosePineStyle.Title.Render("mi-config"))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Muted.Render("What would you like to do?"))
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
	s.WriteString(RosePineStyle.Help.Render("↑/k up • ↓/j down • [Enter] select • [q] quit"))

	return s.String()
}
