# Display options here

set -g DEFAULT_PROMPT_SYMBOL '%'
set -g SUDO_PROMPT_SYMBOL '#'
set -g GIT_DIRTY_SYMBOL '✖︎ '

# Colors defined here

set black (set_color brblack)
set blue (set_color blue)
set cyan (set_color cyan)
set green (set_color green)
set normal (set_color normal)
set white (set_color white)
set yellow (set_color yellow)

# Git related functionality

function _git_display
    set -l git_head (_git_head_repr)
    set -l git_head_tag (_git_head_tag)

    set git_info "$green$git_head"

    if [ -n "$git_head_tag" ]
        set git_info "$git_info$black $git_head_tag"
    end

    if ! _is_git_clean
        set -l dirty "$yellow$GIT_DIRTY_SYMBOL"
        set git_info "$dirty$git_info"
    end

    echo -n "$white at $git_info"
end

function _git_relative_path -a git_root
    set -l relative_path (command realpath --relative-to="$git_root" "$PWD")

    if [ "$relative_path" = "." ]
        set relative_path ""
    else
        set relative_path "/$relative_path"
    end

    prompt_pwd "$(path basename $git_root)$relative_path"
end

function _git_root_dir
    command git rev-parse --show-toplevel 2> /dev/null
end

function _git_head_repr
    command git symbolic-ref --quiet --short HEAD || command git rev-parse --short HEAD
end

function _is_git_clean
    command git diff --quiet
end

function _git_head_tag
    command git tag --points-at HEAD 2>/dev/null
end

# The actual prompt function

function fish_prompt
    set -l cwd $cyan(path basename (prompt_pwd))

    # apply git functionality
    set -l git_root (_git_root_dir)
    if [ "$git_root" ]
        set -f git_display (_git_display)
        set cwd $cyan(_git_relative_path "$git_root")
    end

    set -l output "$cwd"
    set -a output "$git_display"

    # apply multi-line prompt only if there isn't that much space
    set -l prompt_length (string length -V "$output")
    set -l remaining_space (math $COLUMNS - $prompt_length)
    if [ $remaining_space -le 50 ]
        echo -s '| ' $output
    else
        echo -s -n '  ' $output ' '
    end

    set -l prompt_symbol "$DEFAULT_PROMPT_SYMBOL"
    if [ $EUID -eq 0 ]
        set prompt_symbol "$SUDO_PROMPT_SYMBOL"
    end

    echo -n -s "$white$prompt_symbol$normal "
end
