# Delta for TUI

## ADDED Requirements

### Requirement: Cursor Visual Indicator

The TUI MUST show a visual cursor indicator for the active item in ALL lists (selection screens, skill selection, menus).

The cursor indicator MUST:
- Use a consistent prefix character (e.g., "> " or "▸ ") for all lists
- Be applied only to the item at the current cursor position
- Be distinguishable from unselected items

#### Scenario: Component Selection Screen

- GIVEN the user is on the component selection screen
- WHEN the user navigates with ↑/↓ keys
- THEN the active item MUST have a cursor prefix (e.g., "> item-name")
- AND inactive items MUST NOT have the cursor prefix

#### Scenario: Skill Selection Screen

- GIVEN the user is on the skill selection screen
- WHEN the user navigates with ↑/↓ keys through skills
- THEN the active skill MUST have a cursor prefix (e.g., "> [✓] skill-name")
- AND inactive skills MUST NOT have the cursor prefix

#### Scenario: Multiple Groups in Skill Selection

- GIVEN the skill selection screen has multiple groups (SDD Workflow, Utilities)
- WHEN the user navigates across groups
- THEN the cursor MUST follow across group boundaries
- AND each active item MUST show the cursor indicator

#### Scenario: Empty List

- GIVEN a list has no items
- THEN no cursor indicator should be rendered

## MODIFIED Requirements

### Requirement: renderSkillSelection Cursor (Previously: No cursor)

The skill selection screen MUST show a cursor indicator on the active skill, matching the style used in other selection screens.

(Previously: No visual indicator for active skill)