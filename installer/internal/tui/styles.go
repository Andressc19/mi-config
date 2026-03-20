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

const logo = `
    ████████╗██╗  ██╗███████╗
    ╚══██╔══╝██║  ██║██╔════╝
       ██║   ███████║█████╗  
       ██║   ██╔══██║██╔══╝  
       ██║   ██║  ██║███████╗
       ╚═╝   ╚═╝  ╚═╝╚══════╝
    ███████╗██╗  ██╗██╗   ██╗██████╗  ██████╗ ██╗    ██╗███████╗██████╗ 
    ██╔════╝╚██╗██╔╝██║   ██║██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗
    █████╗   ╚███╔╝ ██║   ██║██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝
    ██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██║   ██║██║███╗██║██╔══╝  ██╔══██╗
    ███████╗██╔╝ ██╗╚██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝███████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝
`

const banner = "Your development environment, configured in minutes"
