---
phase: 02-desktop-shell
plan: 03
subsystem: desktop-shell
tags: [hyprpaper, grimblast, wallpaper, screenshots, wayland, home-manager, nixos]

requires:
  - phase: 01-flake-foundation
    provides: home-manager wiring, assets/wallpaper.jpg (Stylix placeholder)
  - phase: 02-desktop-shell
    provides: Hyprland session (02-01), mako notifications (02-02)
provides:
  - services.hyprpaper home-manager service pointing at assets/wallpaper.jpg
  - System-wide screenshot toolchain (grimblast, grim, slurp, hyprpicker, wl-clipboard, jq, libnotify)
  - Input helpers in system packages (brightnessctl, playerctl) for Plan 02-04 keybinds
affects: [02-04, phase-03, phase-05]

tech-stack:
  added: [hyprpaper, grimblast, grim, slurp, hyprpicker, wl-clipboard, jq, libnotify, brightnessctl, playerctl]
  patterns:
    - "Wallpaper asset referenced via relative Nix path (../../assets/wallpaper.jpg) so Stylix lock screen and desktop share one source of truth"
    - "wl-clipboard installed at NixOS level (not home-manager) so systemd user services can access wl-copy/wl-paste"
    - "CLI tools used by keybinds live in environment.systemPackages (centralised package management)"

key-files:
  created:
    - modules/home/wallpaper.nix
  modified:
    - modules/home/default.nix
    - hosts/nervos/default.nix

key-decisions:
  - "Chose hyprpaper over swww -- swww archived late 2024, hyprpaper is the Hyprland-blessed daemon"
  - "grimblast over hand-rolled grim+slurp bash -- handles hyprctl freeze, wl-copy, and notifications correctly"
  - "wl-clipboard at NixOS level (not home-manager) so systemd user services and any process can use wl-copy/wl-paste"
  - "brightnessctl/playerctl added now (Plan 02-03) even though keybinds land in 02-04 -- co-locate CLI tooling"

patterns-established:
  - "Wallpaper path: single relative Nix import string shared between Stylix base + hyprpaper preload"
  - "Screenshot stack: grimblast + deps as system packages; daemon (hyprpaper) as home-manager service"

duration: ~2min
completed: 2026-04-15
---

# Phase 2 Plan 03: Wallpaper + Screenshot Toolchain Summary

**hyprpaper home-manager service displaying assets/wallpaper.jpg, plus grimblast + grim/slurp/hyprpicker/wl-clipboard/jq/libnotify/brightnessctl/playerctl in system packages -- ready for Plan 02-04 keybinds**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-04-15T19:17:10Z
- **Completed:** 2026-04-15T19:18:24Z
- **Tasks:** 3 (2 file-modifying + 1 verification)
- **Files created:** 1
- **Files modified:** 2

## Accomplishments

- Wallpaper daemon (hyprpaper) wired as user-level home-manager service, pointing at the existing `assets/wallpaper.jpg` used by Stylix
- Full screenshot toolchain (grimblast + grim + slurp + hyprpicker + wl-clipboard + jq + libnotify) added to `environment.systemPackages`
- Input helper CLIs (brightnessctl, playerctl) pre-installed so Plan 02-04 can bind XF86 media keys without another package bump
- No use of archived `swww`; research pitfall avoided

## Task Commits

Each task was committed atomically:

1. **Task 1: Create wallpaper.nix with hyprpaper service** - `976dd70` (feat)
2. **Task 2: Add screenshot toolchain to system packages** - `7bf33c2` (feat)
3. **Task 3: Flake evaluation check** - no commit (verification-only; see deferral note below)

**Plan metadata:** appended below (docs commit after SUMMARY.md)

## Files Created/Modified

- `modules/home/wallpaper.nix` (new) - services.hyprpaper config, preloads + displays `../../assets/wallpaper.jpg` on all monitors
- `modules/home/default.nix` - imports `./wallpaper.nix`
- `hosts/nervos/default.nix` - `environment.systemPackages` expanded with screenshot toolchain + input helpers

## Decisions Made

- **hyprpaper over swww:** swww repository was archived late 2024; hyprpaper is the Hyprland project's blessed wallpaper daemon and matches RESEARCH.md mandate
- **grimblast (not a hand-rolled pipeline):** it already handles `hyprctl clients` JSON parsing (needed for active-window capture), wl-clipboard integration, and the hyprpicker freeze overlay during area selection
- **wl-clipboard at NixOS level:** systemd user services (notifications, clipboard daemons planned later) require wl-copy/wl-paste in PATH -- home-manager only exposes them to the interactive login shell
- **brightnessctl/playerctl added now:** Plan 02-04 will reference these for media/brightness keybinds; installing them in 02-03 keeps CLI package management centralised

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

### Flake check deferred (consistent with Plans 02-01 / 02-02)

Task 3 prescribed `nix flake check --no-build`, but the executor host is Windows and has no `nix` binary available. Following the precedent set in 02-01-SUMMARY.md and 02-02-SUMMARY.md, the check was deferred to the target NixOS host's next `nixos-rebuild`.

Static review confirms:
- `modules/home/wallpaper.nix` is a well-formed `{ ... }:` lambda with a balanced `let ... in { ... }` body; `services.hyprpaper.{enable,settings.{preload,wallpaper}}` is a documented home-manager option path.
- `hosts/nervos/default.nix` change is a pure list-append inside `environment.systemPackages = with pkgs; [ ... ];`; all added identifiers (grimblast, grim, slurp, hyprpicker, wl-clipboard, jq, libnotify, brightnessctl, playerctl) are standard nixpkgs attribute names.
- `modules/home/default.nix` gained one list entry (`./wallpaper.nix`) matching sibling imports.

Risk of evaluation failure at `nixos-rebuild` time: minimal.

## User Setup Required

None - no external service configuration required. On the next `nixos-rebuild switch`, hyprpaper will start as a user systemd unit via the home-manager service and the screenshot toolchain will become available system-wide.

## Next Phase Readiness

- **Plan 02-04 unblocked:** `grimblast`, `wl-clipboard`, `brightnessctl`, `playerctl`, `libnotify` are all in PATH once 02-03 lands; 02-04 can wire PrtSc / Shift+PrtSc / XF86* keybinds directly
- **No blockers** for remainder of Phase 2
- Stylix + hyprpaper + hyprlock now all reference the same `assets/wallpaper.jpg` -- Phase 3 (pilot theming) will swap that asset per pilot and all three surfaces will update together

---
*Phase: 02-desktop-shell*
*Completed: 2026-04-15*

## Self-Check: PASSED

- FOUND: modules/home/wallpaper.nix
- FOUND: commit 976dd70 (Task 1)
- FOUND: commit 7bf33c2 (Task 2)
- FOUND: assets/wallpaper.jpg (pre-existing, referenced)
- modules/home/default.nix contains `./wallpaper.nix` import
- hosts/nervos/default.nix contains grimblast, wl-clipboard, slurp, libnotify, brightnessctl, playerctl
