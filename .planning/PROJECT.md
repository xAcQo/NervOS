# NervOS

## What This Is

NervOS is a NixOS-based Linux distribution built around Hyprland and Stylix, designed for users who want to feel like they are *inside* an anime world, not just using a themed desktop. The defining feature is a real-time "Vibe Switcher" — a GTK4 GUI application that lets users swap between fully immersive aesthetic environments (EVA, Lain, Steins;Gate, and user-added themes) with no terminal interaction. The first theme — EVA — recreates the NERV HQ aesthetic: near-black red-tinted background, amber/orange glowing UI elements, green MAGI terminal text, and NERV-style system displays.

## Core Value

A single click or hotkey transports you visually, audibly, and spatially into another world — every pixel, sound, and font shifts to match the vibe.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] NixOS flake-based configuration with Hyprland as the window manager
- [ ] Stylix powers the theming layer — colors, fonts, and wallpapers defined per-theme
- [ ] EVA theme fully implemented: NERV color palette, fonts, wallpapers, soundscape, window borders, waybar, and rofi
- [ ] GTK4 Vibe Switcher GUI app for switching themes live without a terminal
- [ ] Theme switching triggers via both GUI button and configurable keyboard shortcut
- [ ] Bootable ISO installer — installs NervOS like any standard Linux distro (Arch/Ubuntu flow)
- [ ] User can add custom themes (colors, fonts, wallpapers, sounds) through the GUI
- [ ] User can modify existing theme properties (colors, fonts, animations, sounds) through the GUI
- [ ] Soundscape system — each theme plays unique ambient sounds / system notification sounds
- [ ] Theme assets included: EVA wallpapers, fonts, and sounds bundled in the repo
- [ ] Lain theme implemented (second theme after EVA)
- [ ] Steins;Gate theme implemented (third theme)

### Out of Scope

- 1000-tool security command center — deferred, separate milestone
- Dedicated hardware repair/diag mode for console flashing — can be added later if it doesn't interfere
- Gaming optimization (GameMode, Steam/Epic tuning, GPU overlay) — later milestone, v2
- Voice command / speech-to-text triggers — later milestone after core theming is stable
- AniList / external service integrations — not relevant to OS theming
- Wayland/X11 dual support — Hyprland is Wayland-only by design

## Context

- **Reference distro**: LainOS exists as a Lain-themed Linux desktop — useful as aesthetic reference but NervOS is built fresh on NixOS flakes, not forked from LainOS
- **Theme assets**: User has curated image folders for EVA, Lain, and Steins;Gate — these are the visual source material for each theme
- **EVA aesthetic**: Dark near-black with red undertone background, amber/orange glowing borders and UI elements, green monospace terminal text — inspired by NERV HQ MAGI terminals and the EVA-00 analysis interface
- **NixOS advantage**: Declarative config means theme switching can be a pure config swap, making atomic and reproducible vibe changes natural
- **Stylix integration**: Stylix generates color schemes for all Hyprland components from a single base16 palette — perfect for per-theme overrides
- **Target users**: Both power users (want a beautiful opinionated setup without config hell) and anime aesthetic fans (fully GUI-driven, no terminal required for day-to-day use). The OS is beautiful by default and hackable for those who want to go deeper.

## Constraints

- **Tech stack**: NixOS + Hyprland + Stylix — not negotiable, central to the architecture
- **GUI**: GTK4 for the Vibe Switcher — native Linux, low footprint, integrates cleanly with Hyprland
- **Distribution**: Must be installable as a bootable ISO — standard distro install experience
- **Greenfield**: Fresh start, no existing NixOS config — building from zero
- **Gaming**: Deferred to later milestone — focus v1 on aesthetics and the switching system

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| EVA theme first | Most distinctive NERV UI aesthetic, clear color palette (amber/orange/dark), strong visual identity for the project | — Pending |
| GTK4 for Vibe Switcher | Native Linux, minimal footprint, no Electron overhead, integrates with Hyprland naturally | — Pending |
| NixOS flakes | Reproducible, declarative — theme switching maps perfectly to config swaps; makes the ISO build deterministic | — Pending |
| Stylix as theming layer | Single source of truth for colors/fonts across all Hyprland components (waybar, rofi, terminals, borders) | — Pending |
| Project renamed to NervOS | EVA/NERV aesthetic is the primary identity of v1; name reflects the NERV HQ core | — Pending |

---
*Last updated: 2026-04-06 after initialization*
