package tui

import (
	"fmt"
	"strings"
)

// RenderComplete displays the installation complete screen
func RenderComplete(m *Model) string {
	var s strings.Builder

	s.WriteString(RosePineStyle.Success.Render("✨ Installation Complete! ✨"))
	s.WriteString("\n\n")

	s.WriteString(RosePineStyle.Title.Render("Summary"))
	s.WriteString("\n")

	s.WriteString(RosePineStyle.Info.Render(fmt.Sprintf("  • OS: %s", m.Choices.OS)))
	s.WriteString("\n")

	if m.Choices.Component.Opencode {
		s.WriteString(RosePineStyle.Info.Render("  • opencode + Engram"))
		s.WriteString("\n")
	}
	if m.Choices.Component.LazyVim {
		s.WriteString(RosePineStyle.Info.Render("  • LazyVim (Neovim)"))
		s.WriteString("\n")
	}
	if m.Choices.Component.Docker {
		s.WriteString(RosePineStyle.Info.Render("  • Docker"))
		s.WriteString("\n")
	}
	if m.Choices.Component.Shell {
		s.WriteString(RosePineStyle.Info.Render("  • Shell (PowerShell + oh-my-posh)"))
		s.WriteString("\n")
	}
	if m.Choices.Component.DevTools {
		s.WriteString(RosePineStyle.Info.Render("  • DevTools (Git, VS Code)"))
		s.WriteString("\n")
	}
	if m.Choices.Component.EngramMigrate {
		s.WriteString(RosePineStyle.Info.Render(fmt.Sprintf("  • Engram Migration (from: %s)", m.Choices.EngramSourcePath)))
		s.WriteString("\n")
	}

	s.WriteString("\n")
	s.WriteString(RosePineStyle.Title.Render("Next Steps"))
	s.WriteString("\n\n")
	s.WriteString(RosePineStyle.Info.Render("1. Restart your terminal"))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Info.Render("2. Run 'opencode --help' to get started"))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Info.Render("3. Visit https://github.com/mi-config for docs"))
	s.WriteString("\n\n")

	s.WriteString(RosePineStyle.Help.Render("Press [Enter] or [q] to exit"))

	return s.String()
}
