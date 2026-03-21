# Delta for Installer

## Purpose

Agregar selección granular de skills en el installer de opencode.

## ADDED Requirements

### Requirement: Skills Manifest Exists

The installer MUST provide a `skills-manifest.json` file that lists all available skills with their metadata.

The manifest MUST contain:
- `id`: unique skill identifier
- `name`: human-readable name
- `required`: boolean indicating if skill is always installed
- `description`: brief description of the skill
- `source`: skill source type (`local` or `url`)
- `path`: source-specific path (file path for local, URL for url)

```json
{
  "skills": [
    {
      "id": "sdd-init",
      "name": "SDD Init",
      "required": false,
      "description": "Bootstrap SDD context and project configuration",
      "source": "local",
      "path": "skills/sdd-init/SKILL.md"
    },
    {
      "id": "custom-skill",
      "name": "Custom Skill",
      "required": false,
      "description": "A custom skill from URL",
      "source": "url",
      "path": "https://raw.githubusercontent.com/user/repo/main/SKILL.md"
    }
  ]
}
```

#### Scenario: Manifest is valid JSON

- GIVEN a valid `skills-manifest.json` exists
- WHEN the installer reads it
- THEN it MUST parse without errors

#### Scenario: Manifest is missing

- GIVEN `skills-manifest.json` does not exist
- WHEN the installer runs
- THEN it MUST fail with error "skills-manifest.json not found"

### Requirement: --skills Flag Behavior

The installer MUST accept a `--skills` flag that specifies which skills to install.

The flag MUST:
- Accept comma-separated list of skill IDs
- Default to `all` when not specified
- Fail with error if any skill ID does not exist in manifest

#### Scenario: Install specific skills

- GIVEN manifest contains skills `sdd-init`, `sdd-verify`, `mermaid`
- WHEN installer runs with `--skills=sdd-init,sdd-verify`
- THEN ONLY `sdd-init` and `sdd-verify` directories are copied

#### Scenario: Install all skills (default)

- GIVEN `--skills` flag is not provided
- WHEN installer runs
- THEN it MUST install all non-required skills

#### Scenario: Invalid skill ID

- GIVEN user specifies `--skills=non-existent-skill`
- WHEN installer parses the flag
- THEN it MUST fail with error listing invalid skill IDs

### Requirement: --exclude-skills Flag Behavior

The installer MUST accept an `--exclude-skills` flag that specifies skills to skip.

The flag MUST:
- Accept comma-separated list of skill IDs
- Install all skills except those listed
- Fail with error if any skill ID does not exist in manifest

#### Scenario: Exclude specific skills

- GIVEN manifest contains skills `sdd-init`, `sdd-verify`, `mermaid`
- WHEN installer runs with `--exclude-skills=mermaid`
- THEN `sdd-init` and `sdd-verify` are installed but `mermaid` is NOT

#### Scenario: Combined --skills and --exclude-skills

- GIVEN user specifies both flags
- WHEN installer parses flags
- THEN it MUST fail with error "Cannot use both --skills and --exclude-skills"

### Requirement: Required Skills Always Installed

Skills marked as `required: true` in manifest MUST be installed regardless of flags.

#### Scenario: Required skill not excluded

- GIVEN skill `skill-registry` is marked `required: true`
- WHEN installer runs with `--skills=sdd-init`
- THEN `skill-registry` MUST also be installed

### Requirement: TUI Skill Selection Screen

The TUI MUST display a skill selection screen when installing opencode.

The screen MUST:
- List all available skills with checkboxes
- Pre-select skills based on defaults or previous selection
- Allow user to toggle individual skills on/off
- Show skill name and description
- Have "Install Selected" and "Select All" / "Deselect All" actions

#### Scenario: TUI shows all skills

- GIVEN the installer reaches opencode installation
- WHEN the TUI skill selection screen is displayed
- THEN it MUST show all skills from manifest with their descriptions

#### Scenario: User selects skills via TUI

- GIVEN TUI skill selection screen is displayed
- WHEN user toggles `sdd-init` checkbox and confirms
- THEN ONLY selected skills (plus required) are installed

### Requirement: Local Skill Source

Skills with `source: "local"` MUST be copied from the relative path in `path`.

The installer MUST:
- Resolve `path` relative to the configs/opencode directory
- Copy the skill file/folder to the opencode config directory

#### Scenario: Install local skill

- GIVEN manifest entry has `source: "local"` and `path: "skills/sdd-init/SKILL.md"`
- WHEN installer processes this skill
- THEN it MUST copy `configs/opencode/skills/sdd-init/SKILL.md` to `$opencode_dir/skills/sdd-init/SKILL.md`

### Requirement: URL Skill Source

Skills with `source: "url"` MUST be downloaded from the URL in `path`.

The installer MUST:
- Download the file from the URL
- Save it to the skill directory in opencode config
- Fail with error if download fails

#### Scenario: Install URL skill

- GIVEN manifest entry has `source: "url"` and `path: "https://example.com/skill.md"`
- WHEN installer processes this skill
- THEN it MUST download the file and save it to `$opencode_dir/skills/{skill-id}/SKILL.md`

#### Scenario: URL download fails

- GIVEN manifest entry has `source: "url"` and invalid URL
- WHEN installer attempts to download
- THEN it MUST fail with error "Failed to download skill {id} from URL"
