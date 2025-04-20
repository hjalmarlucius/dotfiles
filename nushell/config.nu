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
        name: history_menu
        modifier: none
        keycode: char_/
        mode: [ vi_normal ]
        event: { send: menu name: history_menu }
    }
    {
      name: clear_everything
      modifier: control
      keycode: char_b
      mode: [ emacs, vi_insert, vi_normal ]
      event: [
        { send: clearscreen }
        { send: clearscrollback }
      ]
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
    {
      name: delete_one_word_backward
      modifier: alt
      keycode: backspace
      mode: vi_insert
      event: {edit: backspaceword}
    }
  ]
}

# from: https://github.com/nushell/nushell/issues/8166
def monitor [
  --duration (-d): duration = 1sec
  ...args
] {
  let args = $args | into string
  let cmd = $args | str join ' '

  loop {
      let last_run = (date now)
      let till = $last_run + $duration

      let out = nu --config $nu.config-path --env-config $nu.env-path --commands $cmd | complete

      if $out.exit_code == 0 {
        clear
        print $"Running every ($duration) on '(hostname)': `($cmd)`"

        print $out.stdout

        print $"Last run: ($last_run)"
        sleep ($till - (date now))
      } else {
        print $out.stdout $out.stderr
        break
      }
  }
}

source ~/.oh-my-posh.nu

# argc-completions
$env.ARGC_COMPLETIONS_ROOT = '/home/hjalmarlucius/.local/share/argc-completions'
$env.ARGC_COMPLETIONS_PATH = ($env.ARGC_COMPLETIONS_ROOT + '/completions/linux:' + $env.ARGC_COMPLETIONS_ROOT + '/completions')
$env.PATH = ($env.PATH | prepend ($env.ARGC_COMPLETIONS_ROOT + '/bin'))
argc --argc-completions nushell | save -f '/home/hjalmarlucius/.local/share/argc-completions/tmp/argc-completions.nu'
source '/home/hjalmarlucius/.local/share/argc-completions/tmp/argc-completions.nu'
