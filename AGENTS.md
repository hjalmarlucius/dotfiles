# Working in this repo

The owner's dotfiles. `endos.py` installs them per host: it symlinks files from this checkout, `~/dotfiles`, into `~` and `~/.config` (with `custom-<hostname>/` for one machine), copies a few into `/` with sudo, and installs packages. So this checkout is live: an edit to a symlinked file changes the running setup at once. Issues are tracked on Gitea (`henrik/dotfiles`); GitHub (`hjalmarlucius/dotfiles`) is a public mirror.

Read every session:

- This file.
- Your open issues: `gt issue list -R henrik/dotfiles --label owner/agent-dotfiles`, with their comments.

## Owners

| Name | Account | Owns |
| --- | --- | --- |
| AGENT_DOTFILES | `agent-dotfiles` | Changes to this repository, made directly in `~/dotfiles`, and its issues. |

The owner decides `kind/decide` issues, reviews your commits, pushes to both remotes, and runs `endos.py`.

## Working directly in the live checkout

- Work in `~/dotfiles`, on `main`. Never switch branches, rebase, reset, stash or check out files here: each of those changes the running setup, and the owner often has uncommitted work in this checkout.
- The owner's uncommitted changes are theirs: leave them as they are. Before you edit a file, check `git status` and `git diff` for it. If it already has changes you did not make, ask on the issue first rather than mixing your edit in.
- Your edits take effect at once for every file `endos.py` symlinks. Make each change in one go, so that no half-edited configuration is left live, and check it before the next one (see the checks below).
- Never run `endos.py`: it installs packages, writes to `/`, and needs sudo. Never edit files under `~`, `~/.config` or `/` directly; change them here.

## Public repository

- The repository is public on both remotes. Never commit secrets, tokens, passwords, private keys, email addresses, phone numbers, home IP addresses or private URLs. Read your whole diff for them before every commit.
- Leave `.gitsecret/`, the `*.secret` files and the plaintext files they encrypt (listed in `.gitignore`) alone. Never run `git secret reveal` or `git secret hide`. A change that needs a secret goes on an issue for the owner.
- A value that differs per machine goes in `custom-<hostname>/`, only for the host the issue names, or in an untracked local file.

## Identity and Gitea

- Your name goes in the body of your commits.
- Use `gt` with your own token only: `export GITEA_CLI_HOST=https://git.hjarl.com GITEA_TOKEN=$(cat ~/.config/hjarl/agent-dotfiles.token)`; commands take `-R henrik/dotfiles`.

## Issues

- Open work is Gitea issues, labelled `kind/` (`bug`, `do`, `idea`, `decide`, `plan`), `owner/agent-dotfiles`, `area/<tool>` (`nvim`, `zsh`, `sway`, `tmux`, `endos`, …), `size/` (`S`, `M`, `L`), and `status/plausible` on a bug not yet verified.
- A bug states the defect, where it is (`file:line`) and how it shows. Verify it before dropping `status/plausible`.
- `kind/do` is agreed work; `kind/idea` waits for the owner to relabel it `kind/do`; `kind/decide` needs the owner's call.
- An inconsistency met on the way is a bug: fix it if small, else open an issue.

## Commits

- Commit only your own changes, on `main`: `git add` names each file, and `git add -p` takes only your hunks when a file also holds the owner's changes. Never `git add -A` or `git commit -a`.
- Commits are small and each one is valid on its own; commit line `<tool>: <imperative summary>` (`nvim: ...`, `sway: ...`, `endos: ...`), body says what and why and refers to the issue as `#N`.
- Never push: the owner reviews your commits and pushes them. Comment on the issue with the commit, the checks and their results, and what the owner must do beyond pulling (see below), then leave the issue for the owner to close.

## Checks after each change

- Syntax-check every file you changed: `luac -p` for Lua, `zsh -n` for zsh, `bash -n` for shell scripts, `python -m py_compile` for Python, and the tool's own check where it has one (`sway -C -c CONFIG/sway/config`).
- `uvx ruff check endos.py` already reports findings on `main`; a change to `endos.py` adds none.
- After a Neovim change, load the configuration headless: `nvim --headless +qa`, and report its errors.
- A change to `endos.py`, or one that adds, moves or removes a file it installs, lists in the issue every target under `~`, `~/.config` or `/` that is added, moved or removed.

## Beyond the checkout

- Only the owner runs `endos.py`. A change that needs a step beyond editing files here (a package or plugin install, a new symlink, a sudo copy, a reload of a running program) lists the exact commands on its issue.
