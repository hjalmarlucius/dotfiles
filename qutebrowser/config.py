from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Any
    config: Any = None
    c: Any = None

config.load_autoconfig(True)
config.set("content.register_protocol_handler", True, "https://mail.google.com?extsrc=mailto&url=%25s")

config.bind("<", "tab-move -")
config.bind("<Ctrl+Shift+Tab>", "tab-prev")
config.bind("<Ctrl+Tab>", "tab-next")
config.bind("<Ctrl+l>", "cmd-set-text :open {url:pretty}")
config.bind("<Ctrl-r>", "restart", mode="normal")
config.bind("<Ctrl-h>", "history")
config.bind("<F10>", "config-cycle colors.webpage.darkmode.enabled true false ;; restart")
config.bind("<F11>", "config-cycle tabs.position top left")
config.bind("<F12>", "view-source")
config.bind("<Shift+Escape>", "mode-enter passthrough", mode="normal")
config.bind("<Shift+Escape>", "mode-enter passthrough", mode="insert")
config.bind(">", "tab-move +")
config.bind("J", "tab-prev")
config.bind("K", "tab-next")
config.bind("pw", "spawn --userscript qute-bitwarden")
config.bind("tm", "tab-move")
config.bind("to", "tab-focus")
config.bind("ø", "cmd-set-text :")
config.bind("m", 'cmd-set-text :quickmark-add {url:pretty} "', mode="normal")
config.bind("D", "tab-close")
config.unbind("<Ctrl+v>")  # delete tab
config.unbind("d", mode="normal")  # delete tab
config.unbind("q", mode="normal")  # macro recording
config.unbind("M", mode="normal")  # add bookmark
config.unbind("gb", mode="normal")  # load bookmark
config.unbind("gB", mode="normal")  # load bookmark
config.unbind("wB", mode="normal")  # load bookmark

c.auto_save.session = True
c.completion.open_categories = [
    "searchengines",
    "quickmarks",
    "bookmarks",
    "history",
    "filesystem",
]
c.completion.web_history.max_items = 10000
c.completion.height = "100%"
c.content.autoplay = False
c.content.geolocation = False
c.content.cache.size = 52428800
c.content.notifications.enabled = False
c.content.tls.certificate_errors = "ask-block-thirdparty"
c.editor.command = [
    "urxvt",
    "-title",
    "scratchpad",
    "-geometry",
    "86x24+40+60",
    "-e",
    "nvim",
    "-f",
    "{}",
]
c.input.insert_mode.auto_load = True
c.input.insert_mode.plugins = True
c.messages.timeout = 500
c.qt.args = [
    "enable-accelerated-video-decode",
    "enable-gpu-rasterization",
]
c.scrolling.bar = "always"
c.session.lazy_restore = False
c.statusbar.padding = {"bottom": 10, "left": 10, "right": 10, "top": 10}
c.statusbar.position = "top"
c.statusbar.widgets = [
    "keypress",
    "search_match",
    "url",
    "scroll",
    "history",
    "progress",
]
c.tabs.background = True
c.tabs.favicons.show = "never"
c.tabs.indicator.width = 3
c.tabs.last_close = "close"
c.tabs.max_width = 8000
c.tabs.min_width = -1
c.tabs.mode_on_change = "restore"
c.tabs.new_position.related = "next"
c.tabs.padding = {"bottom": 2, "left": 5, "right": 5, "top": 2}
c.tabs.position = "top"
c.tabs.show = "always"
c.tabs.show_switching_delay = 5000
c.tabs.title.format = "{index}.{current_title}"
c.tabs.undo_stack_size = 1000
c.tabs.width = "15%"
c.url.start_pages = "https://rss.hjarl.com"

c.url.searchengines = dict(
    DEFAULT="https://google.com/search?q={}",
    al="https://wiki.archlinux.org/?search={}",
    gh="https://github.com/search?q={}&type=Code",
    ip="https://iplocation.io/ip/{}",
    sh="https://explainshell.com/explain?cmd={}",
    wi="https://en.wikipedia.org/w/index.php?search={}",
    yt="https://yewtu.be/search?q={}",
)

c.colors.tabs.even.bg = "cyan"
c.colors.tabs.even.fg = "black"
c.colors.tabs.odd.bg = "cyan"
c.colors.tabs.odd.fg = "black"
c.fonts.tabs.selected = "10pt sans-serif"
c.fonts.tabs.unselected = "10pt sans-serif"
c.fonts.statusbar = "20px default_family"
