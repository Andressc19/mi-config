package tui

import (
	"fmt"
	"strings"
)

// RenderOptions displays the component options screen with checkboxes
func RenderOptions(m *Model) string {
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
		{"Engram Migration", m.Choices.Component.EngramMigrate},
	}

	for i, opt := range options {
		checkbox := "[ ]"
		cursor := "  "
		style := UnselectedStyle
		if opt.Selected {
			checkbox = "[✓]"
			style = SelectedStyle
		}
		if i == m.Cursor {
			cursor = "▸ "
			style = SelectedStyle
		}
		s.WriteString(style.Render(fmt.Sprintf("%s%s %s", cursor, checkbox, opt.Name)))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(MutedStyle.Render("Use [Space] to toggle, [Enter] to continue"))
	s.WriteString("\n")
	s.WriteString(HelpStyle.Render("↑/k up • ↓/j down • [Space] toggle • [Enter] continue • [Esc] back"))

	return s.String()
}
