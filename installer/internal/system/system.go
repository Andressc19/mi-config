package system

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
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

type EngramInfo struct {
	HasEngram        bool
	EngramPath       string
	HasBackup        bool
	BackupPath       string
	WSLEngramPath    string
	WindowsEngramPath string
	DBFile           string
}

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
	Engram          EngramInfo
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

	info.Engram = DetectEngram()

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

func DetectEngram() EngramInfo {
	info := EngramInfo{
		DBFile: "engram.db",
	}

	homeDir := os.Getenv("HOME")
	userProfile := os.Getenv("USERPROFILE")

	switch runtime.GOOS {
	case "windows":
		info.WindowsEngramPath = filepath.Join(userProfile, ".engram", info.DBFile)
		if _, err := os.Stat(info.WindowsEngramPath); err == nil {
			info.HasEngram = true
			info.EngramPath = info.WindowsEngramPath
		}

		if checkWSL() {
			userFromWSL := os.Getenv("USER")
			if userFromWSL == "" {
				userFromWSL = "user"
			}
			info.WSLEngramPath = fmt.Sprintf(`\\wsl$\Ubuntu\home\%s\.engram\%s`, userFromWSL, info.DBFile)
			if _, err := os.Stat(info.WSLEngramPath); err == nil && !info.HasEngram {
				info.HasBackup = true
				info.BackupPath = info.WSLEngramPath
			}
		}

		if backupPath := findEngramBackup(userProfile); backupPath != "" {
			info.HasBackup = true
			if info.BackupPath == "" {
				info.BackupPath = backupPath
			}
		}

	case "darwin":
		darwinPath := filepath.Join(homeDir, ".engram", info.DBFile)
		if _, err := os.Stat(darwinPath); err == nil {
			info.HasEngram = true
			info.EngramPath = darwinPath
		}

		if backupPath := findEngramBackup(filepath.Join(homeDir, ".engram")); backupPath != "" {
			info.HasBackup = true
			info.BackupPath = backupPath
		}

	case "linux":
		linuxPath := filepath.Join(homeDir, ".engram", info.DBFile)
		if _, err := os.Stat(linuxPath); err == nil {
			info.HasEngram = true
			info.EngramPath = linuxPath
		}

		if checkWSL() && userProfile != "" {
			info.WSLEngramPath = filepath.Join(userProfile, ".engram", info.DBFile)
			if _, err := os.Stat(info.WSLEngramPath); err == nil && !info.HasEngram {
				info.HasBackup = true
				info.BackupPath = info.WSLEngramPath
			}
		}

		if backupPath := findEngramBackup(filepath.Join(homeDir, ".engram")); backupPath != "" {
			info.HasBackup = true
			info.BackupPath = backupPath
		}
	}

	return info
}

func findEngramBackup(searchDir string) string {
	extensions := []string{".json", ".zip", ".db", ".bak"}
	if _, err := os.Stat(searchDir); err != nil {
		return ""
	}

	entries, err := os.ReadDir(searchDir)
	if err != nil {
		return ""
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		if strings.HasPrefix(name, "engram") || strings.HasSuffix(name, ".db") || strings.HasSuffix(name, ".json") {
			for _, ext := range extensions {
				if strings.HasSuffix(name, ext) {
					return filepath.Join(searchDir, name)
				}
			}
		}
	}
	return ""
}
