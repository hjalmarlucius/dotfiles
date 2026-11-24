# Working in this repo

The owner's dotfiles. `endos.py` installs them per host: it symlinks files from this checkout, `~/dotfiles`, into `~` and `~/.config` (with `custom-<hostname>/` for one machine), copies a few into `/` with sudo, and installs packages. So this checkout is live: an edit to a symlinked file changes the running setup at once. Issues are tracked on Gitea (`henrik/dotfiles`); GitHub (`hjalmarlucius/dotfiles`) is a public mirror.

Read every session:

- This file.
- The open issues and pull requests: `gt issue list -R henrik/dotfiles` and `gt pr list -R henrik/dotfiles`, with their comments and reviews.

## Owners

| Name | Account | Owns |
| --- | --- | --- |
| AGENT_DOTFILES | `agent-dotfiles` | Changes to this repository, made on `agent/*` branches and offered as draft pull requests, and its issues. |

The owner decides `decide:` issues, reviews and merges your pull requests, pushes `main` to both remotes, and runs `endos.py`.

## The live checkout and your worktrees

- `~/dotfiles` is live: never edit, commit, switch branches, rebase, reset, stash or check out files there. Each of those changes the running setup, and the owner often has uncommitted work in it, which is theirs.
- Work in a worktree of your own outside the checkout, one branch per issue, based on Gitea's `main` rather than the local one (which can hold the owner's unpushed commits): `git -C ~/dotfiles fetch https://git.hjarl.com/henrik/dotfiles.git main`, then `git -C ~/dotfiles worktree add -b agent/<N>-<slug> <dir> FETCH_HEAD`. Remove the worktree when the branch is done; the branch keeps the work.
- Nothing you change takes effect until the owner merges and pulls, so check each change before you commit it (see the checks below).
- Never run `endos.py`: it installs packages, writes to `/`, and needs sudo. Never edit files under `~`, `~/.config` or `/` directly; change them in your worktree.

## Public repository

- The repository is public on both remotes. Never commit secrets, tokens, passwords, private keys, email addresses, phone numbers, home IP addresses or private URLs. Read your whole diff for them before every commit.
- Leave `.gitsecret/`, the `*.secret` files and the plaintext files they encrypt (listed in `.gitignore`) alone. Never run `git secret reveal` or `git secret hide`. A change that needs a secret goes on an issue for the owner.
- A value that differs per machine goes in `custom-<hostname>/`, only for the host the issue names, or in an untracked local file.

## Identity and Gitea

- Your name goes in the body of your commits.
- Use `gt` with your own token only: `export GITEA_CLI_HOST=https://git.hjarl.com GITEA_TOKEN=$(cat ~/.config/hjarl/agent-dotfiles.token)`; commands take `-R henrik/dotfiles`.

## Issues

- Open work is Gitea issues, without labels. The title says the tool and the problem: `<tool>: <summary>` (`nvim: ...`, `sway: ...`). A question only the owner can answer has a title starting `decide:`.
- A bug states the defect, where it is (`file:line`) and how it shows. Mark a point you have not verified "(plausible)", and drop the mark once you have.
- An issue the owner opened, or one they have answered, is agreed work. Otherwise, ask on the issue before starting anything that isn't a plain bug fix.
- When the owner asks for something in chat, open an issue for it first, so the branch and pull request have a number.
- An inconsistency met on the way is a bug: fix it if small, else open an issue.

## Commits

- Commit only on your `agent/*` branch: `git add` names each file. Never `git add -A` or `git commit -a`.
- Commits are small and each one is valid on its own; commit line `<tool>: <imperative summary>` (`nvim: ...`, `sway: ...`, `endos: ...`), body says what and why and refers to the issue as `#N`.
- Push only `agent/*` branches, only to `https://git.hjarl.com/henrik/dotfiles.git`, with your own token (a `credential.helper` override, never the owner's stored credentials). Never push `main`, and never push to GitHub.
- Open a draft pull request per branch, titled `WIP: <commit-style title>`. Its text says what changed per issue item, the checks and their results, and what the owner must do beyond pulling (see below), and ends with `Fixes #N`. The owner reviews, merges and closes the issue.

## Checks after each change

- Syntax-check every file you changed: `luac -p` for Lua, `zsh -n` for zsh, `bash -n` for shell scripts, `python -m py_compile` for Python, and the tool's own check where it has one (`sway -C -c CONFIG/sway/config`). That sway check also reads the live `~/.config/sway/local_config`; to check a `custom-<host>/` change, run it with `HOME` set to a temporary folder that links that host's `local_config`.
- `uvx ruff check endos.py` already reports findings on `main`; a change to `endos.py` adds none.
- After a Neovim change, load the worktree's configuration headless (plain `nvim` reads the live one): `nvim --headless -u <worktree>/CONFIG/nvim/init.lua +qa`, and report its errors.
- A change to `endos.py`, or one that adds, moves or removes a file it installs, lists in its pull request every target under `~`, `~/.config` or `/` that is added, moved or removed.

## Beyond the checkout

- Only the owner runs `endos.py`. A change that needs a step beyond merging and pulling (a package or plugin install, a new symlink, a sudo copy, a reload of a running program) lists the exact commands in its pull request.
