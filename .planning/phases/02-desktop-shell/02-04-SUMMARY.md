---
phase: 02-desktop-shell
plan: 04
subsystem: desktop-shell
tags: [audio, network, clipboard, hyprland, keybinds]
requires:
  - "02-03 (screenshot toolchain packages: grimblast, wl-clipboard, brightnessctl, playerctl)"
  - "02-01 (rofi-wayland, waybar)"
  - "02-02 (hyprlock)"
provides:
  - "PipeWire audio stack (replaces legacy PulseAudio)"
  - "NetworkManager applet available to waybar tray"
  - "cliphist clipboard history bound to hyprland-session.target"
  - "Full Phase 2 keybind surface: launcher, lock, clipboard, screenshots, volume, brightness, media"
  - "Session-start autostarts for nm-applet and hyprpolkitagent"
affects:
  - "modules/home/hyprland.nix (Super+V bind semantics: now clipboard, not togglefloating)"
tech-stack:
  added:
    - "services.pipewire (with alsa, pulse shim, wireplumber)"
    - "services.pulseaudio.enable = false (explicit)"
    - "security.rtkit (PipeWire realtime)"
    - "programs.nm-applet"
    - "services.cliphist (home-manager)"
    - "Hyprland bindel + bindl variants; exec-once"
  patterns:
    - "NixOS module for system services; home-manager module for user services"
    - "Explicit hyprland-session.target for user services (avoid graphical-session regressions)"
    - "exec-once for GUI daemons that rely on XDG autostart (Hyprland does not run XDG autostart)"
    - "Volume capped at 1.0 via wpctl -l 1.0 (prevents accidental distortion)"
key-files:
  created:
    - "modules/nixos/audio.nix"
    - "modules/nixos/network.nix"
    - "modules/home/clipboard.nix"
  modified:
    - "modules/home/hyprland.nix"
    - "modules/home/default.nix"
    - "hosts/nervos/default.nix"
decisions:
  - "Super+V reassigned from togglefloating to clipboard history; togglefloating moved to Super+Shift+V (explicit KEY-07 requirement wins)"
  - "Use bindel for volume/brightness (repeat on hold) and bindl for media transport (work while locked) -- replaces deprecated bind flags"
  - "Autostart nm-applet and hyprpolkitagent via exec-once; programs.nm-applet.enable alone is insufficient under Hyprland"
  - "wl-clipboard stays at system level (added in 02-03) -- not duplicated in cliphist module, so systemd user services can access it"
metrics:
  duration: "~5min"
  completed: "2026-04-15"
  tasks: 3
  files: 6
---

# Phase 02 Plan 04: Desktop Shell Wiring Summary

PipeWire + NetworkManager applet + cliphist enabled at the system/user layer; Hyprland extended with the launcher/lock/clipboard/screenshot/volume/brightness/media keybinds that connect every Phase 2 tool into a working session.

## What Was Built

Three module files and one extension:

1. **`modules/nixos/audio.nix`** -- PipeWire with ALSA, 32-bit support, PulseAudio protocol shim, wireplumber; legacy `services.pulseaudio.enable = false` to avoid the known 24.11 rename conflict; `security.rtkit.enable = true` for realtime priority. Commit `7e7b2bd`.

2. **`modules/nixos/network.nix`** -- `networking.networkmanager.enable` (idempotent with host) and `programs.nm-applet.enable` which installs the tray applet and its XDG autostart unit. Commit `7e7b2bd`.

3. **`modules/home/clipboard.nix`** -- `services.cliphist` with `allowImages = true` and `systemdTargets = [ "hyprland-session.target" ]`. System-level `wl-clipboard` (Plan 02-03) satisfies the runtime dependency. Commit `6a3d1a0`.

4. **`modules/home/hyprland.nix`** -- added `exec-once` (nm-applet + hyprpolkitagent), five new `bind` entries (Super+SPACE, Super+L, Super+V, Print, Shift+Print), a `bindel` block for volume (wpctl) + brightness (brightnessctl), and a `bindl` block for media keys (playerctl). Commit `1ee254c`.

## Super+V Conflict Resolution

Phase 1's `$mainMod, V, togglefloating` collided with the Phase 2 KEY-07 explicit requirement that Super+V opens the clipboard picker. Resolution: togglefloating moved to `$mainMod SHIFT, V`. Clipboard history wins the lower-friction chord; floating toggle remains reachable at one extra modifier.

## Commits

- `7e7b2bd` feat(02-04): add audio and network NixOS modules
- `6a3d1a0` feat(02-04): add cliphist home-manager module
- `1ee254c` feat(02-04): wire desktop shell keybinds and autostarts in hyprland

## Deviations from Plan

**1. [Rule 3 - Blocking] `nix flake check --no-build` not run**
- **Found during:** Task 3 verification step
- **Issue:** The executing host is Windows (no `nix` binary available); the NixOS target is evaluated on the Linux rebuild machine, not here.
- **Fix:** Relied on the static grep-based verification steps (all passed). The next rebuild cycle on the Linux host will surface any evaluation issues.
- **Files modified:** none
- **Commit:** n/a (documentation only)

No other deviations -- Rules 1, 2, and 4 did not trigger.

## Phase 2 Coverage After This Plan

All Phase 2 behavioral requirements are now expressed in config:

| ID | Requirement | Source |
|----|------------|--------|
| DESK-01 | waybar | 02-01 |
| DESK-02 | rofi | 02-01 + Super+SPACE bind (here) |
| DESK-03 | kitty | 02-01 + Super+T (Phase 1) |
| DESK-04 | Thunar | 02-02 |
| DESK-05 | mako | 02-02 |
| DESK-06 | hyprlock | 02-02 + Super+L bind (here) |
| DESK-07 | hyprpaper | 02-03 |
| DESK-08 | grimblast | 02-03 + Print/Shift+Print (here) |
| DESK-09 | PipeWire + media keys | audio.nix + bindel/bindl (here) |
| DESK-10 | NetworkManager | network.nix + nm-applet exec-once (here) |
| DESK-11 | cliphist | clipboard.nix + Super+V (here) |
| KEY-01/02/06/07 | launcher/lock/screenshots/clipboard | all bound (here) |

## Next Step

User must run:

```bash
sudo nixos-rebuild switch --flake .#nervos
```

and reboot (or log out of Hyprland) to verify the behavioral success criteria:

- `pactl info` reports PipeWire as server
- nm-applet tray icon appears in waybar
- Super+V pops a rofi-driven clipboard list
- Print / Shift+Print capture to the clipboard
- Super+SPACE opens drun; Super+L locks
- XF86AudioRaiseVolume / Lower / Mute work via wpctl; play/pause/next/prev via playerctl

## Self-Check

- `modules/nixos/audio.nix`: FOUND
- `modules/nixos/network.nix`: FOUND
- `modules/home/clipboard.nix`: FOUND
- Commit `7e7b2bd`: FOUND
- Commit `6a3d1a0`: FOUND
- Commit `1ee254c`: FOUND

## Self-Check: PASSED
