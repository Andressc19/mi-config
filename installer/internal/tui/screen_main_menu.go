package tui

import (
	"strings"
)

// RenderMainMenu displays the main menu screen
func RenderMainMenu(m *Model) string {
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
