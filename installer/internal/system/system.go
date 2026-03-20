package system

import (
	"os"
	"os/exec"
	"runtime"
	"strings"
)

type OSType int

const (
	OSWindows OSType = iota
	OSMac
	OSLinux
	OSWSL
	OSUnknown
)

type SystemInfo struct {
	OS              OSType
	OSName          string
	IsWSL           bool
	IsARM           bool
	HasGit          bool
	HasDocker       bool
	HasWinget       bool
	HasBrew         bool
	HasApt          bool
	HasDnf          bool
	HasNpm          bool
	HasNode         bool
	HasOpencode     bool
	HasLazyVim      bool
	UserShell       string
	HasPowerShell   bool
	HasOhMyPosh     bool
}

func Detect() *SystemInfo {
	info := &SystemInfo{
		OS:        OSUnknown,
		OSName:    "Unknown",
		IsARM:     runtime.GOARCH == "arm64" || runtime.GOARCH == "arm",
		UserShell: detectCurrentShell(),
	}

	switch runtime.GOOS {
	case "windows":
		info.OS = OSWindows
		info.OSName = "Windows"
		info.HasWinget = CommandExists("winget")
	case "darwin":
		info.OS = OSMac
		info.OSName = "macOS"
	case "linux":
		info.OS = OSLinux
		info.OSName = "Linux"
		info.IsWSL = checkWSL()
		if info.IsWSL {
			info.OS = OSWSL
			info.OSName = "WSL"
		}
	}

	info.HasGit = CommandExists("git")
	info.HasDocker = CommandExists("docker")
	info.HasBrew = CommandExists("brew")
	info.HasApt = CommandExists("apt")
	info.HasDnf = CommandExists("dnf")
	info.HasNpm = CommandExists("npm")
	info.HasNode = CommandExists("node")
	info.HasOpencode = CommandExists("opencode")
	info.HasPowerShell = CommandExists("pwsh") || CommandExists("powershell")
	info.HasOhMyPosh = CommandExists("oh-my-posh")

	return info
}

func checkWSL() bool {
	data, err := os.ReadFile("/proc/version")
	if err != nil {
		return false
	}
	content := strings.ToLower(string(data))
	return strings.Contains(content, "microsoft") || strings.Contains(content, "wsl")
}

func detectCurrentShell() string {
	shell := os.Getenv("SHELL")
	if shell == "" {
		if runtime.GOOS == "windows" {
			return detectWindowsShell()
		}
		return "unknown"
	}
	parts := strings.Split(shell, "/")
	return parts[len(parts)-1]
}

func detectWindowsShell() string {
	if CommandExists("pwsh") {
		return "pwsh"
	}
	if CommandExists("powershell") {
		return "powershell"
	}
	if CommandExists("cmd") {
		return "cmd"
	}
	return "unknown"
}

func CommandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

func GetShell() string {
	shell := os.Getenv("SHELL")
	if shell != "" {
		return shell
	}
	switch runtime.GOOS {
	case "windows":
		if CommandExists("pwsh") {
			return "pwsh"
		}
		if CommandExists("powershell") {
			return "powershell"
		}
		return "cmd"
	default:
		return "/bin/sh"
	}
}
