set -g FAILURE_SYMBOL '✖︎'

if test "$TERMINAL_EMULATOR" = "JetBrains-JediTerm"
    # this prevents an extremely weird wrapping bug in JetBrains IDEs
    set -g FAILURE_SYMBOL 'x'
end

function _get_status_message -a code
    switch $code
    case 126
        echo -n "permission denied"
    case 127
        # command not found, nothing needed this is self-explanatory
    case 129
        echo -n "sighup"
    case 130
        echo -n "sigint"
    case 131
        echo -n "sigquit"
    case 132
        echo -n "sigill"
    case 133
        echo -n "sigtrap"
    case 134
        echo -n "sigabrt"
    case 135
        echo -n "sigbus"
    case 136
        echo -n "sigfpe"
    case 137
        echo -n "sigkill"
    case '*'
        echo -n "$code"
    end
end

function fish_right_prompt
    set -l temp_status $status

    set -l normal (set_color normal)
    set -l red (set_color red)
    set -l green (set_color green)

    if [ ! $temp_status -eq 0 ]
        echo -s -n $red (_get_status_message "$temp_status") " $FAILURE_SYMBOL " $normal
    end
end
