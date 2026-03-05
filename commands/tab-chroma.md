# Tab-Chroma

Run tab-chroma CLI commands directly from Claude Code.

Execute the following, then show the output to the user:

```bash
~/.claude/hooks/tab-chroma/tab-chroma.sh $ARGUMENTS
```

If `$ARGUMENTS` is empty, run `status` instead:

```bash
~/.claude/hooks/tab-chroma/tab-chroma.sh status
```

**Available commands (pass as arguments):**
- `status` — show current config and state
- `pause` / `resume` / `toggle` — control whether colors change
- `theme list` — list installed themes
- `theme use <name>` — switch active theme (default, ocean, neon, pastel, solarized, dracula)
- `theme next` — cycle to next theme
- `theme preview [name]` — preview all states (2s each, run from terminal)
- `test <state>` — manually trigger a state (working/done/attention/permission)
- `reset` — reset tab to default color
- `color on|off` / `badge on|off` / `title on|off` — toggle features
- `install` — register Claude Code hooks
- `uninstall` — remove hooks, completions, and data files
