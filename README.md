# Mental Omega on NixOS

How to play [Mental Omega](https://mentalomega.com) 3.3.6, the fan expansion
for Command & Conquer: Red Alert 2 - Yuri's Revenge, on NixOS. It runs under
GE-Proton via
[umu-launcher](https://github.com/Open-Wine-Components/umu-launcher), so you
don't need Steam or a hand-made Wine prefix, and it's upscaled with
[cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw).

This repo contains only a Nix flake launcher (`flake.nix`, `flake.lock`) and
default game settings (`RA2MO.ini`). **It contains no game files.** Mental Omega
is not standalone: you need your own legally owned copy of Red Alert 2 and
Yuri's Revenge, plus the free mod downloads, all set up as described below.
Mental Omega is by Speeder & Mentalmeisters. Command & Conquer, Red Alert 2 and
Yuri's Revenge are trademarks of Electronic Arts. This guide is not affiliated
with either.

Tested on NixOS (nixos-unstable) with GE-Proton 11-3, cnc-ddraw 7.1.0, the i3
window manager and a 4K monitor.

## Get the repo

The game files go into the cloned directory itself. Git ignores everything
except the files above, so they never end up in commits or the Nix store.

```sh
git clone https://github.com/guilledk/mentalomega-nixos ~/Games/MentalOmega
```

Then [set up the game files](#set-up-the-game-files) before playing.

## Play

```sh
nix run ~/Games/MentalOmega                 # run once
nix profile install ~/Games/MentalOmega     # or install: `mentalomega` command + menu entry
```

Keep the directory a git checkout. Nix reads a local flake from git, so the
untracked game files stay out of the store; a plain directory would be copied
into the store in full.

The launcher finds the game files at runtime, not next to the flake. So you can
also run it without a clone, keeping the game wherever you like:

```sh
MO_DIR=/path/to/MentalOmega nix run github:guilledk/mentalomega-nixos
```

On first run umu downloads GE-Proton and the Steam Linux Runtime into
`~/.local/share/umu` (about 1 GB, once). The Wine prefix lives in
`~/.local/share/mentalomega/prefix`, outside this directory.

Environment overrides:

| Variable     | Default                                  | Use                                                      |
|--------------|------------------------------------------|----------------------------------------------------------|
| `MO_DIR`     | current dir if it holds the game, else `~/Games/MentalOmega` | game directory                       |
| `PROTONPATH` | `GE-Proton` (latest, downloaded by umu)  | a local Proton, e.g. `~/.local/share/Steam/compatibilitytools.d/GE-Proton11-3` |
| `WINEPREFIX` | `~/.local/share/mentalomega/prefix`      | Wine prefix                                              |

## Set up the game files

The directory must end up holding the Red Alert 2 / Yuri's Revenge files,
Mental Omega on top of them, and cnc-ddraw. Mental Omega never overwrites the
original game files.

### 1. Red Alert 2 / Yuri's Revenge 1.001 files

Copy these 7 files from a Red Alert 2 + Yuri's Revenge install (Steam, EA App,
The First Decade or CD):

```
BINKW32.DLL  Blowfish.dll  gamemd.exe
ra2.mix  ra2md.mix  language.mix  langmd.mix
```

**`gamemd.exe` must be the original Yuri's Revenge 1.001 executable.** Mental
Omega uses the Ares engine, which accepts only an unmodified 1.001 build:

- **The Steam release (app 2229850) does not work.** EA re-signed its
  `gamemd.exe` and changed its resources (5,286,208 bytes). Ares refuses it with
  *"Found an unknown game patch. Ares 3.0 is not compatible with other
  patches."*, and the game crashes when a skirmish or mission starts. The other
  six files from Steam are fine.
- **Patched builds don't work either**, such as the 2009 "x64 fix"
  (`gamemdx64.zip`), no-CD cracks or 4 GB patches.
- **The known-good file** is the official, unpatched 1.001 build, as installed
  from the original CDs plus the 1.001 patch or from The First Decade:
  - size `4813072` bytes
  - MD5 `6604fd6f4ab71a11c708ea423dc0a29e`
  - PE timestamp 30 Oct 2001

You can check a candidate with `md5sum gamemd.exe`. To confirm in-game, start a
skirmish and look in `syringe.log`, which should say:

```
SyringeDebugger::Handshake: Answers "Found Yuri's Revenge 1.001 (TFD). Applying Ares 3.0." (0)
```

### 2. Mental Omega

Download these from ModDB in a browser (ModDB's Cloudflare check blocks curl
and wget):

| File                                | Link                                                                                         |
|-------------------------------------|----------------------------------------------------------------------------------------------|
| `MentalOmega330Mod.zip` (required)  | <https://www.moddb.com/mods/mental-omega/downloads/mental-omega-330>                         |
| `MentalOmega336Patch.zip` (required)| <https://www.moddb.com/mods/mental-omega/downloads/mental-omega-336-patch-manual-update>     |
| `MentalOmega330Soundtrack.zip`      | <https://www.moddb.com/mods/mental-omega/downloads/soundtrack-for-mental-omega-33>           |
| `MentalOmega330SoundtrackPart2.zip` | <https://www.moddb.com/mods/mental-omega/downloads/soundtrack-for-mental-omega-33-part-ii>   |

The soundtracks are optional but recommended: the mod ships no music. Extract
the archives in this order, letting each one overwrite the previous:

```sh
cd ~/Games/MentalOmega
unzip -o ~/Downloads/MentalOmega330Mod.zip
unzip -o ~/Downloads/MentalOmega336Patch.zip
unzip -o ~/Downloads/MentalOmega330Soundtrack.zip
unzip -o ~/Downloads/MentalOmega330SoundtrackPart2.zip
```

The `version` file should now report `Version=3.3.6`. The client checks for
updates on start.

Extracting the mod archives overwrites `RA2MO.ini`. Run `git checkout RA2MO.ini`
afterwards to restore the tracked defaults.

### 3. cnc-ddraw (renderer)

Mental Omega bundles a 2020 cnc-ddraw. Replace it with a current release
(7.1.0 is tested) from
<https://github.com/FunkyFr3sh/cnc-ddraw/releases/latest> (`cnc-ddraw.zip`):

```sh
cd ~/Games/MentalOmega
unzip -o cnc-ddraw.zip -d /tmp/cnc-ddraw
cp /tmp/cnc-ddraw/ddraw.dll Resources/cnc-ddraw.dll
cp -r /tmp/cnc-ddraw/Shaders .
cp /tmp/cnc-ddraw/ddraw.dll ddraw.dll
cp /tmp/cnc-ddraw/ddraw.ini ddraw.ini
```

The client copies `Resources/cnc-ddraw.dll` to `ddraw.dll` whenever it saves
settings, so both copies have to be the new version.

Then edit `ddraw.ini`. Set these keys in the `[ddraw]` section:

```ini
fullscreen=true        ; upscale to the whole screen
windowed=true          ; borderless (no mode switch), works well on tiling WMs
border=false
maintas=true           ; keep aspect ratio
boxing=true            ; integer scaling when it fits (1080p -> 4K is exactly 2x)
renderer=opengl
vsync=true
shader=Shaders\nearest-neighbor.glsl
savesettings=0
```

Also set these two keys in the `[gamemd]` section, whose defaults override the
ones above:

```ini
maintas=true
boxing=true
```

Copy the finished file over `Resources/cnc-ddraw.ini` too, so the client
doesn't reset it. In the client's options, keep **Renderer = CnC-DDraw**: any
other renderer replaces `ddraw.dll`. The launcher sets
`WINEDLLOVERRIDES=ddraw=n,b` so Wine loads this `ddraw.dll` instead of its own.

## Resolution

The tracked `RA2MO.ini` holds stock Mental Omega settings, except that the
renderer is CnC-DDraw and the resolution is 1920x1080 for both the game
(`ScreenWidth`/`ScreenHeight`) and the client window
(`ClientResolutionX`/`ClientResolutionY`). cnc-ddraw upscales the game to the
whole screen.

The client writes your own settings (resolution, volumes, player handle) back to
this file. To keep those changes out of git:

```sh
git update-index --skip-worktree RA2MO.ini
```

## Copying to another machine

```sh
rsync -a ~/Games/MentalOmega/ otherhost:Games/MentalOmega/
```

The game directory holds no Wine prefix, so it copies cleanly. The other host
creates its own prefix and umu cache on first run.

## Known quirks

- The main-menu song fails to load under Wine-Mono (`HRESULT 0xC00D36BB` in
  `Client/client.log`). In-game music plays normally.
- Don't wrap the launcher in `gamemoderun`. Its preloaded library can't load
  inside umu's container and aborts the process.
