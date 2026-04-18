# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-04-06)

**Core value:** A single click or hotkey transports you into the world of Evangelion -- every pixel, sound, font, and animation shifts to match your chosen pilot's identity.
**Current focus:** Phase 2.1 fork-shell — plan 01 complete, caelestia-shell wired into flake

## Current Position

Phase: 2.1 of 10 (fork-shell — executing)
Plan: 02.1-01 COMPLETE; 02.1-02 COMPLETE (Hyprland keybinds rerouted through caelestia CLI); 02.1-03 next
Status: Plan 02.1-02 complete: five Phase-2 keybinds (SPACE, V, PrtSc, SHIFT+PrtSc, L) rewired in modules/home/hyprland.nix -- SPACE/V/PrtSc/SHIFT+PrtSc call caelestia; Super+L retained on loginctl lock-session. All other binds (workspaces, focus, terminal, media, brightness, togglefloating, exec-once) byte-identical. Surgical 7-line insertion / 5-line deletion. `nix flake check --no-build` deferred to NixOS target (Windows dev host). Phase 3 Plan 03-02 remains parked at checkpoint; will resume after Phase 2.1 lands.
Last activity: 2026-04-18 -- Plan 02.1-02 executed; commit 5e0bbaf (hyprland.nix keybind rewire)

Progress: [███████░░░] 64%

## Performance Metrics

**Velocity:**
- Total plans completed: 10
- Average duration: ~2min
- Total execution time: <1 hour

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-flake-foundation | 3/3 | ~5min | ~1.7min |
| 02-desktop-shell | 4/4 | ~9min | ~2.3min |
| 03-typography-nerv-command-profile | 1/2 | ~4min | ~4min |

**Recent Trend:**
- Last 5 plans: 02-02 (1min), 02-03 (2min), 02-04 (5min, 3 tasks, 6 files), 03-01 (4min, 2 tasks, 3 files)
- Trend: 03-01 included font generation and Stylix wiring

*Updated after each plan completion*

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01 P01 | 2min | 2 | 5 |
| Phase 01-flake-foundation P02 | 1min | 2 tasks | 4 files |
| Phase 01-flake-foundation P03 | 2min | 2 tasks | 4 files |
| Phase 02-desktop-shell P01 | 1min | 3 tasks | 4 files |
| Phase 02-desktop-shell P02 | 1min | 3 tasks | 6 files |
| Phase 02-desktop-shell P03 | 2min | 3 tasks | 3 files |
| Phase 02-desktop-shell P04 | 5min | 3 tasks | 6 files |
| Phase 03-typography P01 | 4min | 2 tasks | 3 files |
| Phase 02.1-fork-shell P01 | 2min | 2 tasks | 9 files (1 created, 2 modified, 6 deleted) |
| Phase 02.1 P02 | 1min | 1 tasks | 1 files |

## Accumulated Context

### Roadmap Evolution

- Phase 2.1 inserted after Phase 2: Fork shell (URGENT)

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
- [Phase 02-desktop-shell]: [Phase 02-04]: Super+V reassigned from togglefloating to cliphist; togglefloating moved to Super+Shift+V (KEY-07 requirement wins)
- [Phase 02-desktop-shell]: [Phase 02-04]: bindel (repeat-on-hold) for volume/brightness; bindl (works when locked) for media transport -- replaces deprecated bind flags
- [Phase 02-desktop-shell]: [Phase 02-04]: nm-applet + hyprpolkitagent started via Hyprland exec-once -- XDG autostart is not honored under Hyprland
- [Phase 03-typography]: [Phase 03-01]: Matisse EB wired via pkgs.callPackage let-binding inside stylix.nix (no specialArgs, no flake overlay)
- [Phase 03-typography]: [Phase 03-01]: Font generated with fonttools as valid OTF binary with PostScript name "MatissePro-EB" for fontconfig
- [Phase 03-typography]: [Phase 03-01]: hyprpaper Stylix target disabled (stylix.targets.hyprpaper.enable = false) to prevent conflict with wallpaper.nix
- [Phase 03-typography]: [Phase 03-01]: Serif kept as DejaVu (not a Phase 3 target); JetBrains Mono unchanged (blank-glyph contingency deferred to Plan 02)
- [Phase 02.1-fork-shell]: [Plan 02.1-01]: caelestia-shell input follows nixpkgs only (flake does not consume home-manager)
- [Phase 02.1-fork-shell]: [Plan 02.1-01]: home-manager.sharedModules wires caelestia.homeManagerModules.default -- do not import inside ./modules/home
- [Phase 02.1-fork-shell]: [Plan 02.1-01]: programs.caelestia.systemd.enable=true on graphical-session.target; NEVER also add caelestia to Hyprland exec-once (double-start hazard)
- [Phase 02.1-fork-shell]: [Plan 02.1-01]: Do NOT add pkgs.quickshell to environment.systemPackages (Research Pitfall 1: transitive version skew)
- [Phase 02.1-fork-shell]: [Plan 02.1-01]: Atomic delete+create commit -- never leave flake evaluable with both old and new shells defined
- [Phase 02.1-fork-shell]: [Plan 02.1-02]: Caelestia subcommand grammar provisional (shell drawers toggle launcher, clipboard, screenshot region, screenshot screen) -- Plan 03 reconciles against caelestia --help
- [Phase 02.1-fork-shell]: [Plan 02.1-02]: Super+L kept on loginctl lock-session -- session-lock is the vendor-neutral contract caelestia's lock listens on; Plan 03 can swap if --help shows different grammar

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 1]: Research flag -- Stylix current API (stylix.targets.*), Hyprland module exports, nerdfonts package split need live verification
- [Phase 6]: Research flag -- D-Bus vs Unix socket for GUI-daemon IPC, kitty remote control API, swww transition types
- [Phase 10]: Research flag -- Calamares + NixOS flake integration stability

## Session Continuity

Last session: 2026-04-18
Stopped at: Completed 02.1-02-PLAN.md (Hyprland keybinds rerouted through caelestia CLI). Parallel-parked: Plan 03-02 Tasks 1 & 2 complete with blocking human-verify checkpoint pending.
Resume file: .planning/phases/02.1-fork-shell/02.1-03-PLAN.md (validation + subcommand reconciliation)
Deferred verification: `nix flake lock` + `nix flake check --no-build` must run green on NixOS target before Plans 02.1-01 and 02.1-02 merge (Nix unavailable on Windows dev host). Plan 02.1-03 includes live `caelestia --help` verification which will confirm or correct the provisional subcommand grammar committed in 02.1-02.
