$env.config.buffer_editor = "/usr/bin/nvim"
$env.SYSTEMD_EDITOR = "/usr/bin/nvim"
$env.EDITOR = "/usr/bin/nvim"
$env.VISUAL = "/usr/bin/nvim"
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
      name: fuzzy_history_fzf
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: {
        send: ExecuteHostCommand
        cmd: "commandline edit --insert (
          history
          | where exit_status == 0
          | get command
          | reverse
          | uniq
          | str join (char -i 0)
          | fzf 
            --preview '{}'
            --preview-window 'bottom:3:wrap'
            --scheme history
            --read0
            --layout reverse
            --bind alt-up:preview-up,alt-down:preview-down
            --height 70%
            --query (commandline)
          | decode utf-8
          | str trim
        )"
      }
    }
    {
      name: fuzzy_history_fzf
      modifier: none
      keycode: char_/
      mode: [ vi_normal ]
      event: { send: menu name: fuzzy_history_fzf }
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

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
  # carapace doesn't give completions if you don't give it any additional
  # args
  mut spans = $spans
  if ($spans | is-empty) {
    $spans = [""]
  }

  carapace $spans.0 nushell ...$spans | from json
    # sort by color
    | sort-by {
      let fg = $in | get -i style.fg
      let attr = $in | get -i style.attr

      # the ~ there to make "empty" results appear at the end
      $"($fg)~($attr)"
    }
}
$env.config.completions.external = {
  enable: true
  max_results: 100
  completer: $carapace_completer
}
