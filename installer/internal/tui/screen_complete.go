package tui

import (
	"fmt"
	"strings"
)

// RenderComplete displays the installation complete screen
func RenderComplete(m *Model) string {
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
	if m.Choices.Component.EngramMigrate {
		s.WriteString(InfoStyle.Render(fmt.Sprintf("  • Engram Migration (from: %s)", m.Choices.EngramSourcePath)))
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
