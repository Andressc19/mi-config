package tui

import (
	"fmt"
	"strings"
)

// RenderWelcome displays the welcome screen with logo and system info
func RenderWelcome(m *Model) string {
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
