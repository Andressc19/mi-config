# Delta for CLI

## MODIFIED Requirements

### Requirement: Terminal Exit Behavior

The installer MUST properly restore the terminal state and return control to the shell after the user exits the TUI.

(Previously: Terminal may remain in raw mode or not return prompt after exit)

#### Scenario: Exit after completing installation

- GIVEN the user has completed the installation process
- WHEN the TUI shows the completion screen
- AND the user presses any key to exit
- THEN the terminal MUST return to normal mode
- AND the user MUST see their shell prompt

#### Scenario: Exit using quit command

- GIVEN the user is navigating the TUI
- WHEN the user presses [q] or [Ctrl+C]
- THEN the TUI MUST exit cleanly
- AND the terminal MUST be restored to normal state
- AND the user MUST see their shell prompt

#### Scenario: Exit from skill selection

- GIVEN the user is on the skill selection screen
- WHEN the user presses [Esc] to go back and then exits
- THEN the terminal MUST be restored properly
- AND no leftover characters or artifacts remain on screen