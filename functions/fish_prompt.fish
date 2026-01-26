# Display options here

set -g OVERFLOW_PROMPT_SYMBOL '⋮'
set -g DEFAULT_PROMPT_SYMBOL '→'
set -g SUDO_PROMPT_SYMBOL '#'

set -g GIT_REBASE_SYMBOL '↯'
set -g GIT_MERGE_SYMBOL '↯'
set -g GIT_DIRTY_SYMBOL '±'

# Colors defined here

set black (set_color brblack)
set blue (set_color blue)
set cyan (set_color cyan)
set green (set_color green)
set normal (set_color normal)
set white (set_color white)
set yellow (set_color yellow)

# Git related functionality

function _git_display -a git_root
    set -l git_head (_git_head_repr)
    set -l git_head_tag (_git_head_tag)

    set git_info "$green$git_head"

    if [ -n "$git_head_tag" ]
        set git_info "$git_info$black $git_head_tag"
    end

    set -l symbol
    if _is_git_rebasing "$git_root"
        set symbol "$yellow$GIT_REBASE_SYMBOL"
    else if _is_git_merging "$git_root"
        set symbol "$yellow$GIT_MERGE_SYMBOL "
    else if ! _is_git_clean
        set symbol "$yellow$GIT_DIRTY_SYMBOL "
    end

    set git_info "$symbol$git_info"

    echo -s -n $white "at $git_info"
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

function _is_git_rebasing -a git_root
    test -d "$git_root/.git/rebase-merge" \
        -o -d "$git_root/.git/rebase-apply"
end

function _is_git_merging -a git_root
    test -f "$git_root/.git/MERGE_HEAD"
end

function _is_git_clean
    # first trying the fastest way of checking, which excludes untracked files
    # otherwise we are checking for all files, using read as a quick-exit
    command git diff --quiet \
        && git diff --quiet --staged \
        && ! command git status --porcelain | read -n 1 >/dev/null 2>&1
end

function _git_head_tag
    command git tag --points-at HEAD 2>/dev/null
end

# The actual prompt function

function fish_prompt
    set -l cwd $cyan(path basename (prompt_pwd))
    set -l output "$cwd"

    # apply git functionality
    set -l git_root (_git_root_dir)
    if [ -n "$git_root" ]
        set -l git_display (_git_display "$git_root")
        set -l git_cwd $cyan(_git_relative_path "$git_root")

        set output "$git_cwd $git_display"
    end

    # apply multi-line prompt only if there isn't that much space
    set -l prompt_length (string length -V "$output")
    set -l remaining_space (math $COLUMNS - $prompt_length)
    if [ $remaining_space -le 50 ]
        echo "$OVERFLOW_PROMPT_SYMBOL $output"
    else
        echo -n "  $output "
    end

    set -l prompt_symbol "$DEFAULT_PROMPT_SYMBOL"
    if [ $EUID -eq 0 ]
        set prompt_symbol "$SUDO_PROMPT_SYMBOL"
    end

    echo -n -s "$white$prompt_symbol$normal "
end
