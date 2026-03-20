package tui

import (
	"fmt"
	"runtime"

	"github.com/mi-config/installer/internal/system"
)

func RunNonInteractive(choices UserChoices) error {
	SetNonInteractiveMode(true)

	sysInfo := system.Detect()

	osChoice := "linux"
	if runtime.GOOS == "darwin" {
		osChoice = "macos"
	} else if runtime.GOOS == "windows" {
		osChoice = "windows"
	}
	choices.OS = osChoice

	model := &Model{
		SystemInfo: sysInfo,
		Choices:    choices,
		LogLines:   []string{},
	}

	steps := buildStepsForChoices(model)

	fmt.Printf("📋 Running %d installation steps...\n\n", len(steps))

	for i, step := range steps {
		fmt.Printf("[%d/%d] %s...\n", i+1, len(steps), step.Name)

		err := executeStep(step.ID, model)
		if err != nil {
			fmt.Printf("    ❌ FAILED: %v\n", err)
			return fmt.Errorf("step '%s' failed: %w", step.Name, err)
		}
		fmt.Printf("    ✓ Done\n")
	}

	fmt.Println()
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	fmt.Println("✅ Installation complete!")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	return nil
}

func buildStepsForChoices(m *Model) []InstallStep {
	var steps []InstallStep

	if m.Choices.Component.Opencode {
		steps = append(steps, InstallStep{ID: "opencode", Name: "Install opencode + Engram"})
	}

	if m.Choices.Component.LazyVim {
		steps = append(steps, InstallStep{ID: "lazvim", Name: "Install LazyVim"})
	}

	if m.Choices.Component.Docker {
		steps = append(steps, InstallStep{ID: "docker", Name: "Install Docker"})
	}

	if m.Choices.Component.Shell {
		steps = append(steps, InstallStep{ID: "shell", Name: "Install Shell (PowerShell + oh-my-posh)"})
	}

	if m.Choices.Component.DevTools {
		steps = append(steps, InstallStep{ID: "devtools", Name: "Install DevTools (Git, VS Code)"})
	}

	return steps
}
