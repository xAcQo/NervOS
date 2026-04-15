---
phase: 02-desktop-shell
plan: 01
subsystem: desktop-shell-foundation
tags: [waybar, rofi, kitty, home-manager, stylix-targets]
requires:
  - 01-flake-foundation (home-manager + stylix wired)
provides:
  - modules/home/waybar.nix
  - modules/home/rofi.nix
  - modules/home/kitty.nix
  - home-manager aggregator wired with desktop shell trio
affects:
  - modules/home/default.nix (imports list)
tech-stack:
  added:
    - waybar (via programs.waybar)
    - rofi-wayland (via programs.rofi with pkgs.rofi-wayland)
    - kitty (via programs.kitty)
  patterns:
    - behavior-only home-manager modules (theming delegated to Stylix)
    - systemd user service for Waybar (Hyprland graphical-session target)
key-files:
  created:
    - modules/home/waybar.nix
    - modules/home/rofi.nix
    - modules/home/kitty.nix
  modified:
    - modules/home/default.nix
decisions:
  - Waybar uses systemd.enable=true (no Hyprland exec-once needed)
  - Tray module included up-front so 02-04 additions (nm-applet, cliphist) appear without re-edit
  - Rofi package pinned to pkgs.rofi-wayland (plain rofi renders broken on Hyprland)
  - Zero style/color/font settings in any module -- Stylix owns all theming
metrics:
  duration_min: 1
  tasks: 3
  files: 4
  completed: 2026-04-15
---

# Phase 02 Plan 01: Desktop Shell Foundation Summary

Waybar status bar, Rofi app launcher, and Kitty terminal wired as behavior-only
home-manager modules -- Stylix owns all theming via its target integrations.

## What Was Built

Three new home-manager modules plus an updated aggregator wiring them into the
pilot user's session. All three are Stylix autotheme targets, so the modules
declare behavior (layout, keybinds, modules-left/right, package variant) and
deliberately omit fonts, colors, and style blocks.

### modules/home/waybar.nix

- Top bar (layer=top, position=top, height=30)
- Left: hyprland/workspaces, hyprland/window
- Center: clock (YYYY-MM-DD HH:MM + calendar tooltip)
- Right: pulseaudio, network, battery, tray
- `systemd.enable = true` -- service managed by Hyprland's graphical-session
  target (avoids a second exec-once in hyprland.nix)
- pulseaudio module name retained despite PipeWire (PipeWire speaks the PulseAudio protocol)
- Tray spacing=8 pre-provisioned for upcoming nm-applet / cliphist icons (02-04)

### modules/home/rofi.nix

- `package = pkgs.rofi-wayland` (mandatory -- plain rofi renders broken on Hyprland)
- `terminal = "${pkgs.kitty}/bin/kitty"` so Rofi launches shell entries in Kitty
- No theme / extraConfig -- Stylix owns visuals

### modules/home/kitty.nix

- `enable_audio_bell = false`
- `confirm_os_window_close = 0`
- No font / no colors -- Stylix injects via stylix.targets.kitty

### modules/home/default.nix (modified)

Added `./waybar.nix`, `./rofi.nix`, `./kitty.nix` to the imports list while
preserving the Stylix comment and the existing `./hyprland.nix` entry first.

## Decisions Made

1. **Behavior-only modules.** All three tools are first-party Stylix targets.
   Any style/color/font declaration would fight Stylix and produce either
   double-definition errors or silently override the palette. Inline comments
   in each file flag this to future editors.

2. **systemd-managed Waybar.** `programs.waybar.systemd.enable = true` defers
   lifecycle to Hyprland's graphical-session target. Keeps hyprland.nix free of
   an `exec-once = waybar` line and gives us correct restart semantics on
   reload.

3. **Tray module up-front.** Phase 02-04 adds nm-applet and cliphist; including
   the tray module now avoids a mandatory re-edit during that plan. Plan
   anticipated this explicitly.

4. **rofi-wayland over rofi.** Research confirmed nixpkgs still ships
   rofi-wayland as the blessed Wayland fork; plain `pkgs.rofi` has known
   rendering issues on Hyprland.

## Deviations from Plan

None -- plan executed exactly as written. Verification commands in each task
passed on the first try.

## Verification

- `test -f modules/home/{waybar,rofi,kitty}.nix` -- PASS (all three exist)
- `grep 'hyprland/workspaces' modules/home/waybar.nix` -- PASS
- `grep 'rofi-wayland' modules/home/rofi.nix` -- PASS
- `grep 'programs.kitty' modules/home/kitty.nix` -- PASS
- `! grep -E '^\s*style\s*=' modules/home/waybar.nix` -- PASS (no style block)
- `! grep -E 'font\s*=' modules/home/kitty.nix` -- PASS (no font override)
- `grep -rE 'style\s*=|color\s*=' modules/home/{waybar,rofi,kitty}.nix` -- no
  matches (confirms Stylix ownership)
- All three modules imported in modules/home/default.nix -- PASS

## Flake Check Note

`nix flake check --no-build` was not run: the development host is Windows and
the `nix` CLI is unavailable, matching the Phase 1 pattern. The modules use
only upstream home-manager option names (`programs.waybar`, `programs.rofi`,
`programs.kitty`) that have been stable for releases; evaluation will be
exercised on a NixOS host during VM bring-up at the end of Phase 2.

## Commits

- `8a6c8dd` feat(02-01): add waybar home-manager module
- `4da10c8` feat(02-01): add rofi and kitty home-manager modules
- `dd2d4c1` feat(02-01): wire waybar, rofi, kitty into home aggregator

## Next Steps

Plan 02-02 can now layer Hyprland keybinds that reference `$terminal = kitty`
and `bind = SUPER, SPACE, exec, rofi -show drun` with confidence that the
targets exist. Plan 02-04 will populate the tray with nm-applet + cliphist
without editing waybar.nix again.

## Self-Check: PASSED

- modules/home/waybar.nix: FOUND
- modules/home/rofi.nix: FOUND
- modules/home/kitty.nix: FOUND
- modules/home/default.nix: FOUND
- commit 8a6c8dd: FOUND
- commit 4da10c8: FOUND
- commit dd2d4c1: FOUND
