$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.config = {
  cursor_shape: {
    vi_insert: line
    vi_normal: block
  }
  history: {
    file_format: sqlite
    isolation: true
  }
  keybindings: [
    {
        name: history_menu
        modifier: control
        keycode: char_r
        mode: [ emacs, vi_insert, vi_normal ]
        event: { send: menu name: history_menu }
    }
    {
      name: move_right_or_take_history_hint
      modifier: control
      keycode: char_f
      mode: [ emacs, vi_insert, vi_normal ]
      event: {
          until: [
              { send: historyhintcomplete }
              { send: menuright }
              { send: right }
          ]
      }
  }
  ]
}
oh-my-posh init nu --config ~/.config/nushell/theme.omp.json
source ~/.oh-my-posh.nu

# argc-completions
$env.ARGC_COMPLETIONS_ROOT = '/home/hjalmarlucius/.local/share/argc-completions'
$env.ARGC_COMPLETIONS_PATH = ($env.ARGC_COMPLETIONS_ROOT + '/completions/linux:' + $env.ARGC_COMPLETIONS_ROOT + '/completions')
$env.PATH = ($env.PATH | prepend ($env.ARGC_COMPLETIONS_ROOT + '/bin'))
argc --argc-completions nushell | save -f '/home/hjalmarlucius/.local/share/argc-completions/tmp/argc-completions.nu'
source '/home/hjalmarlucius/.local/share/argc-completions/tmp/argc-completions.nu'
