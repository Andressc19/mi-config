package tui

import (
	"fmt"
	"strings"
)

// RenderWelcome displays the welcome screen with logo and system info
func RenderWelcome(m *Model) string {
	var s strings.Builder

	s.WriteString(RosePineStyle.Logo.Render(logo))
	s.WriteString("\n\n")

	info := fmt.Sprintf("Detected: %s", m.SystemInfo.OSName)
	if m.SystemInfo.HasBrew {
		info += " | Homebrew ✓"
	}
	if m.SystemInfo.HasGit {
		info += " | Git ✓"
	}
	s.WriteString(RosePineStyle.Info.Render(info))
	s.WriteString("\n\n")

	s.WriteString(RosePineStyle.Subtitle.Render(banner))
	s.WriteString("\n\n")
	s.WriteString(RosePineStyle.Help.Render("Press [Enter] to start • [q] to quit"))

	return CenterBoth(s.String(), m.Width, m.Height)
}
