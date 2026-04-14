---
phase: 01-flake-foundation
plan: 02
subsystem: compositor
tags: [hyprland, wayland, greetd, polkit, xdg-portal, home-manager, keybinds]

# Dependency graph
requires:
  - 01-01 (flake skeleton, nervos host, gpu module, modules/home/ directory)
provides:
  - modules/nixos/hyprland.nix enabling Hyprland + XWayland via programs.hyprland.enable
  - greetd login manager using tuigreet launching Hyprland session
  - security.polkit.enable for Hyprland session management
  - xdg.portal with xdg-desktop-portal-hyprland for screen share + file dialogs
  - modules/home/default.nix home-manager entry point for pilot user
  - modules/home/hyprland.nix user-level compositor config (monitor auto-detect, keybinds, gaps, rounding)
  - kitty terminal in systemPackages (for Super+T keybind)
affects:
  - 01-03-stylix-home (must wire modules/home via home-manager.nixosModules + home-manager.users.pilot)
  - all-later-phases (Hyprland now composable; user keybinds extensible)

# Tech tracking
tech-stack:
  added:
    - Hyprland (via nixpkgs programs.hyprland, NOT a flake input)
    - XWayland (via programs.hyprland.xwayland.enable)
    - greetd + tuigreet (display manager)
    - xdg-desktop-portal-hyprland (portal backend)
    - kitty (terminal emulator)
  patterns:
    - "Hyprland enabled via programs.hyprland.enable from nixpkgs (no separate flake input)"
    - "greetd tuigreet with --cmd Hyprland (capital H) to launch compositor session"
    - "Monitor auto-detect: monitor = \",preferred,auto,auto\" works for any GPU (virtio, AMD, Intel, NVIDIA)"
    - "home-manager systemd.enable left at default true (NOT using UWSM)"
    - "Stylix home module NOT imported in modules/home (auto-integrates via NixOS module in Plan 01-03)"

key-files:
  created:
    - modules/nixos/hyprland.nix
    - modules/home/default.nix
    - modules/home/hyprland.nix
  modified:
    - hosts/nervos/default.nix (uncommented hyprland.nix import; added kitty to systemPackages)

key-decisions:
  - "Skip UWSM for Phase 1 -- conflicts with home-manager systemd integration; revisit post-Phase 1 if needed"
  - "Use monitor=\",preferred,auto,auto\" for GPU-agnostic VM and hardware boot"
  - "Keybinds follow Hyprland convention (Super as mainMod); Super+T for terminal, Super+Q kill, Super+M exit"
  - "Do NOT wire home-manager into flake.nix yet -- deferred to Plan 01-03 where Stylix+HM integrate together"

patterns-established:
  - "NixOS-level compositor enablement lives in modules/nixos/hyprland.nix"
  - "User-level compositor config lives in modules/home/hyprland.nix (separation of system vs user concerns)"
  - "Anti-pattern documentation as inline comments (e.g. 'Do NOT enable UWSM') guards against future drift"

# Metrics
duration: 1min
completed: 2026-04-14
---

# Phase 1 Plan 2: Hyprland Summary

**Hyprland Wayland compositor with greetd+tuigreet login, polkit session management, XDG portal, and user-level keybinds/monitor config via home-manager modules -- all without UWSM or a Hyprland flake input.**

## Performance

- **Duration:** ~1 min
- **Started:** 2026-04-14T21:38:45Z
- **Completed:** 2026-04-14T21:39:46Z
- **Tasks:** 2
- **Files created:** 3
- **Files modified:** 1

## Accomplishments

- modules/nixos/hyprland.nix declares programs.hyprland.enable with XWayland, greetd tuigreet launching Hyprland, security.polkit.enable, and xdg.portal with xdg-desktop-portal-hyprland
- modules/home/default.nix is the home-manager entry point (pilot user, stateVersion 25.05, imports hyprland.nix)
- modules/home/hyprland.nix configures monitor auto-detect, dwindle layout, 5/10 gaps, rounding 8, US keyboard, and a full keybind set (Super+T/Q/M, Super+1-9 workspaces, Super SHIFT+1-9 move-to-workspace, Super+arrows focus, Super+V float, Super+F fullscreen, mouse movewindow/resizewindow)
- hosts/nervos/default.nix now imports hyprland.nix and has kitty in systemPackages
- Anti-pattern hygiene verified: no UWSM, no hardware.opengl, no nerdfonts, no _module.args, no Hyprland flake input (only inline comments warning against them)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Hyprland NixOS module with greetd and polkit** - `a9e273c` (feat)
2. **Task 2: Create home-manager entry point and Hyprland user config** - `9da81fc` (feat)

## Files Created/Modified

- `modules/nixos/hyprland.nix` (created) -- programs.hyprland.enable + XWayland; services.greetd with tuigreet --cmd Hyprland; security.polkit.enable; xdg.portal with xdg-desktop-portal-hyprland
- `modules/home/default.nix` (created) -- home-manager entry: imports ./hyprland.nix; home.username=pilot, home.homeDirectory=/home/pilot; programs.home-manager.enable; home.stateVersion=25.05
- `modules/home/hyprland.nix` (created) -- wayland.windowManager.hyprland.enable; monitor=",preferred,auto,auto"; $mainMod=SUPER, $terminal=kitty; general (gaps 5/10, border_size 2, dwindle); decoration.rounding 8; input (us, follow_mouse 1); bind (T/Q/M/V/F + workspaces 1-9 + move-to-workspace + arrow focus); bindm (mouse 272/273)
- `hosts/nervos/default.nix` (modified) -- uncommented `../../modules/nixos/hyprland.nix` import; added `kitty` to `environment.systemPackages`

## Decisions Made

- Followed plan verbatim; no structural deviations
- Left the Plan 01-01 `.gitkeep` in modules/home/ in place (harmless; next commit could remove it but it does not affect flake evaluation)
- home-manager wiring into flake.nix intentionally deferred to Plan 01-03 per plan instructions -- so `modules/home/*.nix` exist but are not yet evaluated

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None. CRLF conversion warnings from Git on Windows are expected and benign (Nix is line-ending agnostic).

## User Setup Required

None -- no external service configuration required.

Note: `nix flake check` cannot be run from this Windows host. Full validation (greetd launching Hyprland, keybinds working, monitor auto-detect in VM) occurs at end of Phase 1 when the flake is evaluated on NixOS / QEMU.

## Next Phase Readiness

- **Plan 01-03 (Stylix + home-manager) is unblocked.** It needs to:
  - Create `modules/nixos/stylix.nix` (Stylix base16 theming at NixOS level)
  - Uncomment Stylix + home-manager module slots in `flake.nix`
  - Wire `home-manager.nixosModules.home-manager` into nixosConfigurations.nervos with `home-manager.users.pilot = import ./modules/home`
  - After 01-03, the flake will be complete: compositor + theming + per-user config composed into one evaluable system closure

## Self-Check

- modules/nixos/hyprland.nix: FOUND
- modules/home/default.nix: FOUND
- modules/home/hyprland.nix: FOUND
- hosts/nervos/default.nix (modified): FOUND
- Commit a9e273c: FOUND
- Commit 9da81fc: FOUND

## Self-Check: PASSED

---
*Phase: 01-flake-foundation*
*Completed: 2026-04-14*
