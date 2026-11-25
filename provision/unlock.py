"""SSH unlock of the encrypted disk: mothership and droneship."""

import base64
import hashlib
import os
import re
from collections.abc import Callable
from pathlib import Path

import gate
from links import same, show_diff
from options import args
from packages import install
from paths import CUSTOM, HOME
from tables import PACKAGES

CRYPT_CONF = Path("etc/dracut.conf.d/crypt-ssh.conf")
HOST_KEY = "/etc/dracut-crypt-ssh/ssh_host_ed25519_key"
UNLOCK_KEYS = Path("/etc/dracut-crypt-ssh/authorized_keys")  # no root logins
CMDLINE = Path("/etc/kernel/cmdline")
BOOT_ENTRIES = "/efi/loader/entries"


def write_as_root(path: Path, text: str) -> bool:
    """Write a file in /, keeping the old one as .dotfiles-bak."""
    backup = ("sudo", "cp", "-a", "--backup=numbered", path, f"{path}.dotfiles-bak")
    kept = gate.run(*backup) if path.exists() else True
    return kept and gate.run("sudo", "tee", path, text=text)


def make_host_key() -> bool:
    keygen = f"ssh-keygen -q -t ed25519 -N '' -f {HOST_KEY}"
    public = f"ssh-keygen -y -f {HOST_KEY} > {HOST_KEY}.pub"
    steps = f"mkdir -p {UNLOCK_KEYS.parent}; test -f {HOST_KEY} || {keygen}; "
    return gate.run("sudo", "sh", "-ec", f"{steps}test -f {HOST_KEY}.pub || {public}")


def key_lines(text: str) -> list[str]:
    lines = (line.strip() for line in text.splitlines())
    return [line for line in lines if line and not line.startswith("#")]


def has_unlock_keys() -> bool:
    """Whether a key may unlock. The size says enough once the conf is in place."""
    if not UNLOCK_KEYS.exists() or UNLOCK_KEYS.stat().st_size == 0:
        return False
    if args.dry_run or (
        "unlock" not in args.only
        and same(CUSTOM / "ROOT" / CRYPT_CONF, "/" / CRYPT_CONF)
    ):
        return True
    return bool(key_lines(gate.read_as_root("cat", str(UNLOCK_KEYS)) or ""))


PUBLIC_KEY = re.compile(r"(?:ssh|ecdsa|sk)-\S+ +(AAAA[\w+/=]+) *(.*)")


def add_unlock_keys() -> bool:
    """Let the owner pick from the keys that may log in as root or as the user."""
    texts = [gate.read_as_root("cat", "/root/.ssh/authorized_keys") or ""]
    own = HOME / ".ssh/authorized_keys"
    if own.exists():
        texts.append(own.read_text())
    keys = {}
    for line in key_lines("\n".join(texts)):
        if found := PUBLIC_KEY.search(line):
            digest = hashlib.sha256(base64.b64decode(found[1] + "==")).digest()
            fingerprint = "SHA256:" + base64.b64encode(digest).decode().rstrip("=")
            keys[fingerprint] = (found[2], line)
    if not keys:
        gate.warn("no public keys found to choose from; see manual.md")
        return False
    names = gate.choose("which may unlock?", {name: keys[name][0] for name in keys})
    if not names:
        return False
    text = "".join(f"{keys[name][1]}\n" for name in names)
    return write_as_root(UNLOCK_KEYS, text) and gate.run(
        "sudo", "chmod", "600", UNLOCK_KEYS
    )


OMITS = re.compile(r"^\s*omit_dracutmodules\+?=.*$", re.MULTILINE)
NETWORK = re.compile(r"(?<![\w-])(network|crypt-ssh)(?![\w-])")


def without_network(conf: str) -> str:
    """The text of a dracut conf, not omitting the modules that unlocking needs."""
    return OMITS.sub(lambda line: NETWORK.sub("", line[0]), conf)


def keep_network() -> bool:
    written = [
        write_as_root(path, without_network(path.read_text()))
        for path in dracut_confs()
        if without_network(path.read_text()) != path.read_text()
    ]
    return all(written)


def dracut_confs() -> list[Path]:
    confs = [Path("/etc/dracut.conf"), *Path("/etc/dracut.conf.d").glob("*.conf")]
    return [path for path in confs if path.exists()]


def with_network(cmdline: str) -> str:
    """The kernel arguments, with those that bring up the network added."""
    has = cmdline.split()
    missing = [] if "rd.neednet=1" in has else ["rd.neednet=1"]
    if not any(argument.startswith("ip=") for argument in has):
        missing.append("ip=dhcp")
    return " ".join([cmdline.rstrip("\n"), *missing]) + "\n" if missing else cmdline


def entries_ok() -> bool | None:
    """Whether the boot entries of this system have the network arguments."""
    machine = Path("/etc/machine-id").read_text().strip()
    found = gate.read_as_root(
        "grep", "-rh", f"--include={machine}-*.conf", "^options", BOOT_ENTRIES
    )
    return (
        all(with_network(line) == line for line in found.splitlines())
        if found
        else None
    )


def image_ok(version: str) -> bool | None:
    """Whether the initramfs of a kernel can be unlocked over SSH."""
    image = ("lsinitrd", "--kver", version)
    listing = gate.read_as_root(*image)
    if not listing:
        return None
    conf = gate.read_as_root(*image, "--file", "etc/crypt-ssh.conf") or ""
    keys = gate.read_as_root(*image, "--file", "root/.ssh/authorized_keys") or ""
    wanted = gate.read_as_root("cat", str(UNLOCK_KEYS)) or ""
    fingerprint = gate.query("ssh-keygen", "-l", "-f", f"{HOST_KEY}.pub").split()[1:2]
    return (
        "/dropbear" in listing
        and "etc/dropbear/dropbear_ed25519_host_key" in listing
        and "dropbear_port='222'" in conf
        and bool(fingerprint)
        and fingerprint[0] in conf
        and bool(key_lines(wanted))
        and key_lines(keys) == key_lines(wanted)
    )


def item(
    what: str, ok: bool | None, fix: Callable | None = None, how: str = ""
) -> bool:
    """Show the result of a check, and offer to fix what is wrong."""
    print({True: "ok:", False: "PROBLEM:", None: "unknown:"}[ok], what)
    if ok is False and fix and gate.confirm(f"{how}?"):
        ok = fix()
    if not ok and "unlock" in args.only and not args.dry_run:
        gate.failed.append(what)
    return ok is True


def check_unlock() -> None:
    """Set up what is missing. The conf only goes in with a key that may unlock:
    without one, the next kernel update would lock the owner out."""
    failed_before = len(gate.failed)
    source, conf = CUSTOM / "ROOT" / CRYPT_CONF, "/" / CRYPT_CONF
    packages = set(PACKAGES["luks"])
    ready = [
        item(
            "dracut-crypt-ssh and dropbear are installed",
            not gate.query("pacman", "-T", *sorted(packages)).split(),
            lambda: install(packages),
            "install them",
        ),
        item(
            "the host key exists",
            os.path.exists(HOST_KEY) and os.path.exists(f"{HOST_KEY}.pub"),
            make_host_key,
            "make it",
        ),
        item(
            f"{UNLOCK_KEYS} has a key",
            has_unlock_keys(),
            add_unlock_keys,
            "choose keys",
        ),
        item(
            "dracut doesn't omit the network or crypt-ssh",
            all(
                without_network(p.read_text()) == p.read_text() for p in dracut_confs()
            ),
            keep_network,
            "don't omit them",
        ),
        item(
            f"{CMDLINE} has rd.neednet=1 and ip=",
            with_network(CMDLINE.read_text()) == CMDLINE.read_text(),
            lambda: write_as_root(CMDLINE, with_network(CMDLINE.read_text())),
            "add rd.neednet=1 ip=dhcp",
        ),
    ]
    if not all(ready):
        print(f"{conf} and the initramfs are left alone until these are in place")
        return
    if not same(source, conf) and conf.exists():
        show_diff(source, conf)
    copy = ("sudo", "install", "-D", "-m", "644", source, conf)
    how = "install it (it takes effect at the next kernel update or rebuild)"
    ready = item(f"{conf} is ours", same(source, conf), lambda: gate.run(*copy), how)
    if not ready or "unlock" not in args.only:
        return
    if check_boot() and gate.confirm("rebuild the boot entries and every initramfs?"):
        del gate.failed[failed_before:]  # these are checked again
        if gate.run("sudo", "reinstall-kernels") and not args.dry_run:
            check_boot()


def check_boot() -> bool:
    """Whether there is a problem that a rebuild may fix."""
    results = {"the boot entries have rd.neednet=1 and ip=": entries_ok()}
    for path in sorted(Path("/usr/lib/modules").glob("*/pkgbase")):
        version = path.parent.name
        what = f"the initramfs of {version} has dropbear and our keys"
        results[what] = image_ok(version)
    for what, ok in results.items():
        item(what, ok)
    return False in results.values()
