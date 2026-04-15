# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-04-06)

**Core value:** A single click or hotkey transports you into the world of Evangelion -- every pixel, sound, font, and animation shifts to match your chosen pilot's identity.
**Current focus:** Phase 2 - Desktop Shell

## Current Position

Phase: 2 of 10 (Desktop Shell) -- IN PROGRESS
Plan: 3 of 4 in current phase (complete); next: 02-04
Status: Phase 2 Plan 03 complete; 02-04 unblocked
Last activity: 2026-04-15 -- Plan 02-03 executed (hyprpaper + screenshot toolchain)

Progress: [████░░░░░░] 40%

## Performance Metrics

**Velocity:**
- Total plans completed: 6
- Average duration: ~1.5min
- Total execution time: <1 hour

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-flake-foundation | 3/3 | ~5min | ~1.7min |
| 02-desktop-shell | 3/4 | ~4min | ~1.3min |

**Recent Trend:**
- Last 5 plans: 01-03 (2min), 02-01 (1min, 3 tasks, 4 files), 02-02 (1min, 3 tasks, 6 files), 02-03 (2min, 3 tasks, 3 files)
- Trend: fast and stable (n=6)

*Updated after each plan completion*

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01 P01 | 2min | 2 | 5 |
| Phase 01-flake-foundation P02 | 1min | 2 tasks | 4 files |
| Phase 01-flake-foundation P03 | 2min | 2 tasks | 4 files |
| Phase 02-desktop-shell P01 | 1min | 3 tasks | 4 files |
| Phase 02-desktop-shell P02 | 1min | 3 tasks | 6 files |
| Phase 02-desktop-shell P03 | 2min | 3 tasks | 3 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: 10 phases derived from 55 requirements; Phases 7 & 8 can execute in parallel
- [Roadmap]: MAGI dashboard is v1 scope (Phase 8), not polish
- [Roadmap]: Soundscapes are Phase 5 (before switching engine) -- first-class differentiator
- [Phase 01]: Use nixos-unstable + shared nixpkgs via follows; specialArgs (not _module.args) for flake composition
- [Phase 01]: stateVersion pinned at 25.05; hardware.graphics.enable (not deprecated hardware.opengl)
- [Phase 01-02]: Skip UWSM for Phase 1 (conflicts with home-manager systemd integration)
- [Phase 01-02]: Use monitor=",preferred,auto,auto" for GPU-agnostic VM + hardware boot
- [Phase 01-02]: NixOS-level compositor at modules/nixos/hyprland.nix; user-level at modules/home/hyprland.nix (clean separation)
- [Phase 01-flake-foundation]: [Phase 01-03]: Stylix auto-integrates into home-manager via NixOS module -- never manually import stylix.homeModules.stylix
- [Phase 01-flake-foundation]: [Phase 01-03]: home-manager wired with useGlobalPkgs + useUserPackages for shared nixpkgs
- [Phase 01-flake-foundation]: [Phase 01-03]: NERV Command base16 palette and DejaVu/wallpaper are Phase 1 placeholders -- Phase 3 swap points documented inline
- [Phase 02-desktop-shell]: [Phase 02-01]: Behavior-only home-manager modules for waybar/rofi/kitty -- Stylix owns all theming (no style/color/font in any)
- [Phase 02-desktop-shell]: [Phase 02-01]: Waybar uses systemd.enable=true -- managed by Hyprland graphical-session target, no exec-once needed
- [Phase 02-desktop-shell]: [Phase 02-01]: Rofi pinned to pkgs.rofi-wayland (plain rofi renders broken on Hyprland)
- [Phase 02-desktop-shell]: [Phase 02-02]: Thunar at NixOS level (gvfs/tumbler services); mako+hyprlock behavior-only (Stylix themes)
- [Phase 02-desktop-shell]: [Phase 02-02]: programs.hyprlock.enable on NixOS side is mandatory -- auto-configures PAM; never hand-write security.pam.services.hyprlock
- [Phase 02-desktop-shell]: [Phase 02-03]: hyprpaper over swww (swww archived late 2024); wallpaper path shared with Stylix via single relative Nix import
- [Phase 02-desktop-shell]: [Phase 02-03]: grimblast + deps installed as system packages (not home-manager) so systemd user services can access wl-copy/wl-paste
- [Phase 02-desktop-shell]: [Phase 02-03]: brightnessctl/playerctl added in 02-03 (not 02-04) to centralise CLI package management

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 1]: Research flag -- Stylix current API (stylix.targets.*), Hyprland module exports, nerdfonts package split need live verification
- [Phase 6]: Research flag -- D-Bus vs Unix socket for GUI-daemon IPC, kitty remote control API, swww transition types
- [Phase 10]: Research flag -- Calamares + NixOS flake integration stability

## Session Continuity

Last session: 2026-04-15
Stopped at: Completed 02-03-PLAN.md; Phase 2 Plan 04 next
Resume file: .planning/phases/02-desktop-shell/02-04-PLAN.md
