#!/usr/bin/env python3

# SPDX-FileCopyrightText: Simon A. F. Lund os@safl.dk
#
# SPDX-License-Identifier: BSD-3-Clause

"""Traverse Makefile and print all help instructions"""
import argparse
from pathlib import Path
import os
import re
import sys

TEXT_FMT_BOLD = "\033[1m"
TEXT_FMT_END = "\033[0m"
SEP = ";"

SKIP_TARGETS = ["help", "help-verbose"]

def expand_path(path):
    """Expands variables from the given path and turns it into absolute path"""

    return os.path.abspath(os.path.expanduser(os.path.expandvars(path)))


def setup():
    """Parse command-line arguments"""

    prsr = argparse.ArgumentParser(
        description="Traverse Makefile and print all help instructions",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    prsr.add_argument(
        "--repos", help="Path to root of the xNVMe repository", required=True
    )
    prsr.add_argument(
        "--verbose",
        action="store_true",
        help="If set, print verbose descriptions",
        required=False,
    )
    prsr.add_argument(
        "--colorize",
        action="store_true",
        default=False,
        help="If set, colorizes the text-output",
        required=False,
    )
    args = prsr.parse_args()
    args.repos = expand_path(args.repos)

    return args


def gen_help(args):
    """Generate dict from help instructions in Makefile"""

    define_regex = re.compile("define (?P<target>.+)-help")
    endef_regex = re.compile("endef")
    args.help = {}
    key = ""
    desc = []
    for line in (Path(args.repos) / "Makefile").read_text().splitlines():
        if define_regex.match(line):
            key = define_regex.match(line).group("target")
        elif endef_regex.match(line):
            args.help[key] = [
                ln[1:].strip("\n") for ln in desc if ln.startswith("#")
            ]
            key = ""
            desc = []
        elif key:
            desc.append(line)
    return args


def print_help(args):
    """Print the help instructions"""

    print(
        "\n".join(
            [
                "Usage:",
                " ",
                f"  make help          {SEP} Brief target description",
                f"  make help-verbose  {SEP} Verbose target descriptions",
                f"  make [target]      {SEP} Invoke the given 'target'",
                " ",
                "Targets:",
                " ",
            ]
        )
    )

    width = max(len(k) for k in args.help)

    for key, desc in sorted(args.help.items()):
        if key in SKIP_TARGETS:
            continue
        if key.startswith("_"):
            continue

        short = "".join(
            [key.ljust(width), f" {SEP}{desc[0]}"]
            if args.colorize
            else [
                TEXT_FMT_BOLD,
                key.ljust(width),
                TEXT_FMT_END,
                f" {SEP}{desc[0]}",
            ]
        )
        print(short)
        if args.verbose and len(desc) > 1:
            for line in desc[1:]:
                print(line)
            print("")


def main(args):
    """Entry point"""

    try:
        print_help(gen_help(args))
    except FileNotFoundError:
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(setup()))
