# Tab-Chroma Cheatsheet

Run this bash command and display the output verbatim inside a code block:

```bash
~/.claude/hooks/tab-chroma/tab-chroma.sh status | python3 -c "
import sys, os

lines = sys.stdin.read().strip().split('\n')
status = {}
for l in lines:
    if ':' in l:
        k, _, v = l.partition(':')
        status[k.strip()] = v.strip()

version_file = os.path.expanduser('~/.claude/hooks/tab-chroma/VERSION')
version = open(version_file).read().strip() if os.path.exists(version_file) else '?'
paused  = status.get('paused', 'false') == 'true'
theme   = status.get('active theme', 'default')
state   = status.get('last state', 'none')

W = 53
def row(content):
    inner = W - 2
    return '│' + content.ljust(inner)[:inner] + '│'

sep = '├' + '─' * (W-2) + '┤'
top = '╭' + '─' * (W-2) + '╮'
bot = '╰' + '─' * (W-2) + '╯'
blank = row('')

status_str = '  ⏸  PAUSED' if paused else ''
print(top)
print(row(f'  tab-chroma v{version}   theme: {theme}'))
print(row(f'  state: {state:<12} {status_str}'))
print(sep)
print(row('  SLASH COMMANDS'))
print(blank)
print(row('  /tab-chroma                  show status'))
print(row('  /tab-chroma pause            stop color changes'))
print(row('  /tab-chroma resume           restart colors'))
print(row('  /tab-chroma toggle           flip pause state'))
print(row('  /tab-chroma reset            clear tab color'))
print(row('  /tab-chroma theme list       list themes'))
print(row('  /tab-chroma theme use NAME   switch theme'))
print(row('  /tab-chroma theme next       cycle theme'))
print(row('  /tab-chroma test STATE       trigger a state'))
print(sep)
print(row('  STATES              THEMES'))
print(blank)
print(row('  working           · default   ocean    neon'))
print(row('  done              · pastel    dracula  solarized'))
print(row('  attention'))
print(row('  permission'))
print(row('  session.start'))
print(bot)
"
```
