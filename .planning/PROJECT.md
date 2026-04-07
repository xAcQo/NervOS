# NervOS

## What This Is

NervOS is a NixOS-based Linux distribution dedicated entirely to the world of Neon Genesis Evangelion. Built on Hyprland and Stylix, it immerses the user in NERV HQ from the moment they power on — themed bootloader, Plymouth animation, login screen, desktop, sounds, and system widgets all coordinated. The defining feature is the **Pilot Selection System**: a GTK4 GUI that lets users choose their EVA unit (NERV Command, Unit-01 Shinji, Unit-00 Rei, Unit-02 Asuka), instantly transforming every pixel, sound, and animation to match that pilot's identity. No other distro or rice ships live multi-profile switching with synchronized soundscapes.

## Core Value

A single click or hotkey transports you into the world of Evangelion — every pixel, sound, font, and animation shifts to match your chosen pilot's identity.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] NixOS flake-based configuration with Hyprland as the window manager
- [ ] Stylix powers the theming layer — base16 palettes drive all components from a single definition
- [ ] 4 pilot profiles fully implemented: NERV Command, Unit-01 Shinji, Unit-00 Rei, Unit-02 Asuka
- [ ] Each profile covers: colors, fonts, wallpaper, cursor, window borders, Waybar CSS, Rofi, terminal, notifications, lock screen, animations
- [ ] `nervos-switcher` daemon applies profile switches at runtime (sub-3s, no rebuild)
- [ ] GTK4 "Pilot Selection" app for switching profiles live without terminal
- [ ] Keyboard shortcuts for profile switch (Super+P GUI, Super+Shift+P cycle)
- [ ] Per-profile soundscape: ambient audio loop + notification sounds + system event sounds
- [ ] MAGI hexagonal eww widget overlay (CPU=CASPAR, RAM=BALTHASAR, NET=MELCHIOR)
- [ ] Full boot pipeline: GRUB → Plymouth → greetd greeter → first-boot welcome app
- [ ] Bootable ISO with graphical installer — installs like any standard Linux distro

### Out of Scope

- Lain / Steins;Gate themes — NervOS is a dedicated Evangelion distro
- Gaming optimization (GameMode, Steam) — later milestone, v2
- User theme creation GUI — v2
- Voice command / speech-to-text triggers — v2 after core is stable
- Multiple window managers — Hyprland is the identity
- Flatpak / Snap — breaks GTK theming consistency
- Wayland/X11 dual support — Hyprland is Wayland-only by design

## Context

- **Pure EVA identity**: NervOS is 100% dedicated to Neon Genesis Evangelion — not a generic theme switcher. Every design decision reinforces the EVA world.
- **Pilot profiles**: 4 sub-themes tied to EVA units — NERV Command (orange/black), Unit-01 Shinji (purple/green), Unit-00 Rei (blue/white/cold), Unit-02 Asuka (red/orange). Each is a complete aesthetic system.
- **Asset collection**: User has curated EVA image folders (Neon Genesis Evangelion (Pics)/) — these are the wallpaper source material
- **Gemini research**: Deep research document identified: EVA sound rips from Evangelion 64 (800+ effects), Matisse EB as the canonical NGE font, MAGI hexagonal dashboard as signature UI element, Plymouth + GRUB + SDDM as the full boot theming pipeline
- **Hybrid switching**: All profiles pre-generated at Nix evaluation time; runtime daemon swaps symlinks + sends reload signals. Sub-3s switch, no nixos-rebuild needed.
- **NixOS advantage**: Declarative config makes profile definitions reproducible and the ISO build deterministic
- **Target users**: Power users AND anime fans — beautiful by default, hackable for those who go deeper. Zero terminal required for daily use.

## Constraints

- **Tech stack**: NixOS + Hyprland + Stylix — not negotiable, central to the architecture
- **GUI**: GTK4 for the Vibe Switcher — native Linux, low footprint, integrates cleanly with Hyprland
- **Distribution**: Must be installable as a bootable ISO — standard distro install experience
- **Greenfield**: Fresh start, no existing NixOS config — building from zero
- **Gaming**: Deferred to later milestone — focus v1 on aesthetics and the switching system

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Pure EVA focus — no Lain/S;G | NervOS is a dedicated Evangelion distro, not a generic switcher. Strong identity beats broad coverage | — Pending |
| 4 pilot profiles in v1 | NERV Command + 3 units gives depth and choice without scope explosion | — Pending |
| GTK4/PyGObject for Pilot Selection app | Native Linux, minimal footprint, no Electron; can port to Rust later if needed | — Pending |
| GTK4 without libadwaita | libadwaita overrides GTK themes, conflicting with per-profile theming | — Pending |
| Hybrid switching (pre-gen + runtime daemon) | Sub-3s theme switch without NixOS rebuild; declarative profiles stay reproducible | — Pending |
| NixOS flakes on unstable channel | Hyprland + Stylix release cadence requires unstable; stable channel lags too far | — Pending |
| Stylix as theming layer | Single base16 palette drives all components; manual per-app overrides only for Stylix gaps | — Pending |
| eww for MAGI dashboard in v1 | MAGI widgets are the signature NervOS UI element — not a polish item | — Pending |
| Project renamed NervOS | EVA/NERV is the identity; name is the promise | — Pending |

---
*Last updated: 2026-04-06 after initialization*
