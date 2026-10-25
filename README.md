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

The setup is the same as for Homebrew MAME, described in detail in
[MAME via Homebrew on Macs](https://mameonmacs.blogspot.com/2025/12/mame-via-homebrew-on-macs-finally-there.html).
Replace `mame` with `hbmame` and `/opt/homebrew/share/mame` with `/opt/homebrew/share/hbmame`:

1. Make an empty folder, `cd` into it and run `hbmame -createconfig` to create `hbmame.ini`.
2. In `hbmame.ini`, point the system paths at the Homebrew folders:
   ```
   hashpath      /opt/homebrew/share/hbmame/hash
   pluginspath   /opt/homebrew/share/hbmame/plugins
   languagepath  /opt/homebrew/share/hbmame/language
   bgfx_path     /opt/homebrew/share/hbmame/bgfx
   ```
   and set `rompath` (and the other user folders) to where you keep your HBMAME data.

## For frontend developers

The formula is designed so a frontend can treat it exactly like Homebrew MAME: the
executable is `bin/hbmame` and the support files are in `share/hbmame`, both under
`brew --prefix`. The installed version is reported by
`brew info --json=v2 estefan3112/hbmame/hbmame`.

## About this tap

HBMAME is by Robbbert and contributors, licensed GPL-2.0-or-later. This tap only packages
it for macOS. Signed and notarized stand-alone builds (no Homebrew needed) are available
from [estefan3112/hbmame-macos](https://github.com/estefan3112/hbmame-macos/releases).
