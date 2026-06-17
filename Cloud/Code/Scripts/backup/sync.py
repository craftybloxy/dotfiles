#!/usr/bin/env python3
"""sync.py — faithful backup/restore between / and an ext4 USB key.

  ./sync.py backup    # /     -> USB   (mirror full paths onto the key)
  ./sync.py restore   # USB   -> /     (put everything back in place)

ext4 keeps Unix ownership/modes/ACLs/xattrs, and `rsync -aAX` preserves them.
Runs as root so the original owners survive in both directions.
"""
import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Cache dirs that bloat the backup with nothing worth keeping.
EXCLUDES = (
    "*/Cache/",
    "*/Code Cache/",
    "*/GPUCache/",
    "*/Service Worker/CacheStorage/",
    "*/Application Cache/",
)

def parse_args():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("mode", choices=("backup", "restore"))
    parser.add_argument("dest", nargs="?", type=Path,
                        default=Path("/media/crafty/backup"),
                        help="USB mount point (default: %(default)s)")
    parser.add_argument("--list", type=Path,
                        default=Path(__file__).resolve().parent / "paths.list",
                        help="path list, relative to / (default: paths.list)")
    parser.add_argument("-n", "--dry-run", action="store_true",
                        help="preview only: show what would change, write nothing")
    return parser.parse_args()

def main():
    args = parse_args()

    if shutil.which("rsync") is None:
        sys.exit("rsync not found; install it first")
    if not args.list.is_file():
        sys.exit(f"path list not found: {args.list}")
    if not args.dest.is_dir():
        sys.exit(f"USB not mounted at: {args.dest}")

    # Root is required to preserve ownership; re-run under sudo if needed.
    if os.geteuid() != 0:
        os.execvp("sudo", ["sudo", sys.executable, *sys.argv])

    src, dst = ("/", f"{args.dest}/") if args.mode == "backup" else (f"{args.dest}/", "/")

    cmd = ["rsync", "-aAXHr", "--info=progress2", "--relative",
           f"--files-from={args.list}"]
    cmd += [f"--exclude={pattern}" for pattern in EXCLUDES]
    if args.dry_run:
        cmd.append("--dry-run")
    cmd += [src, dst]

    # rsync exit codes: 0 = ok, 23/24 = partial (some source paths missing or
    # vanished mid-copy) — a warning for backups, not a fatal error.
    result = subprocess.run(cmd)
    if result.returncode == 0:
        print(f"{args.mode} done -> {dst}")
    elif result.returncode in (23, 24):
        print(f"{args.mode} finished with warnings (some paths missing) -> {dst}",
              file=sys.stderr)
    else:
        sys.exit(f"rsync failed (exit {result.returncode}); nothing reliable written")


if __name__ == "__main__":
    main()