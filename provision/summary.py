"""What a run did."""

import gate
from options import args

KINDS = {  # how a change starts: what the summary calls it
    "link ": "linked",
    "delete ": "deleted",
    "yay -S ": "installed",
    "yay -Rns ": "uninstalled",
    "remove ": "removed",
}


def print_summary() -> None:
    kinds: dict[str, list[str]] = {}
    for what in gate.done:
        kind = next((k for start, k in KINDS.items() if what.startswith(start)), "ran")
        kinds.setdefault(kind, []).append(what)
    kinds |= {
        "you said no to": gate.skipped,
        "warnings": gate.warned,
        "FAILED": gate.failed,
    }
    print("\nSummary" + (" (dry run: nothing was changed)" if args.dry_run else ""))
    for kind, lines in kinds.items():
        if lines:
            print(f"{kind}: {len(lines)}")
        if kind not in ("linked", "removed"):  # these are many, and shown above
            print("".join(f"  {line}\n" for line in lines), end="")
    if not any(kinds.values()):
        print("nothing to do")
