# Tab-Chroma: iTerm2 Visual Feedback Plugin for Claude Code

## Context

When running Claude Code in iTerm2, there's no visual indicator of Claude's current state — whether it's working, done, or waiting for user input. The user must constantly watch the terminal to know when to act. Inspired by the **peon-ping** audio notification plugin (~1500 lines, sound packs, CLI, hooks), we want to build a visual counterpart: **tab-chroma** — a plugin that changes iTerm2 tab colors, badges, and titles based on Claude Code hook events.

The user already has a basic `iterm-tab-color.sh` script working (writes escape sequences to `/dev/tty`). This plan upgrades it into a full-featured, configurable plugin with themes, CLI, state management, and proper installation — following peon-ping's proven architecture patterns.

---

## Plugin Name: `tab-chroma`

Short, descriptive, memorable.

---

## Architecture Overview

```
~/.claude/hooks/tab-chroma/
├── tab-chroma.sh              # Main entry point (~350-400 lines bash)
├── config.json                # User configuration
├── .state.json                # Runtime state (hidden, not user-edited)
├── .paused                    # Pause flag file (presence = paused)
├── VERSION                    # Version string (e.g., "1.0.0")
├── install.sh                 # Installer script
├── uninstall.sh               # Uninstaller script
├── completions.bash           # Bash/zsh tab completion
├── completions.fish           # Fish shell tab completion
└── themes/                    # Color theme packs
    ├── default/
    │   └── theme.json
    ├── ocean/
    │   └── theme.json
    ├── neon/
    │   └── theme.json
    ├── pastel/
    │   └── theme.json
    ├── solarized/
    │   └── theme.json
    └── dracula/
        └── theme.json
```

---

## Hook Events → Visual States

| Claude Code Hook Event | Internal State | Description |
|---|---|---|
| `SessionStart` | `session.start` | New session started |
| `UserPromptSubmit` | `working` | Claude is processing |
| `Stop` | `done` | Claude finished, user's turn |
| `Notification` (idle_prompt) | `attention` | Waiting for user input |
| `Notification` (permission_prompt) | `permission` | Needs approval |
| `PermissionRequest` | `permission` | Needs tool approval |

---

## Theme Format (`theme.json`)

Each theme defines RGB colors for each state, plus metadata:

```json
{
  "schema_version": "1.0",
  "name": "default",
  "display_name": "Default",
  "version": "1.0.0",
  "description": "Clean blue/green/orange color scheme",
  "author": {
    "name": "Jacopo Castellano"
  },
  "states": {
    "session.start": {
      "r": -1, "g": -1, "b": -1,
      "action": "reset",
      "label": "Session started"
    },
    "working": {
      "r": 0, "g": 100, "b": 200,
      "label": "Claude is working"
    },
    "done": {
      "r": 34, "g": 180, "b": 80,
      "label": "Ready for input"
    },
    "attention": {
      "r": 255, "g": 160, "b": 40,
      "label": "Needs attention"
    },
    "permission": {
      "r": 220, "g": 60, "b": 40,
      "label": "Needs approval"
    }
  }
}
```

**State color rules:**
- `"action": "reset"` → resets tab to default (no custom color)
- RGB values 0-255 → sets tab color
- Missing state → no color change for that event

### Bundled Themes (6 total)

| Theme | Working | Done | Attention | Permission | Vibe |
|---|---|---|---|---|---|
| `default` | Blue (0,100,200) | Green (34,180,80) | Orange (255,160,40) | Red (220,60,40) | Clean, high-contrast |
| `ocean` | Deep Blue (0,80,160) | Teal (0,180,170) | Amber (240,180,40) | Coral (240,80,60) | Calm, oceanic |
| `neon` | Electric Blue (0,150,255) | Neon Green (0,255,100) | Hot Pink (255,50,150) | Red (255,30,30) | Vibrant, cyberpunk |
| `pastel` | Soft Blue (130,170,220) | Soft Green (130,200,150) | Soft Peach (240,180,140) | Soft Rose (220,140,140) | Gentle, easy on eyes |
| `solarized` | Blue (38,139,210) | Green (133,153,0) | Yellow (181,137,0) | Red (220,50,47) | Solarized palette |
| `dracula` | Purple (189,147,249) | Green (80,250,123) | Orange (255,184,108) | Red (255,85,85) | Dracula editor theme |

---

## Configuration (`config.json`)

```json
{
  "active_theme": "default",
  "enabled": true,
  "features": {
    "tab_color": true,
    "badge": true,
    "title": true
  },
  "states": {
    "session.start": true,
    "working": true,
    "done": true,
    "attention": true,
    "permission": true
  },
  "debounce_seconds": 2,
  "theme_rotation": [],
  "theme_rotation_mode": "off"
}
```

**Fields:**
- `active_theme` — Current theme name (matches directory in `themes/`)
- `enabled` — Master on/off switch
- `features.tab_color` — Enable/disable tab color changes
- `features.badge` — Enable/disable iTerm2 badge (project name + status)
- `features.title` — Enable/disable tab title updates
- `states.*` — Toggle individual states on/off
- `debounce_seconds` — Suppress rapid state changes within this window
- `theme_rotation` — List of theme names for rotation (like peon-ping's pack rotation)
- `theme_rotation_mode` — `"off"`, `"random"`, or `"round-robin"`

---

## Runtime State (`.state.json`)

```json
{
  "last_state": "working",
  "last_state_time": 1709567234.567,
  "session_themes": {
    "session-uuid": "neon"
  },
  "rotation_index": 0
}
```

Tracks state for debouncing and per-session theme pinning.

---

## CLI Commands

```bash
# Basic controls
tab-chroma pause                    # Disable (creates .paused file)
tab-chroma resume                   # Re-enable (removes .paused)
tab-chroma toggle                   # Toggle pause state
tab-chroma status                   # Show: active theme, state, features, paused

# Theme management
tab-chroma theme list               # List installed themes with preview colors
tab-chroma theme use <name>         # Switch active theme
tab-chroma theme next               # Cycle to next theme alphabetically
tab-chroma theme preview [name]     # Cycle through all states of a theme (2s each)

# Feature toggles
tab-chroma badge on|off             # Toggle iTerm2 badge
tab-chroma title on|off             # Toggle tab title updates
tab-chroma color on|off             # Toggle tab color changes

# Manual testing
tab-chroma test <state>             # Manually trigger a state (working/done/attention/permission)
tab-chroma reset                    # Reset tab to default color

# Info
tab-chroma help                     # Show usage
tab-chroma version                  # Show version
```

---

## iTerm2 Escape Sequences Used

| Feature | Escape Sequence | Notes |
|---|---|---|
| Set tab color (red) | `\033]6;1;bg;red;brightness;R\a` | R = 0-255 |
| Set tab color (green) | `\033]6;1;bg;green;brightness;G\a` | G = 0-255 |
| Set tab color (blue) | `\033]6;1;bg;blue;brightness;B\a` | B = 0-255 |
| Reset tab color | `\033]6;1;bg;*;default\a` | Back to default |
| Set tab title | `\033]0;TITLE\007` | Shows in tab bar |
| Set badge | `\033]1337;SetBadgeFormat=BASE64\a` | Base64-encoded text |
| Clear badge | `\033]1337;SetBadgeFormat=\a` | Empty = clear |

**Critical:** All escape sequences write to `/dev/tty` (not stdout) because Claude Code captures hook stdout.

---

## Main Script Flow (`tab-chroma.sh`)

```
┌─────────────────────────────────────┐
│ 1. Platform/Terminal Detection      │
│    - Check $TERM_PROGRAM = iTerm.app│
│    - Exit silently if not iTerm2    │
├─────────────────────────────────────┤
│ 2. CLI Argument Routing             │
│    - If args present → handle CLI   │
│    - If stdin is TTY → show help    │
│    - Otherwise → process hook event │
├─────────────────────────────────────┤
│ 3. Read Hook JSON from stdin        │
│    - Parse with single Python call  │
│    - Extract: event, cwd, session_id│
├─────────────────────────────────────┤
│ 4. Check Guards                     │
│    - Is enabled? (.paused file)     │
│    - Is config.enabled true?        │
├─────────────────────────────────────┤
│ 5. Map Event → State                │
│    - SessionStart → session.start   │
│    - UserPromptSubmit → working     │
│    - Stop → done                    │
│    - Notification → attention       │
│    - PermissionRequest → permission │
├─────────────────────────────────────┤
│ 6. Apply Debouncing                 │
│    - Skip if same state within N sec│
│    - Exception: always allow urgent │
│      states (attention, permission) │
├─────────────────────────────────────┤
│ 7. Resolve Theme                    │
│    - Load active theme or rotation  │
│    - Pin theme to session if needed │
├─────────────────────────────────────┤
│ 8. Apply Visual Changes             │
│    - Tab color → /dev/tty           │
│    - Tab title → /dev/tty           │
│    - Badge → /dev/tty               │
├─────────────────────────────────────┤
│ 9. Save State                       │
│    - Update .state.json             │
└─────────────────────────────────────┘
```

### Consolidated Python Block (Performance)

Following peon-ping's pattern, all JSON parsing, config loading, state management, theme resolution, and debouncing logic runs in a **single Python invocation** to minimize overhead:

```bash
eval "$(python3 -c "
import sys, json, os, time

# 1. Parse hook input
event_data = json.load(sys.stdin)
event = event_data.get('hook_event_name', '')
cwd = event_data.get('cwd', '')
session_id = event_data.get('session_id', '')

# 2. Load config
config = json.load(open('$CONFIG'))

# 3. Load state
state = json.load(open('$STATE')) if os.path.exists('$STATE') else {}

# 4. Map event → state
# 5. Debounce check
# 6. Resolve theme & colors
# 7. Output bash variables

print(f'STATE_NAME=\"{state_name}\"')
print(f'COLOR_R={r}')
print(f'COLOR_G={g}')
print(f'COLOR_B={b}')
print(f'ACTION=\"{action}\"')
print(f'TITLE_TEXT=\"{title}\"')
print(f'BADGE_TEXT=\"{badge}\"')

# 8. Save state atomically
json.dump(state, open('$STATE', 'w'))
" <<< "$INPUT" 2>/dev/null)"
```

Then bash applies the escape sequences:

```bash
if [ "$ACTION" = "reset" ]; then
  printf '\033]6;1;bg;*;default\a' > /dev/tty
elif [ -n "$COLOR_R" ]; then
  printf '\033]6;1;bg;red;brightness;%s\a\033]6;1;bg;green;brightness;%s\a\033]6;1;bg;blue;brightness;%s\a' \
    "$COLOR_R" "$COLOR_G" "$COLOR_B" > /dev/tty
fi

if [ -n "$TITLE_TEXT" ]; then
  printf '\033]0;%s\007' "$TITLE_TEXT" > /dev/tty
fi

if [ -n "$BADGE_TEXT" ]; then
  printf '\033]1337;SetBadgeFormat=%s\a' "$(echo -n "$BADGE_TEXT" | base64)" > /dev/tty
fi
```

---

## Installation Script (`install.sh`)

```bash
#!/bin/bash
# 1. Copy tab-chroma directory to ~/.claude/hooks/tab-chroma/
# 2. Register hooks in ~/.claude/settings.json using Python:
#    - Add tab-chroma.sh to SessionStart, UserPromptSubmit, Stop, Notification, PermissionRequest
#    - Preserve existing hooks (peon-ping, etc.)
# 3. Install bash completions to ~/.bash_completion.d/ (source from .bashrc/.zshrc)
# 4. Install fish completions to ~/.config/fish/completions/
# 5. Create default config.json if not exists
# 6. Print success message with usage instructions
```

**Hook registration pattern** (from peon-ping):
```python
import json

settings_path = os.path.expanduser('~/.claude/settings.json')
settings = json.load(open(settings_path))
hooks = settings.setdefault('hooks', {})

TAB_CHROMA_CMD = os.path.expanduser('~/.claude/hooks/tab-chroma/tab-chroma.sh')
EVENTS = ['SessionStart', 'UserPromptSubmit', 'Stop', 'Notification', 'PermissionRequest']

for event in EVENTS:
    entries = hooks.setdefault(event, [])
    # Check if already registered
    already = any(
        TAB_CHROMA_CMD in h.get('command', '')
        for entry in entries
        for h in entry.get('hooks', [])
    )
    if not already:
        if entries and entries[0].get('matcher', '') == '':
            # Append to existing catch-all entry
            entries[0]['hooks'].append({
                'type': 'command',
                'command': TAB_CHROMA_CMD,
                'timeout': 5
            })
        else:
            # Create new entry
            entries.append({
                'matcher': '',
                'hooks': [{
                    'type': 'command',
                    'command': TAB_CHROMA_CMD,
                    'timeout': 5
                }]
            })

json.dump(settings, open(settings_path, 'w'), indent=2)
```

---

## Uninstallation Script (`uninstall.sh`)

```bash
#!/bin/bash
# 1. Remove tab-chroma hooks from ~/.claude/settings.json
#    (filter out any hook where command contains 'tab-chroma')
# 2. Reset tab color to default
# 3. Clear badge
# 4. Remove completions files
# 5. Remove ~/.claude/hooks/tab-chroma/ directory
# 6. Print success message
```

---

## Shell Completions

### Bash/Zsh (`completions.bash`)

```bash
_tab_chroma_completions() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "$prev" in
    tab-chroma)
      COMPREPLY=( $(compgen -W "pause resume toggle status theme badge title color test reset help version" -- "$cur") );;
    theme)
      COMPREPLY=( $(compgen -W "list use next preview" -- "$cur") );;
    use|preview)
      local themes_dir="$HOME/.claude/hooks/tab-chroma/themes"
      local names=$(ls -d "$themes_dir"/*/ 2>/dev/null | xargs -n1 basename)
      COMPREPLY=( $(compgen -W "$names" -- "$cur") );;
    badge|title|color)
      COMPREPLY=( $(compgen -W "on off" -- "$cur") );;
    test)
      COMPREPLY=( $(compgen -W "working done attention permission" -- "$cur") );;
  esac
}
complete -F _tab_chroma_completions tab-chroma
```

### Fish (`completions.fish`)

```fish
complete -c tab-chroma -f
complete -c tab-chroma -n __fish_use_subcommand -a pause -d "Disable color changes"
complete -c tab-chroma -n __fish_use_subcommand -a resume -d "Re-enable color changes"
complete -c tab-chroma -n __fish_use_subcommand -a toggle -d "Toggle pause state"
complete -c tab-chroma -n __fish_use_subcommand -a status -d "Show current config"
complete -c tab-chroma -n __fish_use_subcommand -a theme -d "Manage themes"
complete -c tab-chroma -n __fish_use_subcommand -a test -d "Test a state"
complete -c tab-chroma -n __fish_use_subcommand -a reset -d "Reset tab color"
complete -c tab-chroma -n __fish_use_subcommand -a help -d "Show help"
```

---

## Tab Title & Badge Format

**Tab title format:**
```
◉ ProjectName: status
```

Examples:
- `◉ ProcessGrid_FrontEnd: working`
- `◉ ProcessGrid_FrontEnd: done`
- `◉ ProcessGrid_FrontEnd: needs approval`

**Badge format:**
```
ProjectName
status
```

(Two lines: project name on top, status below — displayed as overlay in iTerm2 tab)

---

## Debouncing Logic

```python
now = time.time()
last_time = state.get('last_state_time', 0)
last_state = state.get('last_state', '')
debounce = config.get('debounce_seconds', 2)

# Always allow urgent states
urgent = state_name in ('attention', 'permission')

# Skip if same state within debounce window (unless urgent)
if state_name == last_state and (now - last_time) < debounce and not urgent:
    skip = True
```

---

## Terminal Detection

```bash
detect_terminal() {
  if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
    echo "iterm2"
  elif [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    echo "apple-terminal"  # Title only, no tab color
  elif [ -n "$KITTY_PID" ]; then
    echo "kitty"           # Future: kitty has its own escape codes
  else
    echo "unsupported"
  fi
}
```

For non-iTerm2 terminals, the plugin gracefully degrades:
- **Apple Terminal**: Tab title only (no color/badge support)
- **Kitty**: Could add support later (has `\033]30;TITLE\033\\` for titles)
- **Others**: Exit silently, no-op

---

## Implementation Plan (Step by Step)

### Step 1: Create directory structure
- Create `~/.claude/hooks/tab-chroma/` and `themes/` subdirectories
- Create `VERSION` file with `1.0.0`

### Step 2: Create theme files
- Write `theme.json` for all 7 bundled themes
- Validate JSON structure consistency

### Step 3: Write main script (`tab-chroma.sh`)
- Platform/terminal detection
- CLI argument routing (pause/resume/toggle/status/theme/test/reset/help)
- Hook JSON parsing via consolidated Python
- Event → state mapping
- Config loading + debouncing
- Theme resolution (with rotation support)
- iTerm2 escape sequence output to `/dev/tty`
- State persistence

### Step 4: Write config.json (default)
- Default configuration with all features enabled

### Step 5: Write install.sh
- Copy files, register hooks in settings.json, install completions
- Detect and preserve existing hooks (peon-ping coexistence)

### Step 6: Write uninstall.sh
- Remove hooks from settings.json, clean up files, reset tab

### Step 7: Write shell completions
- `completions.bash` for bash/zsh
- `completions.fish` for fish

### Step 8: Create shell alias
- Add `alias tab-chroma="~/.claude/hooks/tab-chroma/tab-chroma.sh"` to shell RC
- Or add to PATH via symlink

### Step 9: Register hooks
- Run install.sh to wire up hooks in `~/.claude/settings.json`
- Ensure coexistence with existing peon-ping hooks

### Step 10: Remove old iterm-tab-color.sh
- Delete `~/.claude/hooks/iterm-tab-color.sh` (replaced by tab-chroma)
- Remove its hook entries from settings.json

---

## Files to Modify

| File | Action |
|---|---|
| `~/.claude/hooks/tab-chroma/tab-chroma.sh` | **Create** — main script |
| `~/.claude/hooks/tab-chroma/config.json` | **Create** — default config |
| `~/.claude/hooks/tab-chroma/.state.json` | **Created at runtime** |
| `~/.claude/hooks/tab-chroma/VERSION` | **Create** — "1.0.0" |
| `~/.claude/hooks/tab-chroma/install.sh` | **Create** — installer |
| `~/.claude/hooks/tab-chroma/uninstall.sh` | **Create** — uninstaller |
| `~/.claude/hooks/tab-chroma/completions.bash` | **Create** — bash completions |
| `~/.claude/hooks/tab-chroma/completions.fish` | **Create** — fish completions |
| `~/.claude/hooks/tab-chroma/themes/*/theme.json` | **Create** — 7 theme files |
| `~/.claude/settings.json` | **Modify** — register hooks (via install.sh) |
| `~/.claude/hooks/iterm-tab-color.sh` | **Delete** — replaced by tab-chroma |

---

## Verification

1. **Manual test each state:**
   ```bash
   tab-chroma test working     # Tab turns blue
   tab-chroma test done        # Tab turns green
   tab-chroma test attention   # Tab turns orange
   tab-chroma test permission  # Tab turns red
   tab-chroma reset            # Tab returns to default
   ```

2. **Theme switching:**
   ```bash
   tab-chroma theme list                # Shows 7 themes
   tab-chroma theme use neon            # Switch to neon
   tab-chroma test working              # Verify neon blue
   tab-chroma theme preview             # Cycles all states
   ```

3. **Live integration test:**
   - Start a new Claude Code session → tab resets (session.start)
   - Send a prompt → tab turns blue (working)
   - Claude finishes → tab turns green (done)
   - Claude asks permission → tab turns orange/red (permission)

4. **CLI controls:**
   ```bash
   tab-chroma pause            # Colors stop changing
   tab-chroma status           # Shows "paused: true"
   tab-chroma resume           # Colors resume
   ```

5. **Coexistence with peon-ping:**
   - Verify both hooks fire on all events
   - Sound plays AND tab color changes simultaneously
