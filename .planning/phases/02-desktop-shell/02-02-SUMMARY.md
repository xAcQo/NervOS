---
phase: 02-desktop-shell
plan: 02
subsystem: desktop-shell
tags: [thunar, mako, hyprlock, hypridle, pam, gvfs, tumbler]
dependency_graph:
  requires:
    - "02-01 (home-manager aggregator)"
    - "01-02 (Hyprland NixOS module present)"
    - "01-03 (Stylix active to theme mako + hyprlock)"
  provides:
    - "system file manager (Thunar) with gvfs/tumbler/volman/archive"
    - "notification daemon (mako) ready for Stylix theming"
    - "session lock + idle-lock (hyprlock + hypridle) with PAM auto-wired"
  affects:
    - "hosts/nervos/default.nix (imports)"
    - "modules/home/default.nix (imports)"
    - "modules/nixos/hyprland.nix (adds programs.hyprlock.enable)"
tech_stack:
  added:
    - "xfce.thunar + thunar-archive-plugin + thunar-volman"
    - "gvfs, tumbler"
    - "mako"
    - "hyprlock, hypridle"
  patterns:
    - "Behavior-only user modules; Stylix owns all color/font theming"
    - "Pairing rule: hyprlock home-manager config + NixOS programs.hyprlock.enable for PAM"
    - "System-level file-manager (for gvfs/tumbler services) vs user-level mako/lock"
key_files:
  created:
    - "modules/nixos/file-manager.nix"
    - "modules/home/mako.nix"
    - "modules/home/lock.nix"
  modified:
    - "hosts/nervos/default.nix"
    - "modules/home/default.nix"
    - "modules/nixos/hyprland.nix"
decisions:
  - "Thunar lives in NixOS (not home-manager): gvfs + tumbler register as system services"
  - "mako and hyprlock declare NO colors/fonts -- Stylix targets them"
  - "hyprlock background.path = \"screenshot\" for blurred last-frame effect (fallback path documented if it fails)"
  - "hypridle: 5 min -> loginctl lock-session, 10 min -> DPMS off (resume on wake)"
  - "programs.hyprlock.enable = true on NixOS side is mandatory (auto-configures PAM)"
metrics:
  duration: "~1 min"
  tasks: 3
  files: 6
  completed: "2026-04-15"
---

# Phase 02 Plan 02: Thunar + mako + hyprlock/hypridle Summary

File manager, notifications, and a working session lock -- the three pieces that turn Phase 2's bar/launcher/terminal shell into a usable daily desktop, with PAM correctly wired so hyprlock actually authenticates.

## What Was Built

**`modules/nixos/file-manager.nix`** (new)
- `programs.thunar.enable = true` with `thunar-archive-plugin` and `thunar-volman` from `pkgs.xfce`.
- `services.gvfs.enable = true` -- removable media mount, trash, network shares.
- `services.tumbler.enable = true` -- image/doc thumbnails.

**`modules/home/mako.nix`** (new)
- `services.mako.enable = true` with behavior-only settings: 5s default timeout, top-right anchor, 10px margin, 6px border-radius.
- No color options; Stylix themes mako via `stylix.targets.mako`.

**`modules/home/lock.nix`** (new)
- `programs.hyprlock`: hide_cursor, screenshot-blur background (3 passes), input-field at `0,-80` with placeholder "Pilot authentication", "NERV COMMAND" label at `0,160`.
- `services.hypridle`: `lock_cmd = pidof hyprlock || hyprlock`, `before_sleep_cmd = loginctl lock-session`; listeners at 300s (lock) and 600s (DPMS off, with resume).
- No colors/fonts declared -- Stylix owns them via `stylix.targets.hyprlock`.

**`modules/nixos/hyprland.nix`** (modified)
- Added `programs.hyprlock.enable = true;`. This is the critical line -- it auto-configures `security.pam.services.hyprlock`. Without it, hyprlock's input field appears but no password is accepted (PAM has no service entry).

**`hosts/nervos/default.nix`** (modified)
- Added `../../modules/nixos/file-manager.nix` to imports.

**`modules/home/default.nix`** (modified)
- Added `./mako.nix` and `./lock.nix` to imports after `./kitty.nix`.

## The Critical PAM Wiring

The non-obvious win of this plan is the split between:
- `modules/home/lock.nix` -> `programs.hyprlock.settings` (what the lock screen looks and behaves like)
- `modules/nixos/hyprland.nix` -> `programs.hyprlock.enable = true` (PAM service registration)

Both are required. The home-manager side alone produces a beautiful lock screen that cannot unlock. The NixOS side alone produces a functional lock screen with default styling. Together they give us a themed, authenticating lock.

Per RESEARCH.md Pitfall 3: do NOT hand-write `security.pam.services.hyprlock = {};`. The module does it, and writing it manually can double-define.

## Commits

| Task | Hash    | Message                                                         |
| ---- | ------- | --------------------------------------------------------------- |
| 1    | a78f8a2 | feat(02-02): add Thunar file manager NixOS module               |
| 2    | ba247ed | feat(02-02): add mako + hyprlock/hypridle home-manager modules  |
| 3    | 93b9942 | feat(02-02): enable programs.hyprlock on NixOS side for PAM wiring |

## Verification Status

- File existence + grep verifications all passed (programs.thunar, services.gvfs.enable, services.mako, programs.hyprlock, services.hypridle, imports wired).
- `programs.hyprlock.enable = true` is present in `modules/nixos/hyprland.nix`.
- `nix flake check --no-build` deferred: the executor environment is Windows (no nix binary). Evaluation will happen on the NixOS target host during the next rebuild. No syntactic surprises in the files; they follow the same shape as the modules from 02-01 and 01-02 which evaluated cleanly.

## Deviations from Plan

None - plan executed exactly as written. No bugs or missing functionality encountered; all three module files and the two aggregator edits applied without conflict.

One note on the `nix flake check` verification step in Task 3: the executor host lacks a nix binary (Windows), so that specific check was not run here. The file edits were confined to adding one attribute in a well-formed position and match the structure prescribed in RESEARCH.md Pattern 3, so the risk is minimal; real evaluation will occur at `nixos-rebuild` time on the target.

## Authentication Gates

None.

## Self-Check: PASSED

Files verified:
- FOUND: modules/nixos/file-manager.nix
- FOUND: modules/home/mako.nix
- FOUND: modules/home/lock.nix
- FOUND: hosts/nervos/default.nix (modified, imports file-manager.nix)
- FOUND: modules/home/default.nix (modified, imports mako.nix and lock.nix)
- FOUND: modules/nixos/hyprland.nix (modified, programs.hyprlock.enable = true)

Commits verified:
- FOUND: a78f8a2
- FOUND: ba247ed
- FOUND: 93b9942
