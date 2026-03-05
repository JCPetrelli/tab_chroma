# tab-chroma fish completions

function __tab_chroma_no_subcommand
    not __fish_seen_subcommand_from pause resume toggle status theme badge title color test reset help version
end

function __tab_chroma_theme_subcommand
    __fish_seen_subcommand_from theme
end

function __tab_chroma_feature_subcommand
    __fish_seen_subcommand_from badge title color
end

function __tab_chroma_test_subcommand
    __fish_seen_subcommand_from test
end

function __tab_chroma_theme_names
    set themes_dir $HOME/.claude/hooks/tab-chroma/themes
    if test -d $themes_dir
        ls -d $themes_dir/*/ 2>/dev/null | xargs -n1 basename 2>/dev/null
    end
end

complete -c tab-chroma -f

# Top-level subcommands
complete -c tab-chroma -n __tab_chroma_no_subcommand -a pause      -d "Disable color changes"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a resume     -d "Re-enable color changes"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a toggle     -d "Toggle pause state"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a status     -d "Show current config and state"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a theme      -d "Manage themes"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a badge      -d "Toggle badge on/off"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a title      -d "Toggle tab title on/off"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a color      -d "Toggle tab color on/off"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a test       -d "Test a visual state"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a reset      -d "Reset tab to default color"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a help       -d "Show help"
complete -c tab-chroma -n __tab_chroma_no_subcommand -a version    -d "Show version"

# theme subcommands
complete -c tab-chroma -n __tab_chroma_theme_subcommand -a list    -d "List installed themes"
complete -c tab-chroma -n __tab_chroma_theme_subcommand -a use     -d "Switch active theme"
complete -c tab-chroma -n __tab_chroma_theme_subcommand -a next    -d "Cycle to next theme"
complete -c tab-chroma -n __tab_chroma_theme_subcommand -a preview -d "Preview all states of a theme"

# theme names after 'use' and 'preview'
complete -c tab-chroma -n "__tab_chroma_theme_subcommand and __fish_seen_subcommand_from use preview" \
    -a "(__tab_chroma_theme_names)" -d "Theme name"

# feature toggles
complete -c tab-chroma -n __tab_chroma_feature_subcommand -a on  -d "Enable"
complete -c tab-chroma -n __tab_chroma_feature_subcommand -a off -d "Disable"

# test states
complete -c tab-chroma -n __tab_chroma_test_subcommand -a working       -d "Claude is working"
complete -c tab-chroma -n __tab_chroma_test_subcommand -a done          -d "Ready for input"
complete -c tab-chroma -n __tab_chroma_test_subcommand -a attention     -d "Needs attention"
complete -c tab-chroma -n __tab_chroma_test_subcommand -a permission    -d "Needs approval"
complete -c tab-chroma -n __tab_chroma_test_subcommand -a session.start -d "Session started"
