# HBMAME for Homebrew

A [Homebrew](https://brew.sh) tap for **HBMAME** (HomeBrew MAME: hacks, homebrew and
prototypes), built from upstream [Robbbert/hbmame](https://github.com/Robbbert/hbmame).

Pre-built packages ("bottles") are provided for **Apple Silicon Macs on macOS 15 Sequoia
and later**, so installing takes seconds instead of a multi-hour compile. Other Macs can
still install it; Homebrew then builds it from source.

## Install

```sh
brew install estefan3112/hbmame/hbmame
```

Update together with everything else:

```sh
brew update && brew upgrade
```

## What gets installed

The layout mirrors Homebrew's own `mame` formula:

| What | Where (Apple Silicon) |
|---|---|
| Program | `/opt/homebrew/bin/hbmame` |
| Runtime folders: `artwork`, `bgfx`, `ctrlr`, `hash`, `ini`, `language`, `plugins`, `samples` | `/opt/homebrew/share/hbmame/` |

On Intel Macs replace `/opt/homebrew` with `/usr/local`. To find the prefix from a script,
use `$(brew --prefix)/bin/hbmame` and `$(brew --prefix)/share/hbmame`.

## First-time setup

Run this once after installing:

```sh
hbmame-setup
```

It creates `~/Library/Application Support/hbmame` with the usual sub-folders (`roms`, `cfg`,
`nvram`, `artwork`, `ini`, ...) and a starter `hbmame.ini` that already points at the Homebrew
support files in `/opt/homebrew/share/hbmame`. An existing `hbmame.ini` is never changed.

Then put your HBMAME ROMs into `~/Library/Application Support/hbmame/roms`, or change
`rompath` in `hbmame.ini` to where your set lives (several folders separated by `;`).

This is the same layout as Homebrew MAME, described in
[MAME via Homebrew on Macs](https://mameonmacs.blogspot.com/2025/12/mame-via-homebrew-on-macs-finally-there.html).
Use either this Homebrew version or the stand-alone HBMAME.app, not both: they share
`~/Library/Application Support/hbmame`.

## For frontend developers

The formula is designed so a frontend can treat it exactly like Homebrew MAME: the
executable is `bin/hbmame` and the support files are in `share/hbmame`, both under
`brew --prefix`. The installed version is reported by
`brew info --json=v2 estefan3112/hbmame/hbmame`.

## About this tap

HBMAME is by Robbbert and contributors, licensed GPL-2.0-or-later. This tap only packages
it for macOS. Signed and notarized stand-alone builds (no Homebrew needed) are available
from [estefan3112/hbmame-macos](https://github.com/estefan3112/hbmame-macos/releases).
