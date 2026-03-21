package main

import (
	"flag"
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/mi-config/installer/internal/tui"
)

var Version = "1.0.0"

type cliFlags struct {
	version        bool
	help           bool
	dryRun         bool
	nonInteractive bool
	opencode       bool
	lazvim         bool
	docker         bool
	shell          bool
	devtools       bool
	engramMigrate  bool
}

func parseFlags() *cliFlags {
	flags := &cliFlags{}

	flag.BoolVar(&flags.version, "version", false, "Show version information")
	flag.BoolVar(&flags.version, "v", false, "Show version information (shorthand)")
	flag.BoolVar(&flags.help, "help", false, "Show help message")
	flag.BoolVar(&flags.help, "h", false, "Show help message (shorthand)")
	flag.BoolVar(&flags.dryRun, "dry-run", false, "Show what would be installed without doing it")
	flag.BoolVar(&flags.nonInteractive, "non-interactive", false, "Run without TUI, use CLI flags")
	flag.BoolVar(&flags.opencode, "opencode", false, "Install opencode + Engram")
	flag.BoolVar(&flags.lazvim, "lazvim", false, "Install LazyVim (Neovim)")
	flag.BoolVar(&flags.lazvim, "nvim", false, "Install LazyVim (Neovim) (alias)")
	flag.BoolVar(&flags.docker, "docker", false, "Install Docker")
	flag.BoolVar(&flags.shell, "shell", false, "Install Shell (PowerShell + oh-my-posh)")
	flag.BoolVar(&flags.devtools, "devtools", false, "Install DevTools (Git, VS Code)")
	flag.BoolVar(&flags.engramMigrate, "engram-migrate", false, "Migrate Engram from backup")

	flag.Parse()
	return flags
}

func main() {
	flags := parseFlags()

	if flags.version {
		fmt.Printf("mi-config-installer v%s\n", Version)
		os.Exit(0)
	}

	if flags.help {
		printHelp()
		os.Exit(0)
	}

	if flags.dryRun {
		os.Setenv("MI_CONFIG_DRY_RUN", "1")
		fmt.Println("🧪 Dry-run mode: No actual installations will be performed")
	}

	if flags.nonInteractive {
		if !flags.opencode && !flags.lazvim && !flags.docker && !flags.shell && !flags.devtools && !flags.engramMigrate {
			fmt.Fprintf(os.Stderr, "Error: at least one component must be selected (--opencode, --lazvim, --docker, --shell, --devtools, --engram-migrate)\n")
			os.Exit(1)
		}

		choices := tui.UserChoices{
			Component: tui.ComponentSelection{
				Opencode:      flags.opencode,
				LazyVim:       flags.lazvim,
				Docker:        flags.docker,
				Shell:         flags.shell,
				DevTools:      flags.devtools,
				EngramMigrate: flags.engramMigrate,
			},
		}

		fmt.Println("🚀 mi-config Non-Interactive Installer")
		fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		fmt.Printf("  opencode:        %v\n", choices.Component.Opencode)
		fmt.Printf("  LazyVim:         %v\n", choices.Component.LazyVim)
		fmt.Printf("  Docker:          %v\n", choices.Component.Docker)
		fmt.Printf("  Shell:           %v\n", choices.Component.Shell)
		fmt.Printf("  DevTools:        %v\n", choices.Component.DevTools)
		fmt.Printf("  Engram Migrate:  %v\n", choices.Component.EngramMigrate)
		fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		fmt.Println()

		if err := tui.RunNonInteractive(choices); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		os.Exit(0)
	}

	model := tui.NewModel()
	p := tea.NewProgram(
		model,
		tea.WithAltScreen(),
		tea.WithMouseCellMotion(),
	)
	tui.SetGlobalProgram(p)

	_, err := p.Run()

	// Ensure terminal is restored on Windows
	fmt.Print("\033[?1049l\033[?25h")

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error running installer: %v\n", err)
		os.Exit(1)
	}
	os.Exit(0)
}

func printHelp() {
	fmt.Println(`mi-config-installer - TUI installer for mi-config development environment

Usage:
  mi-config-installer [flags]

Interactive Mode (default):
  Just run 'mi-config-installer' to start the TUI installer.

Non-Interactive Mode:
  mi-config-installer --non-interactive [options]

Flags:
  -h, --help           Show this help message
  -v, --version        Show version information
  --dry-run            Show what would be installed without doing it
  --non-interactive    Run without TUI, use CLI flags instead

Non-Interactive Options:
  --opencode           Install opencode + Engram
  --nvim, --lazvim     Install LazyVim (Neovim)
  --docker             Install Docker
  --shell              Install Shell (PowerShell + oh-my-posh)
  --devtools           Install DevTools (Git, VS Code)
  --engram-migrate     Migrate Engram from existing installation/backup

Examples:
  # Interactive TUI
  mi-config-installer

  # Non-interactive with all components
  mi-config-installer --non-interactive --opencode --lazvim --docker --shell --devtools

  # Non-interactive with Engram migration
  mi-config-installer --non-interactive --opencode --engram-migrate

  # Dry-run mode
  mi-config-installer --dry-run --opencode

Navigation (TUI mode):
  ↑/k, ↓/j        Navigate up/down
  Enter/Space     Select option
  Esc             Go back
  q               Quit
  d               Toggle details (during installation)

For more info: https://github.com/mi-config`)
}
