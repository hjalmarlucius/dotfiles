function fish_user_key_bindings
  for mode in insert default visual
        bind -M $mode \cf forward-char
  end
  bind -M insert \ew __fzf_reverse_isearch
  bind -M insert \eo '__fzf_cd --hidden'
  bind -M insert \eF __fzf_find_file
  bind -M insert \ef __fzf_open
end

function ll --description 'List contents of directory using long format'
    ls -lha $argv
end

fzf_key_bindings
