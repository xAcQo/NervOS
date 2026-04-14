---
phase: 01-flake-foundation
plan: 03
subsystem: theming
tags: [stylix, home-manager, base16, fonts, nerd-fonts, wallpaper, nixos-module]

# Dependency graph
requires:
  - 01-01 (flake skeleton with stylix + home-manager inputs)
  - 01-02 (modules/home/default.nix entry point + hyprland user config)
provides:
  - flake.nix composition of stylix.nixosModules.stylix + home-manager.nixosModules.home-manager into nixosConfigurations.nervos
  - home-manager.useGlobalPkgs + useUserPackages wiring for shared nixpkgs
  - home-manager.users.pilot importing modules/home
  - modules/nixos/stylix.nix with NERV Command base16 palette, JetBrains Mono Nerd Font, DejaVu placeholders, Bibata cursor, dark polarity, opacity tuning
  - assets/wallpaper.jpg placeholder (required by Stylix; Phase 3 replaces)
  - hosts/nervos/default.nix importing stylix.nix
affects:
  - 02-profile-engine (Stylix palette + font API is now the single switching surface)
  - 03-typography-nerv-command (will replace DejaVu with Matisse EB and swap placeholder wallpaper)
  - all-later-phases (system is a complete themed desktop closure; further phases layer on top)

# Tech tracking
tech-stack:
  added:
    - Stylix (NixOS module, auto-integrates into home-manager)
    - nerd-fonts.jetbrains-mono (post-split nerdfonts API)
    - dejavu_fonts (Phase 1 display font placeholder)
    - noto-fonts-color-emoji (emoji fallback)
    - bibata-cursors (cursor theme)
  patterns:
    - "Stylix auto-integrates into home-manager when both use NixOS modules -- do NOT manually import stylix.homeModules.stylix"
    - "home-manager wired as NixOS module via home-manager.nixosModules.home-manager + inline config block"
    - "useGlobalPkgs + useUserPackages: HM shares system nixpkgs; installs to /etc/profiles/per-user"
    - "Stylix image path resolves via relative path from module file (../../assets/wallpaper.jpg)"
    - "Font declaration at Stylix level propagates to GTK + terminal + all apps (no per-app overrides)"
    - "Base16 palette single-source-of-truth for colors across system"

key-files:
  created:
    - modules/nixos/stylix.nix
    - assets/wallpaper.jpg
  modified:
    - flake.nix (added stylix + home-manager modules list entries and HM inline config)
    - hosts/nervos/default.nix (imported stylix.nix)

key-decisions:
  - "Phase 1 palette is a NERV-colored placeholder (true black bg, NERV orange base09, wire cyan base0C) -- Phase 3 tunes final values"
  - "DejaVu Sans/Serif as Phase 1 display font placeholders; Matisse EB deferred to Phase 3 typography work"
  - "Wallpaper is a tiny valid placeholder JPEG; Phase 3 supplies real EVA asset"
  - "Do NOT import stylix.homeModules.stylix anywhere -- the NixOS module auto-propagates to HM (community-standard pattern per 01-RESEARCH)"
  - "home-manager inline config lives in flake.nix modules list (not a separate module) to keep HM wiring visible at the flake root"

patterns-established:
  - "Phase 3 swap points documented in inline comments at modules/nixos/stylix.nix for every placeholder (wallpaper, sansSerif, serif)"
  - "Anti-pattern guard comments preserved in modules/home/default.nix warn against manual Stylix HM import"
  - "specialArgs pattern (from 01-01) coexists cleanly with home-manager.nixosModules.home-manager"

# Metrics
duration: ~2min
completed: 2026-04-14
---

# Phase 1 Plan 3: Stylix + home-manager Summary

**Stylix NixOS module with NERV Command base16 palette (true-black bg, NERV orange, wire cyan) plus JetBrains Mono Nerd Font, Bibata cursor, and placeholder wallpaper, auto-integrated into home-manager via the community-standard NixOS-module-only pattern -- Phase 1 is now a complete themed Hyprland desktop closure.**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-04-14T21:41:48Z
- **Completed:** 2026-04-14T21:43:19Z
- **Tasks:** 2
- **Files created:** 2 (modules/nixos/stylix.nix, assets/wallpaper.jpg)
- **Files modified:** 2 (flake.nix, hosts/nervos/default.nix)

## Accomplishments

- `flake.nix` modules list now composes `./hosts/nervos`, `stylix.nixosModules.stylix`, `home-manager.nixosModules.home-manager`, and an inline HM config block (`useGlobalPkgs=true`, `useUserPackages=true`, `users.pilot = import ./modules/home`).
- `modules/nixos/stylix.nix` declares the full Phase 1 theming surface: `stylix.enable=true`, base16 palette (all 16 slots populated with NERV Command placeholder values), monospace/sansSerif/serif/emoji fonts, font sizes, cursor, polarity=dark, opacity.
- Monospace font uses `pkgs.nerd-fonts.jetbrains-mono` (post-split API). The deprecated monolithic `pkgs.nerdfonts` is absent from the entire source tree.
- `assets/wallpaper.jpg` is a valid 332-byte JPEG -- satisfies Stylix's evaluation requirement. Phase 3 replaces with real EVA asset.
- `hosts/nervos/default.nix` imports list now has four entries: `hardware-configuration.nix`, `gpu.nix`, `hyprland.nix`, `stylix.nix`.
- Anti-pattern audit of source files (excluding .planning docs) is clean: no `pkgs.nerdfonts`, no `hardware.opengl`, no `_module.args`, no `withUWSM`, no Hyprland flake input, no manual `stylix.homeModules.stylix` import.

## Task Commits

Each task was committed atomically:

1. **Task 1: Wire home-manager + Stylix NixOS modules into flake.nix** - `e5a8323` (feat)
2. **Task 2: Create Stylix NixOS module + placeholder wallpaper + host import** - `90c2e7f` (feat)

## Files Created/Modified

- `flake.nix` (modified) -- outputs block now includes `stylix.nixosModules.stylix`, `home-manager.nixosModules.home-manager`, and inline HM block with `useGlobalPkgs`, `useUserPackages`, `users.pilot = import ./modules/home`
- `modules/nixos/stylix.nix` (created) -- Stylix NixOS config: base16 palette, fonts (JetBrains Mono mono / DejaVu Sans+Serif / Noto Color Emoji), font sizes, Bibata cursor, polarity dark, opacity settings; `image = ../../assets/wallpaper.jpg`
- `assets/wallpaper.jpg` (created) -- 332-byte valid JPEG placeholder
- `hosts/nervos/default.nix` (modified) -- imports list appended with `../../modules/nixos/stylix.nix`

## Base16 Palette (NERV Command Placeholder)

| Slot  | Hex     | Role                         |
| ----- | ------- | ---------------------------- |
| base00 | 000000 | Background: true black      |
| base01 | 1a1a1a | Lighter background           |
| base02 | 333333 | Selection background         |
| base03 | 666666 | Comments, muted              |
| base04 | 999999 | Dark foreground              |
| base05 | cccccc | Default foreground           |
| base06 | e6e6e6 | Light foreground             |
| base07 | ffffff | Lightest foreground          |
| base08 | ff3030 | Red (alert red)              |
| base09 | ff9830 | **NERV orange** (accent)     |
| base0A | ffcc00 | Yellow                       |
| base0B | 40bf40 | Green                        |
| base0C | 20f0ff | Wire cyan (highlight)        |
| base0D | 4080ff | Blue                         |
| base0E | 9050ff | Purple                       |
| base0F | ff6030 | Dark orange                  |

Phase 3 (Typography & NERV Command Profile) will tune these against real EVA asset references and pilot-specific palettes for the profile engine.

## Font Stack

- **Monospace:** JetBrainsMono Nerd Font Mono (`pkgs.nerd-fonts.jetbrains-mono`)
- **Sans:** DejaVu Sans (Phase 3 -> Matisse EB or closest open alternative)
- **Serif:** DejaVu Serif (Phase 3 reconsideration)
- **Emoji:** Noto Color Emoji
- **Sizes:** applications 12, desktop 10, terminal 12, popups 10

Phase 3 swap points are documented as inline comments in `modules/nixos/stylix.nix`.

## Stylix Auto-Integration Confirmation

- `flake.nix` imports `stylix.nixosModules.stylix` (NixOS module) only.
- `modules/home/default.nix` imports `./hyprland.nix` only -- no `stylix.homeModules.stylix` import. A guard comment explicitly warns against manual import.
- Grep for `stylix.homeModules.stylix` across repo source returns zero hits (all matches are in `.planning/` documentation as anti-pattern warnings).
- This is the community-standard pattern surfaced in `01-RESEARCH.md`: with `useGlobalPkgs=true` + both Stylix and home-manager as NixOS modules, Stylix auto-propagates palette and font options into the HM configuration. Manual import causes double-definition errors on every Stylix option.

## Deviations from Plan

None -- plan executed exactly as written.

Implementation note: the plan's bash one-liner for wallpaper creation used `printf` with a raw binary literal containing `&` characters, which the Windows Git-Bash shell interpreted as command separators. Fell back to a Python one-liner (`open(..., 'wb').write(bytes.fromhex(...))`) to write the same valid minimal JPEG. Final artifact is a 332-byte `assets/wallpaper.jpg` that Stylix will accept. This is a mechanical substitution, not a behavioral deviation.

## Issues Encountered

- Windows Git-Bash rejected the `printf` binary literal from the plan (ampersands broke parsing). Worked around with Python. No impact on the final artifact.
- Standard CRLF warnings from Git on Windows are expected and benign (Nix is line-ending agnostic).

## User Setup Required

None -- no external service configuration required.

Note: `nix flake lock`, `nix build .#nixosConfigurations.nervos.config.system.build.toplevel`, and QEMU VM boot verification cannot be run from this Windows host. The full Phase 1 system closure will be validated on first NixOS/QEMU evaluation -- the natural end-of-phase verification opportunity.

## Phase 1 Closure

With this plan complete, Phase 1 (Flake Foundation) delivers:

- FOUND-01: flake with pinned inputs (nixpkgs unstable + home-manager + stylix, all follows=nixpkgs)
- FOUND-02: bootable NixOS host (systemd-boot, pilot user, flakes enabled, hardware.graphics)
- FOUND-03: Stylix base16 palette driving colors across GTK + terminal from a single definition
- FOUND-04: home-manager integrated as NixOS module with `useGlobalPkgs` + `useUserPackages` + `users.pilot`
- FOUND-05: shared nixpkgs across all inputs via `follows = "nixpkgs"`

Phase 2 (Profile Engine) is now unblocked -- it will consume the Stylix palette/font API as the switching surface for per-pilot identity.

## Next Phase Readiness

- **Phase 2 (Profile Engine) is unblocked.** It can now:
  - Factor the placeholder base16Scheme + fonts in `modules/nixos/stylix.nix` into per-pilot profile definitions
  - Introduce the profile-selection mechanism (likely a NixOS option + Home Manager module that chooses a profile at build time)
  - Layer the switching hotkey/GUI trigger on top of the theming surface established here
- No live-run verification yet (Windows host). First boot verification arrives when a NixOS/QEMU environment is available.

## Self-Check

- flake.nix (modified): FOUND
- modules/nixos/stylix.nix: FOUND
- assets/wallpaper.jpg: FOUND (332 bytes)
- hosts/nervos/default.nix (modified, imports stylix.nix): FOUND
- Commit e5a8323: FOUND
- Commit 90c2e7f: FOUND
- Anti-pattern audit (source tree, excluding .planning/ docs): zero hits for pkgs.nerdfonts / hardware.opengl / _module.args / withUWSM / stylix.homeModules.stylix

## Self-Check: PASSED

---
*Phase: 01-flake-foundation*
*Completed: 2026-04-14*
