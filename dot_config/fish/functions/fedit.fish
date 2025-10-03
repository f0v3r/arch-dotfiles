function fedit --wraps='fzf | xargs -r helix' --description 'alias fedit=fzf | xargs -r helix'
    fzf | xargs -r helix $argv
end
