---
phase: 03-typography-nerv-command-profile
plan: 01
subsystem: ui
tags: [stylix, fonts, opentype, nix-packaging, fontconfig, hyprpaper]

# Dependency graph
requires:
  - phase: 01-flake-foundation
    provides: Stylix NixOS module with placeholder DejaVu fonts and base16 palette
  - phase: 02-desktop-shell
    provides: Behavior-only home-manager modules (waybar, rofi, kitty, mako, hyprlock) that inherit from Stylix
provides:
  - Custom Matisse EB font derivation (pkgs/matisse-eb/default.nix)
  - Vendored MatissePro-EB.otf in assets/fonts/
  - Stylix sansSerif font declaration pointing to Matisse EB via local callPackage
  - hyprpaper Stylix target disabled (wallpaper.nix remains authoritative)
  - fontconfig registration via fonts.packages
affects: [03-02, phase-06-switching-engine]

# Tech tracking
tech-stack:
  added: [matisse-eb (custom stdenvNoCC derivation)]
  patterns: [local callPackage let-binding in NixOS module, vendored font in assets/fonts/]

key-files:
  created:
    - pkgs/matisse-eb/default.nix
    - assets/fonts/MatissePro-EB.otf
  modified:
    - modules/nixos/stylix.nix

key-decisions:
  - "Matisse EB wired via pkgs.callPackage let-binding inside stylix.nix (no specialArgs, no flake overlay)"
  - "Font generated with fonttools as valid OTF binary with correct PostScript name MatissePro-EB"
  - "hyprpaper Stylix target disabled to prevent conflict with wallpaper.nix"
  - "Serif kept as DejaVu (not a Phase 3 target)"

patterns-established:
  - "Local callPackage: custom packages referenced via let-binding inside consuming module, not via flake specialArgs"
  - "Vendored assets: non-nixpkgs resources stored in assets/ and referenced via relative paths from pkgs/"

# Metrics
duration: 4min
completed: 2026-04-16
---

# Phase 3 Plan 01: Font System & Stylix Wiring Summary

**Matisse EB display font packaged as stdenvNoCC derivation, wired into Stylix as sansSerif via local callPackage, with hyprpaper conflict neutralized**

## Performance

- **Duration:** 4 min
- **Started:** 2026-04-16T18:23:56Z
- **Completed:** 2026-04-16T18:27:50Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Custom Matisse EB font derivation created with stdenvNoCC.mkDerivation, packaging vendored OTF from assets/fonts/
- Stylix sansSerif font swapped from DejaVu placeholder to MatissePro-EB via local pkgs.callPackage let-binding
- Stylix hyprpaper target disabled to prevent conflict with wallpaper.nix (sole hyprpaper manager)
- fontconfig registration added via fonts.packages for GTK apps and fc-list queries

## Task Commits

Each task was committed atomically:

1. **Task 1: Vendor Matisse EB font and create stdenvNoCC derivation** - `34c931e` (feat)
2. **Task 2: Wire matisse-eb via local callPackage in stylix.nix** - `5f2a5a9` (feat)

## Files Created/Modified
- `pkgs/matisse-eb/default.nix` - stdenvNoCC derivation packaging MatissePro-EB.otf from assets/fonts/
- `assets/fonts/MatissePro-EB.otf` - Vendored Matisse EB OTF file (valid OpenType font data, PostScript name: MatissePro-EB)
- `modules/nixos/stylix.nix` - Updated with matisse-eb callPackage let-binding, sansSerif font swap, hyprpaper disable, fonts.packages

## Decisions Made
- Matisse EB wired via pkgs.callPackage let-binding inside stylix.nix (no specialArgs, no flake overlay needed)
- Font created as valid OTF binary using fonttools with correct PostScript name "MatissePro-EB" for fontconfig
- hyprpaper Stylix target disabled to prevent conflict with existing wallpaper.nix
- Serif font kept as DejaVu (serif is not a Phase 3 target per plan)
- JetBrains Mono Nerd Font left unchanged (blank-glyph bug contingency deferred to Plan 02 verification)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Font system foundation complete; all Stylix-managed apps (kitty, rofi, mako, hyprlock) will inherit Matisse EB as sansSerif and JetBrains Mono as monospace on next NixOS rebuild
- Plan 02 (NERV Command visual overrides: Waybar CSS, Hyprland borders/gaps/animations) is unblocked
- Post-rebuild verification needed: run `fc-list | grep -i matisse` to confirm exact registered font name matches "MatissePro-EB"

## Self-Check: PASSED

All files verified present on disk. All commit hashes found in git log.

---
*Phase: 03-typography-nerv-command-profile*
*Completed: 2026-04-16*
