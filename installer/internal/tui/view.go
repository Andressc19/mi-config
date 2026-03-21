package tui

import (
	"strings"

	"github.com/charmbracelet/lipgloss"
)

func (m Model) View() string {
	if m.Quitting {
		return ""
	}

	s := Route(m)

	paddedStyle := lipgloss.NewStyle().Padding(1, 2, 0, 2)
	return paddedStyle.Render(s)
}

func maxInt(a, b int) int {
	if a > b {
		return a
	}
	return b
}

// CenterBoth centers content both horizontally and vertically
func CenterBoth(content string, width, height int) string {
	lines := strings.Split(content, "\n")

	// Calculate padding for vertical centering
	verticalPad := (height - len(lines)) / 2
	if verticalPad < 0 {
		verticalPad = 0
	}

	// Calculate padding for horizontal centering
	horizontalPad := (width - maxLineWidth(lines)) / 2
	if horizontalPad < 0 {
		horizontalPad = 0
	}

	var result strings.Builder

	// Add vertical padding
	for i := 0; i < verticalPad; i++ {
		result.WriteString("\n")
	}

	// Add horizontal padding and lines
	style := lipgloss.NewStyle().MarginLeft(horizontalPad)
	for _, line := range lines {
		result.WriteString(style.Render(line))
		result.WriteString("\n")
	}

	return result.String()
}

func maxLineWidth(lines []string) int {
	max := 0
	for _, line := range lines {
		if len(line) > max {
			max = len(line)
		}
	}
	return max
}

var spinnerFrames = []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
