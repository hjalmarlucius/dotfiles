c.InteractiveShellApp.extensions = ["autoreload"]
c.InteractiveShellApp.exec_lines = ["%autoreload 2"]

## Use colors for displaying information about objects. Because this information
#  is passed through a pager (like 'less'), and some pagers get confused with
#  color codes, this capability can be turned off.
#  Default: True
c.InteractiveShell.color_info = True
c.InteractiveShell.separate_in = ""

## Set the color scheme (NoColor, Neutral, Linux, or LightBG).
# c.InteractiveShell.colors = "Linux"
# c.TerminalInteractiveShell.colors = "Linux"

## Set to confirm when you try to exit IPython with an EOF (Control-D in Unix,
#  Control-Z/Enter in Windows). By typing 'exit' or 'quit', you can force a
#  direct exit without any confirmation.
c.TerminalInteractiveShell.confirm_exit = False

## The name or class of a Pygments style to use for syntax highlighting. To see
#  available styles, run `pygmentize -L styles`.
#  Default: traitlets.Undefined
# c.TerminalInteractiveShell.highlighting_style = 'monokai'

## Use 24bit colors instead of 256 colors in prompt highlighting. If your
#  terminal supports true color, the following command should print 'TRUECOLOR'
#  in orange: printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
#  Default: False
c.TerminalInteractiveShell.true_color = True
