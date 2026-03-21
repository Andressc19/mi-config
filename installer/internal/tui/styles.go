package tui

import "github.com/charmbracelet/lipgloss"

var (
	Background        = lipgloss.Color("#0f1117")
	BackgroundPanel   = lipgloss.Color("#1a1d27")
	BackgroundElement = lipgloss.Color("#252836")

	Text      = lipgloss.Color("#E4E7EB")
	TextMuted = lipgloss.Color("#6B7280")

	Primary   = lipgloss.Color("#8B5CF6")
	Secondary = lipgloss.Color("#A78BFA")
	Accent    = lipgloss.Color("#F59E0B")

	Error   = lipgloss.Color("#EF4444")
	Warning = lipgloss.Color("#F59E0B")
	Success = lipgloss.Color("#10B981")
	Info    = lipgloss.Color("#3B82F6")

	Border       = lipgloss.Color("#374151")
	BorderActive = lipgloss.Color("#8B5CF6")

	TitleStyle = lipgloss.NewStyle().
			Foreground(Primary).
			Bold(true).
			MarginBottom(1)

	SubtitleStyle = lipgloss.NewStyle().
			Foreground(Secondary).
			Italic(true)

	SuccessStyle = lipgloss.NewStyle().
			Foreground(Success).
			Bold(true)

	ErrorStyle = lipgloss.NewStyle().
			Foreground(Error).
			Bold(true)

	WarningStyle = lipgloss.NewStyle().
			Foreground(Warning)

	InfoStyle = lipgloss.NewStyle().
			Foreground(Info)

	MutedStyle = lipgloss.NewStyle().
			Foreground(TextMuted)

	SelectedStyle = lipgloss.NewStyle().
			Foreground(Accent).
			Bold(true).
			PaddingLeft(2)

	UnselectedStyle = lipgloss.NewStyle().
			Foreground(Text).
			PaddingLeft(4)

	BoxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(BorderActive).
			Padding(1, 2)

	LogoStyle = lipgloss.NewStyle().
			Foreground(Primary).
			Bold(true)

	StepActiveStyle = lipgloss.NewStyle().
			Foreground(Accent).
			Bold(true)

	StepDoneStyle = lipgloss.NewStyle().
			Foreground(Success)

	StepPendingStyle = lipgloss.NewStyle().
				Foreground(TextMuted)

	HelpStyle = lipgloss.NewStyle().
			Foreground(TextMuted).
			Italic(true).
			MarginTop(1)

	HighlightStyle = lipgloss.NewStyle().
			Foreground(Accent).
			Bold(true)
)

// Rose Pine Theme - a beautiful dark color palette
type RosePineTheme struct {
	Background        lipgloss.Color
	BackgroundPanel   lipgloss.Color
	BackgroundElement lipgloss.Color
	Text              lipgloss.Color
	TextMuted         lipgloss.Color
	Primary           lipgloss.Color
	Secondary         lipgloss.Color
	Accent            lipgloss.Color
	Error             lipgloss.Color
	Warning           lipgloss.Color
	Success           lipgloss.Color
	Info              lipgloss.Color
	Border            lipgloss.Color
	BorderActive      lipgloss.Color
}

// RosePine is the Rose Pine dark color palette
var RosePine = RosePineTheme{
	Background:        lipgloss.Color("#191724"),
	BackgroundPanel:   lipgloss.Color("#26233a"),
	BackgroundElement: lipgloss.Color("#317BC1"),
	Text:              lipgloss.Color("#e0def4"),
	TextMuted:         lipgloss.Color("#6e6a86"),
	Primary:           lipgloss.Color("#c4a7e7"),
	Secondary:         lipgloss.Color("#908caa"),
	Accent:            lipgloss.Color("#eb6f92"),
	Error:             lipgloss.Color("#eb6f92"),
	Warning:           lipgloss.Color("#f6c177"),
	Success:           lipgloss.Color("#9ccfd8"),
	Info:              lipgloss.Color("#317BC1"),
	Border:            lipgloss.Color("#403d52"),
	BorderActive:      lipgloss.Color("#c4a7e7"),
}

// RosePineStyle contains Lipgloss styles using Rose Pine theme
var RosePineStyle = struct {
	Title       lipgloss.Style
	Subtitle    lipgloss.Style
	Success     lipgloss.Style
	Error       lipgloss.Style
	Warning     lipgloss.Style
	Info        lipgloss.Style
	Muted       lipgloss.Style
	Selected    lipgloss.Style
	Unselected  lipgloss.Style
	Box         lipgloss.Style
	Logo        lipgloss.Style
	StepActive  lipgloss.Style
	StepDone    lipgloss.Style
	StepPending lipgloss.Style
	Help        lipgloss.Style
	Highlight   lipgloss.Style
}{
	Title: lipgloss.NewStyle().
		Foreground(RosePine.Primary).
		Bold(true).
		MarginBottom(1),

	Subtitle: lipgloss.NewStyle().
		Foreground(RosePine.Secondary).
		Italic(true),

	Success: lipgloss.NewStyle().
		Foreground(RosePine.Success).
		Bold(true),

	Error: lipgloss.NewStyle().
		Foreground(RosePine.Error).
		Bold(true),

	Warning: lipgloss.NewStyle().
		Foreground(RosePine.Warning),

	Info: lipgloss.NewStyle().
		Foreground(RosePine.Info),

	Muted: lipgloss.NewStyle().
		Foreground(RosePine.TextMuted),

	Selected: lipgloss.NewStyle().
		Foreground(RosePine.Accent).
		Bold(true).
		PaddingLeft(2),

	Unselected: lipgloss.NewStyle().
		Foreground(RosePine.Text).
		PaddingLeft(4),

	Box: lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(RosePine.BorderActive).
		Padding(1, 2),

	Logo: lipgloss.NewStyle().
		Foreground(RosePine.Primary).
		Bold(true),

	StepActive: lipgloss.NewStyle().
		Foreground(RosePine.Accent).
		Bold(true),

	StepDone: lipgloss.NewStyle().
		Foreground(RosePine.Success),

	StepPending: lipgloss.NewStyle().
		Foreground(RosePine.TextMuted),

	Help: lipgloss.NewStyle().
		Foreground(RosePine.TextMuted).
		Italic(true).
		MarginTop(1),

	Highlight: lipgloss.NewStyle().
		Foreground(RosePine.Accent).
		Bold(true),
}

const logo = `
 WAIT
`

const banner = "Your development environment, configured in minutes"
