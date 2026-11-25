"""Links from ~ and ~/.config into the checkout."""

import os
from difflib import unified_diff
from pathlib import Path

import gate
from paths import CFG, CUSTOM, DOTFILES, HOME

TREES = (
    (DOTFILES / "HOME", HOME),
    (DOTFILES / "CONFIG", CFG),
    (CUSTOM / "CONFIG", CFG),
)
PRIVATE = ("CONFIG/aerc/accounts.conf", "CONFIG/vdirsyncer/config")  # mode 600


def list_files(root: Path, *options: str) -> list[str]:
    output = gate.query("git", "ls-files", "-z", *options, cwd=root)
    return [name for name in output.split("\0") if name]


def tracked(root: Path) -> list[Path]:
    """Files in git below root. A git-secret file x.secret stands for x."""
    found = []
    for name in list_files(root) if root.is_dir() else ():
        rel = Path(name.removesuffix(".secret"))
        if (root / rel).is_file():
            found.append(rel)
        else:
            print(f"! missing (secret not revealed?): {root / rel}")
    return found


def into_checkout(path: Path) -> bool:
    """Whether path is a link into the checkout."""
    if not path.is_symlink():
        return False
    target = os.path.normpath(path.parent / os.readlink(path))
    return Path(target).is_relative_to(DOTFILES)


def same(src: Path, tgt: Path) -> bool:
    try:
        return src.read_bytes() == tgt.read_bytes()
    except OSError:
        return False


def show_diff(src: Path, tgt: Path) -> None:
    try:
        old, new = (p.read_text().splitlines(keepends=True) for p in (tgt, src))
    except (OSError, UnicodeDecodeError) as err:
        print("! cannot compare:", err)
        return
    if src.with_name(src.name + ".secret").exists():
        print("a git-secret file: the differences are not shown")
    else:
        print("".join(unified_diff(old, new, str(tgt), str(src))))


def may_replace(src: Path, tgt: Path) -> bool:
    show_diff(src, tgt)
    return gate.args.overwrite or gate.confirm(f"replace {tgt}?")


def set_aside(path: Path) -> bool:
    backup = path.with_name(path.name + ".dotfiles-bak")
    while os.path.lexists(backup):
        backup = backup.with_name(backup.name + "~")
    return gate.do(f"rename {path} to {backup.name}", path.rename, backup)


def make_link(src: Path, tgt: Path) -> None:
    tgt.parent.mkdir(parents=True, exist_ok=True)
    tgt.symlink_to(src)


def link(src: Path, tgt: Path) -> None:
    if tgt.parent.resolve().is_relative_to(DOTFILES):
        # through some link we didn't make; a link here would replace src itself
        gate.failed.append(f"link {tgt}: its folder is in the checkout")
        return
    if tgt.is_symlink() and os.readlink(tgt) == str(src):
        return
    if into_checkout(tgt) or (not tgt.is_symlink() and same(src, tgt)):
        clear = gate.do(f"remove {tgt}, to link it", tgt.unlink)
    elif os.path.lexists(tgt):
        clear = may_replace(src, tgt) and set_aside(tgt)
    else:
        clear = True
    if clear:
        gate.do(f"link {tgt} -> {src}", make_link, src, tgt)


def link_tree(source: Path, root: Path, skip: set[str]) -> None:
    files = [rel for rel in tracked(source) if rel.parts[0] not in skip]
    # older versions linked whole folders; those become real folders
    unfolded = set()
    for folder in sorted({root / p for rel in files for p in rel.parents[:-1]}):
        if into_checkout(folder) and unfolded.isdisjoint(folder.parents):
            gate.do(f"remove the folder link {folder}", folder.unlink)
            unfolded.add(folder)
    for rel in files:
        if gate.args.dry_run and not unfolded.isdisjoint((root / rel).parents):
            print(f"+ link {root / rel} -> {source / rel}")
        else:
            link(source / rel, root / rel)
    if source.is_dir():
        for name in list_files(source, "--others", "--directory", "--exclude-standard"):
            print(f"! not in git, so not linked: {source / name}")


def prune_links() -> None:
    """Remove dead links to files that are no longer in the checkout."""
    folders = {HOME} | {(HOME / rel).parent for rel in tracked(DOTFILES / "HOME")}
    folders |= {Path(folder) for folder, _, _ in os.walk(CFG)}
    for folder in sorted(filter(Path.is_dir, folders)):
        for path in sorted(folder.iterdir()):
            if into_checkout(path) and not path.exists():
                gate.do(f"remove the dead link {path}", path.unlink)


def link_all(groups: list[str]) -> None:
    prune_links()
    skip = {"homeassistant"} if "k8s" in groups else {"homeassistant", "k9s"}
    for source, root in TREES:
        link_tree(source, root, skip)
    for path in (DOTFILES / name for name in PRIVATE):
        if path.exists() and path.stat().st_mode & 0o077:
            gate.do(f"chmod 600 {path}", path.chmod, 0o600)
