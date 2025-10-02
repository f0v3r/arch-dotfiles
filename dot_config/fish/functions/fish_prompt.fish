function fish_prompt
    set_color yellow
    echo -n (whoami)
    set_color normal
    echo -n ' at '
    set_color red
    echo -n (hostname)' '
    set_color cyan --bold
    echo -n (prompt_pwd)
    set_color magenta
    echo -n (fish_vcs_prompt)
    set_color normal
    echo -n ' > '
end
