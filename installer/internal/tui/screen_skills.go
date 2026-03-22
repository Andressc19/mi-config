package tui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// RenderSkills displays the skill selection screen
func RenderSkills(m *Model) string {
	var s strings.Builder

	s.WriteString(m.renderStepProgressSkills())
	s.WriteString("\n\n")

	s.WriteString(RosePineStyle.Title.Render(m.GetScreenTitle()))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Muted.Render(m.GetScreenDescription()))
	s.WriteString("\n\n")

	sddSkills := []SkillChoice{}
	utilities := []SkillChoice{}
	for _, skill := range m.Skills {
		if skill.Group == "sdd-workflow" {
			sddSkills = append(sddSkills, skill)
		} else {
			utilities = append(utilities, skill)
		}
	}

	if len(sddSkills) > 0 {
		s.WriteString(RosePineStyle.Muted.Render("SDD Workflow"))
		s.WriteString("\n")
		for i, skill := range sddSkills {
			checkbox := "[ ]"
			if skill.Selected {
				checkbox = "[✓]"
			}
			globalIdx := i
			for j, sk := range m.Skills {
				if sk.ID == skill.ID {
					globalIdx = j
					break
				}
			}
			cursor := "  "
			style := RosePineStyle.Unselected
			if globalIdx == m.Cursor {
				cursor = "▸ "
				style = RosePineStyle.Selected
			}
			s.WriteString(style.Render(fmt.Sprintf("%s%s %s", cursor, checkbox, skill.Name)))
			s.WriteString("\n")
		}
		s.WriteString("\n")
	}

	if len(utilities) > 0 {
		s.WriteString(RosePineStyle.Muted.Render("Utilities"))
		s.WriteString("\n")
		startIdx := len(sddSkills)
		for i, skill := range utilities {
			checkbox := "[ ]"
			if skill.Selected {
				checkbox = "[✓]"
			}
			globalIdx := startIdx + i
			for j, sk := range m.Skills {
				if sk.ID == skill.ID {
					globalIdx = j
					break
				}
			}
			cursor := "  "
			style := RosePineStyle.Unselected
			if globalIdx == m.Cursor {
				cursor = "▸ "
				style = RosePineStyle.Selected
			}
			s.WriteString(style.Render(fmt.Sprintf("%s%s %s", cursor, checkbox, skill.Name)))
			s.WriteString("\n")
		}
		s.WriteString("\n")
	}

	s.WriteString(RosePineStyle.Muted.Render("Use [Space] to toggle, [a] Select All, [n] Deselect All"))
	s.WriteString("\n")
	s.WriteString(RosePineStyle.Help.Render("↑/k up • ↓/j down • [Space] toggle • [a] select all • [n] deselect all • [Enter] continue • [Esc] back"))

	return s.String()
}

// renderStepProgressSkills returns the step progress indicator for skills screen
func (m *Model) renderStepProgressSkills() string {
	steps := []string{"OS", "Components", "Skills"}
	currentIdx := 2

	var parts []string
	for i, step := range steps {
		var style lipgloss.Style
		if i < currentIdx {
			style = RosePineStyle.StepDone
			parts = append(parts, style.Render("✓ "+step))
		} else if i == currentIdx {
			style = RosePineStyle.StepActive
			parts = append(parts, style.Render("● "+step))
		} else {
			style = RosePineStyle.StepPending
			parts = append(parts, style.Render("○ "+step))
		}
	}

	return strings.Join(parts, RosePineStyle.Muted.Render(" → "))
}
