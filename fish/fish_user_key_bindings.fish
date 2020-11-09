function fish_user_key_bindings
  bind --preset _ beginning-of-line
  bind \eh __fzf_reverse_isearch
  bind \eF __fzf_open
  bind -M insert \ec '__fzf_cd --hidden'
  bind -M insert \ep __fzf_find_file
  bind -M insert \ef '__fzf_open --editor'
end

fzf_key_bindings
