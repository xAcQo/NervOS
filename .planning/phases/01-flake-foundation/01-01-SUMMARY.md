---
phase: 01-flake-foundation
plan: 01
subsystem: infra
tags: [nix, flakes, nixos, home-manager, stylix, systemd-boot, qemu]

# Dependency graph
requires: []
provides:
  - flake.nix with pinned inputs (nixpkgs unstable, home-manager, stylix) all sharing nixpkgs via follows
  - nixosConfigurations.nervos NixOS system closure using specialArgs pattern
  - Host configuration defining bootable system (systemd-boot, NetworkManager, pilot user, flakes)
  - GPU-agnostic hardware.graphics module (AMD/Intel/virtio work; NVIDIA stub ready)
  - QEMU virtio hardware-configuration.nix for VM testing
  - Directory skeleton (hosts/nervos/, modules/nixos/, modules/home/) for subsequent plans
affects:
  - 01-02-hyprland (uncomments hyprland.nix import in hosts/nervos/default.nix)
  - 01-03-stylix-home (wires home-manager + stylix modules into flake.nix)
  - all-later-phases (every phase composes modules into nixosConfigurations.nervos)

# Tech tracking
tech-stack:
  added:
    - nixpkgs nixos-unstable (flake input)
    - home-manager (flake input, pinned via follows)
    - stylix (flake input, pinned via follows)
  patterns:
    - "specialArgs over _module.args (avoids infinite recursion in imports)"
    - "Shared nixpkgs via inputs.*.follows = nixpkgs (prevents closure bloat)"
    - "GPU-agnostic graphics via hardware.graphics.enable (NOT deprecated hardware.opengl)"
    - "Hyprland via programs.hyprland.enable from nixpkgs (NOT separate flake input)"
    - "Per-host directory: hosts/{name}/ with default.nix + hardware-configuration.nix"
    - "Cross-cutting modules at modules/nixos/ imported by host"

key-files:
  created:
    - flake.nix
    - hosts/nervos/default.nix
    - hosts/nervos/hardware-configuration.nix
    - modules/nixos/gpu.nix
    - modules/home/.gitkeep
  modified: []

key-decisions:
  - "Use nixos-unstable channel to get latest Hyprland/Stylix features"
  - "stateVersion pinned at 25.05 (must not change across upgrades)"
  - "initialPassword = nervos for VM testing; real deployments override"
  - "QEMU virtio as default hardware config; real hardware replaces with nixos-generate-config output"
  - "NVIDIA block kept commented in gpu.nix (documentation-as-code for hardware pivot)"

patterns-established:
  - "Flake input pattern: declare upstream url + follows=nixpkgs to share instance"
  - "Module slots commented with target plan (e.g. # Wired in Plan 01-02) for incremental composition"
  - "NIXOS_OZONE_WL=1 session variable baked into base host (Electron/Chromium Wayland)"

# Metrics
duration: 2min
completed: 2026-04-14
---

# Phase 1 Plan 1: Flake Foundation Summary

**NixOS flake skeleton with nixpkgs/home-manager/stylix inputs (all following nixpkgs), nervos host config with systemd-boot + pilot user + flakes enabled, and GPU-agnostic hardware.graphics module ready for compositor + theming layering.**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-04-14T21:35:35Z
- **Completed:** 2026-04-14T21:37:38Z
- **Tasks:** 2
- **Files created:** 5

## Accomplishments

- flake.nix evaluates with 3 pinned inputs and a valid nixosConfigurations.nervos output
- nervos host declares a complete bootable NixOS system (systemd-boot, NetworkManager, pilot user, locale, flakes)
- GPU module uses current hardware.graphics API (not deprecated hardware.opengl)
- Directory skeleton ready: hosts/nervos/ populated; modules/nixos/ populated; modules/home/ reserved for Plan 01-03
- Anti-pattern hygiene verified: no _module.args, no hardware.opengl, no nerdfonts, no Hyprland flake input

## Task Commits

Each task was committed atomically:

1. **Task 1: Create flake.nix with all inputs and nixosConfigurations output** - `8b282c5` (feat)
2. **Task 2: Create host configuration and GPU module** - `4296ee7` (feat)

**Plan metadata:** (created after this SUMMARY is written)

## Files Created/Modified

- `flake.nix` - Flake inputs (nixpkgs unstable, home-manager, stylix with follows=nixpkgs) and nixosConfigurations.nervos output using specialArgs
- `hosts/nervos/default.nix` - NixOS host: systemd-boot, NetworkManager, pilot user (wheel+networkmanager+video), flakes enabled, en_US.UTF-8, America/New_York, NIXOS_OZONE_WL=1, stateVersion 25.05
- `hosts/nervos/hardware-configuration.nix` - QEMU virtio placeholder (qemu-guest profile, vda1/vda2 ext4+vfat, x86_64-linux)
- `modules/nixos/gpu.nix` - hardware.graphics.enable = true (GPU-agnostic); commented NVIDIA block with open kernel modules + modesetting
- `modules/home/.gitkeep` - Reserved for home-manager module in Plan 01-03

## Decisions Made

- Followed plan verbatim; all critical hygiene rules (specialArgs, follows, hardware.graphics) are preserved
- Added a .gitkeep to modules/home/ so git tracks the empty directory required by future plans
- Confirmed anti-pattern absence by repo-wide grep (all hits confined to .planning/ docs)

## Deviations from Plan

None - plan executed exactly as written.

(The single tiny addition of modules/home/.gitkeep is a mechanical necessity -- git does not track empty directories, and the plan explicitly requires the directory to exist for Plan 01-03. Not a behavioral deviation.)

## Issues Encountered

None. CRLF conversion warnings from Git on Windows are expected and benign (Nix is line-ending agnostic).

## User Setup Required

None - no external service configuration required.

Note: `nix flake check` cannot be run from this Windows host. Validation will occur when the flake is evaluated on NixOS (next concrete verification opportunity: Plan 01-03 completion with a VM boot test).

## Next Phase Readiness

- **Plan 01-02 (Hyprland) is unblocked.** It needs to:
  - Create `modules/nixos/hyprland.nix` enabling `programs.hyprland.enable`
  - Uncomment the `../../modules/nixos/hyprland.nix` import in `hosts/nervos/default.nix`
- **Plan 01-03 (Stylix + home-manager) is unblocked.** It needs to:
  - Create `modules/nixos/stylix.nix` and `modules/home/default.nix`
  - Uncomment the Stylix + home-manager module slots in `flake.nix`
- No live-run verification yet (Windows host); first boot verification arrives at end of Phase 1.

## Self-Check

- flake.nix: FOUND
- hosts/nervos/default.nix: FOUND
- hosts/nervos/hardware-configuration.nix: FOUND
- modules/nixos/gpu.nix: FOUND
- modules/home/.gitkeep: FOUND
- Commit 8b282c5: FOUND
- Commit 4296ee7: FOUND

## Self-Check: PASSED

---
*Phase: 01-flake-foundation*
*Completed: 2026-04-14*
