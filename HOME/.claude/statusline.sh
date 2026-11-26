#!/bin/bash
# Claude Code status line (settings.json statusLine): model, folder, git
# branch, context used, weekly limit used, and the open pull requests of the
# repository's git.hjarl.com remote. PR numbers are links (Ctrl+click in
# foot); drafts are dim. Claude Code passes its session data as JSON on stdin.
in=$(cat)
field() { jq -r "$1 // empty" <<<"$in" 2>/dev/null; }

dim=$'\e[2m' yellow=$'\e[33m' red=$'\e[31m' off=$'\e[0m'
pct() { # colour a percentage: yellow from 50, red from 80
    local p=${1%.*} c=
    [ -z "$p" ] && return
    ((p >= 80)) && c=$red || { ((p >= 50)) && c=$yellow; }
    printf '%s %s%s%%%s' "$2" "$c" "$p" "$off"
}

dir=$(field .workspace.current_dir)
[ -n "$dir" ] || dir=$(field .cwd)
parts=("$(field .model.display_name)" "${dir##*/}")
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[ -n "$branch" ] && parts+=("$branch")
ctx=$(pct "$(field .context_window.used_percentage)" ctx) && [ -n "$ctx" ] && parts+=("$ctx")
week=$(pct "$(field .rate_limits.seven_day.used_percentage)" week) && [ -n "$week" ] && parts+=("$week")

# Open pull requests on git.hjarl.com, cached for a minute per repository
url=$(git -C "$dir" remote -v 2>/dev/null | awk '$2 ~ /git\.hjarl\.com[:\/]/ {print $2; exit}')
if [ -n "$url" ]; then
    repo=${url#*git.hjarl.com}
    repo=${repo#[:/]}
    repo=${repo%.git}
    cache=${XDG_RUNTIME_DIR:-/tmp}/claude-statusline/${repo//\//_}
    if [ -z "$(find "$cache" -mmin -1 2>/dev/null)" ]; then
        mkdir -p "${cache%/*}"
        token=$(gt auth token --host git.hjarl.com 2>/dev/null)
        if [ -n "$token" ] && json=$(curl -sf -m 2 \
            -H @<(printf 'Authorization: token %s\n' "$token") \
            "https://git.hjarl.com/api/v1/repos/$repo/pulls?state=open&limit=20"); then
            jq -r '.[] | [.number, .html_url, (.draft or (.title | test("^WIP")))] | @tsv' \
                <<<"$json" >"$cache.tmp" 2>/dev/null && mv "$cache.tmp" "$cache"
        fi
        touch "$cache" 2>/dev/null # retry after a minute, also on failure
    fi
    prs=
    n=0
    while IFS=$'\t' read -r number link draft; do
        ((n++ < 6)) || continue
        [ "$draft" = true ] && c=$dim || c=
        prs+=" ${c}"$'\e]8;;'"$link"$'\e\\'"#$number"$'\e]8;;\e\\'"$off"
    done <"$cache"
    ((n > 6)) && prs+=" +$((n - 6))"
    [ -n "$prs" ] && parts+=("PRs$prs")
fi

out=
for p in "${parts[@]}"; do
    [ -n "$p" ] && out+="${out:+ · }$p"
done
printf '%s\n' "$out"
