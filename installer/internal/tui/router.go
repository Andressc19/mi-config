package tui

// Route dispatches to the appropriate screen renderer based on Model.Screen
func Route(m Model) string {
	switch m.Screen {
	case ScreenWelcome:
		return RenderWelcome(&m)
	case ScreenMainMenu:
		return RenderMainMenu(&m)
	case ScreenOSSelect:
		return RenderSelect(&m)
	case ScreenOptions:
		return RenderOptions(&m)
	case ScreenSkillSelect:
		return RenderSkills(&m)
	case ScreenEngramMigrate:
		return RenderEngram(&m)
	case ScreenInstalling:
		return RenderInstalling(&m)
	case ScreenComplete:
		return RenderComplete(&m)
	case ScreenError:
		return RenderError(&m)
	default:
		return ""
	}
}
