package tui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// RenderEngram displays the Engram migration selection screen
func RenderEngram(m *Model) string {
	var s strings.Builder

	s.WriteString(m.renderStepProgressEngram())
	s.WriteString("\n\n")

	s.WriteString(TitleStyle.Render("Step 3: Migrate Engram"))
	s.WriteString("\n")
	s.WriteString(MutedStyle.Render("Found existing Engram installation or backup"))
	s.WriteString("\n\n")

	engramInfo := m.SystemInfo.Engram
	if engramInfo.HasEngram {
		s.WriteString(InfoStyle.Render(fmt.Sprintf("  ✓ Engram found at: %s", engramInfo.EngramPath)))
		s.WriteString("\n\n")
	}

	if engramInfo.HasBackup && engramInfo.BackupPath != engramInfo.EngramPath {
		s.WriteString(InfoStyle.Render(fmt.Sprintf("  📦 Backup found at: %s", engramInfo.BackupPath)))
		s.WriteString("\n\n")
	}

	options := []string{
		"📥 Import from detected location",
		"⏩︎Skip (fresh install)",
		"📁 Import from custom path",
	}

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
	s.WriteString(HelpStyle.Render("↑/k up • ↓/j down • [Enter] select • [Esc] back"))

	return s.String()
}

// renderStepProgressEngram returns the step progress indicator for Engram screen
func (m *Model) renderStepProgressEngram() string {
	steps := []string{"OS", "Components", "Engram"}
	currentIdx := 2

	var parts []string
	for i, step := range steps {
		var style lipgloss.Style
		if i < currentIdx {
			style = StepDoneStyle
			parts = append(parts, style.Render("✓ "+step))
		} else if i == currentIdx {
			style = StepActiveStyle
			parts = append(parts, style.Render("● "+step))
		} else {
			style = StepPendingStyle
			parts = append(parts, style.Render("○ "+step))
		}
	}

	return strings.Join(parts, MutedStyle.Render(" → "))
}
