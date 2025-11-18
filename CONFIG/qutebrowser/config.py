from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Any

    config: Any = None
    c: Any = None

config.load_autoconfig(True)
config.bind("<", "tab-move -")
config.bind("<Ctrl+Shift+Tab>", "tab-prev")
config.bind("<Ctrl+Tab>", "tab-next")
config.bind("<Ctrl+l>", "cmd-set-text :open {url:pretty}")
config.bind("<Ctrl+r>", "reload")
config.bind("<Ctrl+n>", "tab-clone -w")
config.bind("<Ctrl+t>", "tab-clone -t")
config.bind("<Ctrl+Shift+r>", "restart", mode="normal")
config.bind("<Ctrl+h>", "history")
config.bind("<F8>", "config-cycle colors.webpage.darkmode.enabled true false")
config.bind("<F11>", "config-cycle tabs.position top left")
config.bind("<F12>", "devtools")
config.bind("<Shift+F12>", "view-source")
config.bind("<Shift+Escape>", "mode-enter passthrough", mode="normal")
config.bind("<Shift+Escape>", "mode-enter passthrough", mode="insert")
config.bind(">", "tab-move +")
config.bind("K", "tab-prev")
config.bind("J", "tab-next")
fuzzelargs = """--dmenu-invocation 'fuzzel --dmenu -p "Bitwarden"' --password-prompt-invocation 'fuzzel --dmenu -p "Master Password: " --password --lines 0'"""
config.bind("pww", f"spawn --userscript qute-bitwarden {fuzzelargs}")
config.bind("pwu", f"spawn --userscript qute-bitwarden {fuzzelargs} --username-only")
config.bind("pwp", f"spawn --userscript qute-bitwarden {fuzzelargs} --password-only")
config.bind("pwo", f"spawn --userscript qute-bitwarden {fuzzelargs} --totp-only")
config.bind("do", "download-open")
config.bind("dx", "download-cancel")
config.bind("dD", "download-delete")
config.bind("dr", "download-retry")
config.bind("dC", "download-clear")
config.bind("dc", "download-remove")
config.bind("tm", "tab-move")
config.bind("to", "tab-focus")
config.bind("tj", "back -t", mode="normal")
config.bind("wj", "back -w", mode="normal")
config.bind("tk", "forward -t", mode="normal")
config.bind("wk", "forward -w", mode="normal")
config.bind("ø", "cmd-set-text :")
config.bind("m", 'cmd-set-text :quickmark-add {url:pretty} "', mode="normal")
config.bind("D", "tab-close")
config.bind(",m", "hint links spawn mpv {hint-url}", mode="normal")
config.bind(",M", "spawn mpv {url}", mode="normal")
config.unbind("co")  # close all tabs except this one
config.unbind("<Ctrl+x>")  # navigate decrement
config.unbind("<Ctrl+a>")  # navigate increment
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
    "history",
    "filesystem",
]
c.content.register_protocol_handler = False
c.content.blocking.enabled = True
c.content.fullscreen.window = True
c.content.blocking.method = "both"
c.content.blocking.adblock.lists = [
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext",
]
c.completion.web_history.max_items = 10000
c.completion.height = "100%"
c.confirm_quit = ["multiple-tabs", "downloads"]
c.content.javascript.clipboard = "ask"
c.content.local_content_can_access_remote_urls = True
c.content.autoplay = False
c.content.geolocation = False
c.content.cache.size = 52428800
c.content.notifications.enabled = False
c.content.tls.certificate_errors = "ask-block-thirdparty"

urlconfigs: dict[str, list[tuple[str, bool | str | dict[str, str]]]] = {
    "https://meet.google.com": [
        ("content.desktop_capture", True),
        ("content.media.audio_video_capture", True),
        ("content.media.video_capture", True),
        ("content.media.audio_capture", True),
    ],
    "https://mail.google.com": [("content.javascript.clipboard", "access-paste")],
    "https://*.hjarl.com": [("content.javascript.clipboard", "access-paste")],
    "https://chatgpt.com": [("content.javascript.clipboard", "access-paste")],
    "*://*.youtube.com/*": [
        (
            "content.headers.custom",
            {"X-YouTube-Client-Name": "85", "X-YouTube-Client-Version": "2.0"},
        )
    ],
}
for url, urlconfig in urlconfigs.items():
    for setting, value in urlconfig:
        config.set(setting, value, url)

c.downloads.position = "bottom"
c.downloads.prevent_mixed_content = False
c.editor.command = [
    "foot",
    "-title",
    "scratchpad",
    "-geometry",
    "86x24+40+60",
    "-e",
    "nvim",
    "-f",
    "{}",
]
c.hints.padding = {"bottom": 2, "left": 5, "right": 5, "top": 2}
c.hints.border = "none"
c.input.insert_mode.auto_load = True
c.input.insert_mode.auto_leave = False
c.input.insert_mode.plugins = True
c.messages.timeout = 5000
c.qt.highdpi = True
c.scrolling.bar = "always"
c.scrolling.smooth = False
c.session.lazy_restore = False
c.session.default_name = "hb"
c.statusbar.padding = {"bottom": 5, "left": 5, "right": 5, "top": 5}
c.statusbar.position = "bottom"
c.statusbar.show = "always"
c.statusbar.widgets = [
    "keypress",
    "search_match",
    "url",
    "scroll",
    "history",
    "progress",
]
c.tabs.background = True
c.tabs.favicons.show = "pinned"
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
c.tabs.tabs_are_windows = False
c.tabs.title.format = "{index}.{current_title}"
c.tabs.undo_stack_size = 1000
c.tabs.width = "15%"
c.url.start_pages = "http://www.google.com/search?hl=en&source=hp"
c.url.default_page = "http://www.google.com/search?hl=en&source=hp"
c.url.searchengines = dict(
    DEFAULT="http://www.google.com/search?hl=en&source=hp&q={}",
    aw="https://wiki.archlinux.org/?search={}",
    ap="https://www.archlinux.org/packages/?q={}",
    gh="https://github.com/search?q={}&type=repositories",
    ip="https://iplocation.io/ip/{}",
    sh="https://explainshell.com/explain?cmd={}",
    wi="https://en.wikipedia.org/w/index.php?search={}",
    yt="https://yewtu.be/search?q={}",
)
c.zoom.default = "100%"

# FONTS
c.fonts.default_family = ["Iosevka"]
c.fonts.default_size = "12pt"
c.fonts.prompts = "12pt Iosevka"
c.fonts.web.family.sans_serif = "IBM Plex Sans"
c.fonts.web.family.serif = "IBM Plex Serif"
c.fonts.web.family.fixed = "IBM Plex Mono"
c.fonts.web.family.standard = c.fonts.web.family.sans_serif

# COLORS
base00 = "#181818"
base01 = "#282828"
base02 = "#383838"
base03 = "#585858"
base04 = "#b8b8b8"
base05 = "#d8d8d8"
base06 = "#e8e8e8"
base07 = "#f8f8f8"
base08 = "#ab4642"
base09 = "#dc9656"
base0A = "#f7ca88"
base0B = "#a1b56c"
base0C = "#86c1b9"
base0D = "#7cafc2"
base0E = "#ba8baf"
base0F = "#a16946"
c.colors.webpage.preferred_color_scheme = "light"
c.colors.webpage.darkmode.enabled = False

# from https://raw.githubusercontent.com/tinted-theming/base16-qutebrowser/refs/heads/main/templates/default.mustache
c.colors.completion.fg = base05
c.colors.completion.odd.bg = base01
c.colors.completion.even.bg = base00
c.colors.completion.category.fg = base0A
c.colors.completion.category.bg = base00
c.colors.completion.category.border.top = base00
c.colors.completion.category.border.bottom = base00
c.colors.completion.item.selected.fg = base05
c.colors.completion.item.selected.bg = base02
c.colors.completion.item.selected.border.top = base02
c.colors.completion.item.selected.border.bottom = base02
c.colors.completion.item.selected.match.fg = base0B
c.colors.completion.match.fg = base0B
c.colors.completion.scrollbar.fg = base05
c.colors.completion.scrollbar.bg = base00
c.colors.contextmenu.disabled.bg = base01
c.colors.contextmenu.disabled.fg = base04
c.colors.contextmenu.menu.bg = base00
c.colors.contextmenu.menu.fg = base05
c.colors.contextmenu.selected.bg = base02
c.colors.contextmenu.selected.fg = base05
c.colors.downloads.bar.bg = base00
c.colors.downloads.start.fg = base00
c.colors.downloads.start.bg = base0D
c.colors.downloads.stop.fg = base00
c.colors.downloads.stop.bg = base0C
c.colors.downloads.error.fg = base08
c.colors.hints.fg = base00
c.colors.hints.bg = base0A
c.colors.hints.match.fg = base05
c.colors.keyhint.fg = base05
c.colors.keyhint.suffix.fg = base05
c.colors.keyhint.bg = base00
c.colors.messages.error.fg = base00
c.colors.messages.error.bg = base08
c.colors.messages.error.border = base08
c.colors.messages.warning.fg = base00
c.colors.messages.warning.bg = base0E
c.colors.messages.warning.border = base0E
c.colors.messages.info.fg = base05
c.colors.messages.info.bg = base00
c.colors.messages.info.border = base00
c.colors.prompts.fg = base05
c.colors.prompts.border = base00
c.colors.prompts.bg = base00
c.colors.prompts.selected.bg = base02
c.colors.prompts.selected.fg = base05
c.colors.statusbar.normal.fg = base0B
c.colors.statusbar.normal.bg = base00
c.colors.statusbar.insert.fg = base00
c.colors.statusbar.insert.bg = base0D
c.colors.statusbar.passthrough.fg = base00
c.colors.statusbar.passthrough.bg = base0C
c.colors.statusbar.private.fg = base00
c.colors.statusbar.private.bg = base01
c.colors.statusbar.command.fg = base05
c.colors.statusbar.command.bg = base00
c.colors.statusbar.command.private.fg = base05
c.colors.statusbar.command.private.bg = base00
c.colors.statusbar.caret.fg = base00
c.colors.statusbar.caret.bg = base0E
c.colors.statusbar.caret.selection.fg = base00
c.colors.statusbar.caret.selection.bg = base0D
c.colors.statusbar.progress.bg = base0D
c.colors.statusbar.url.fg = base05
c.colors.statusbar.url.error.fg = base08
c.colors.statusbar.url.hover.fg = base05
c.colors.statusbar.url.success.http.fg = base0C
c.colors.statusbar.url.success.https.fg = base0B
c.colors.statusbar.url.warn.fg = base0E
c.colors.tabs.bar.bg = base00
c.colors.tabs.indicator.start = base0D
c.colors.tabs.indicator.stop = base0C
c.colors.tabs.indicator.error = base08
c.colors.tabs.odd.fg = base05
c.colors.tabs.odd.bg = base01
c.colors.tabs.even.fg = base05
c.colors.tabs.even.bg = base00
c.colors.tabs.pinned.even.bg = base0C
c.colors.tabs.pinned.even.fg = base07
c.colors.tabs.pinned.odd.bg = base0B
c.colors.tabs.pinned.odd.fg = base07
c.colors.tabs.pinned.selected.even.bg = base02
c.colors.tabs.pinned.selected.even.fg = base05
c.colors.tabs.pinned.selected.odd.bg = base02
c.colors.tabs.pinned.selected.odd.fg = base05
c.colors.tabs.selected.odd.fg = base05
c.colors.tabs.selected.odd.bg = base02
c.colors.tabs.selected.even.fg = base05
c.colors.tabs.selected.even.bg = base02

# overrides
c.colors.hints.fg = base05
c.colors.hints.bg = base02
c.colors.hints.match.fg = base0A
c.colors.tabs.selected.odd.bg = "teal"
c.colors.tabs.selected.even.bg = "teal"
