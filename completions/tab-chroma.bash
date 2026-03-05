#!/usr/bin/env bash
# tab-chroma bash/zsh completions

_tab_chroma_completions() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  local pprev="${COMP_WORDS[COMP_CWORD-2]:-}"

  case "$prev" in
    tab-chroma)
      COMPREPLY=( $(compgen -W "pause resume toggle status theme badge title color test reset help version" -- "$cur") )
      return 0
      ;;
    theme)
      COMPREPLY=( $(compgen -W "list use next preview" -- "$cur") )
      return 0
      ;;
    use|preview)
      local themes_dir="$HOME/.claude/hooks/tab-chroma/themes"
      local names
      names=$(ls -d "$themes_dir"/*/ 2>/dev/null | xargs -n1 basename 2>/dev/null)
      COMPREPLY=( $(compgen -W "$names" -- "$cur") )
      return 0
      ;;
    badge|title|color)
      COMPREPLY=( $(compgen -W "on off" -- "$cur") )
      return 0
      ;;
    test)
      COMPREPLY=( $(compgen -W "working done attention permission session.start" -- "$cur") )
      return 0
      ;;
  esac

  # Handle: tab-chroma theme use <name>
  if [ "$pprev" = "theme" ] && [ "$prev" = "use" ]; then
    local themes_dir="$HOME/.claude/hooks/tab-chroma/themes"
    local names
    names=$(ls -d "$themes_dir"/*/ 2>/dev/null | xargs -n1 basename 2>/dev/null)
    COMPREPLY=( $(compgen -W "$names" -- "$cur") )
    return 0
  fi
}

complete -F _tab_chroma_completions tab-chroma
