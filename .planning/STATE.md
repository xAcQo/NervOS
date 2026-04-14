# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-04-06)

**Core value:** A single click or hotkey transports you into the world of Evangelion -- every pixel, sound, font, and animation shifts to match your chosen pilot's identity.
**Current focus:** Phase 1 - Flake Foundation

## Current Position

Phase: 1 of 10 (Flake Foundation) -- COMPLETE
Plan: 3 of 3 in current phase (complete); Phase 1 done; next: Phase 2 (Profile Engine)
Status: Phase 1 complete; Phase 2 unblocked
Last activity: 2026-04-14 -- Plan 01-03 executed (Stylix + home-manager wiring)

Progress: [███░░░░░░░] 30%

## Performance Metrics

**Velocity:**
- Total plans completed: 3
- Average duration: ~1.7min
- Total execution time: <1 hour

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-flake-foundation | 3/3 | ~5min | ~1.7min |

**Recent Trend:**
- Last 5 plans: 01-01 (2min, 2 tasks, 5 files), 01-02 (1min, 2 tasks, 4 files), 01-03 (2min, 2 tasks, 4 files)
- Trend: fast and stable (n=3)

*Updated after each plan completion*

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01 P01 | 2min | 2 | 5 |
| Phase 01-flake-foundation P02 | 1min | 2 tasks | 4 files |
| Phase 01-flake-foundation P03 | 2min | 2 tasks | 4 files |

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

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 1]: Research flag -- Stylix current API (stylix.targets.*), Hyprland module exports, nerdfonts package split need live verification
- [Phase 6]: Research flag -- D-Bus vs Unix socket for GUI-daemon IPC, kitty remote control API, swww transition types
- [Phase 10]: Research flag -- Calamares + NixOS flake integration stability

## Session Continuity

Last session: 2026-04-14
Stopped at: Completed 01-03-PLAN.md; Phase 1 (Flake Foundation) complete; Phase 2 unblocked
Resume file: .planning/phases/02-profile-engine/ (to be created by /gsd:research-phase)
