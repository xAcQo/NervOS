# Ecosystem Analysis for NervOS
*Source: Gemini Deep Research, 2026-04-17*

## Summary of Key Architectural Findings

### Critical Decision: Use NixOS Specialisations for Profile Switching
Each pilot profile = a NixOS `specialisation {}` block. Switching at runtime via:
```bash
/run/current-system/specialisation/rei/bin/switch-to-configuration test
```
No rebuild required. No custom daemon. Replaces the planned nervos-switcher Phase 6 daemon approach.

### Font Decision: No Matisse EB (proprietary)
Use **Cinzel** or **Noto Serif Display** (SIL OFL) + `transform: scaleX(0.8)` in QML/CSS.
scaleX works in QML and Astal — NOT in GTK CSS (Waybar). This confirms the shell pivot.

### Shell: Consider caelestia-dots/shell
9k stars, QML+TypeScript, GPL-3.0, Home Manager module. QML supports real CSS transforms.
May be preferable to end-4/dots-hyprland for NervOS given the geometric widget requirements.

---

## Desktop Shell & Widget Ecosystems

### Comparative Table

| Repository | Stars | Last Commit | License | Nix/Flake Friendly |
|---|---|---|---|---|
| caelestia-dots/shell | 9,000 | 2026-04-02 | GPL-3.0 | Yes (Home Manager Module) |
| JaKooLit/Hyprland-Dots | 3,300 | 2026-03-01 | Unspecified | Via Install Script |
| fufexan/dotfiles | 1,100 | 2026-04-13 | MIT | Yes (Native Nix) |
| mylinuxforwork/dotfiles | 2,600 | 2024-12-02 | Unspecified | Partial (Arch focus) |

### caelestia-dots/shell
- **Repo:** https://github.com/caelestia-dots/shell
- **Stars / Last Commit:** 9k / 2026-04-02
- **License:** GPL-3.0 (Permits redistribution)
- **NixOS/flake-friendly:** Yes, dedicated Home Manager module
- **What it does:** Highly aesthetic desktop shell built with QML and TypeScript, high-density information displays and fluid animations.
- **How NervOS uses it:** Reference caelestia-cli for orchestrating shell reloads; study its systemd integration for widget lifecycle management.
- **Known issues:** Heavy reliance on specific QML modules; some users report hard freezes on specific hardware.

### fufexan/dotfiles
- **Repo:** https://github.com/fufexan/dotfiles
- **Stars / Last Commit:** 1.1k / 2026-04-13
- **License:** MIT (Permits redistribution)
- **NixOS/flake-friendly:** Yes, exports packages and modules directly
- **What it does:** Library-oriented Nix configuration with helper functions for Wayland-compatible themes.
- **How NervOS uses it:** Depend on helper functions for wallpaper hashing and host-specific specialisations.
- **Known issues:** Highly opinionated; may require significant refactoring to integrate with chosen shell.

---

## Widget Libraries: AGS, Astal, Quickshell

### Aylur/astal
- **Repo:** https://github.com/Aylur/astal
- **Stars / Last Commit:** 939 / 2026-04-10
- **License:** LGPL-2.1 (Permissible for OS inclusion)
- **NixOS/flake-friendly:** Yes, native Nix support
- **What it does:** Modular toolkit for building desktop shells — separates backend logic (Vala/C, D-Bus) from frontend UI (TypeScript/Python).
- **How NervOS uses it:** Depend on core libraries to build Pilot Selection GUI and MAGI status monitors.
- **Known issues:** Rapid development; API stability not yet guaranteed.

### outfoxxed/quickshell
- **Repo:** https://github.com/outfoxxed/quickshell
- **Stars / Last Commit:** 220 / 2025-11-15
- **License:** GPL-3.0
- **NixOS/flake-friendly:** Yes, via Quickshell overlay
- **What it does:** QML-based shell engine treating the desktop as a single GPU-accelerated canvas.
- **How NervOS uses it:** Reference for hexagonal MAGI dashboard — QML is superior for complex geometric rendering.
- **Known issues:** QML LSP/tooling support described as "the worst" by developers.

---

## Profile and Theme Switching Engines

### NixOS Specialisations (built-in)
Each pilot profile is a `specialisation {}` in configuration.nix. Activating at runtime:
```bash
/run/current-system/specialisation/<pilot>/bin/switch-to-configuration test
```
This updates colors, fonts, sounds, animations without a full rebuild.
Changes `stylix.base16Scheme` and `services.pipewire.extraConfig` per profile.
**Replaces the planned nervos-switcher daemon (Phase 6).**

### InioX/matugen
- **Repo:** https://github.com/InioX/matugen
- **Stars / Last Commit:** 1.6k / 2026-04-12
- **License:** GPL-2.0 (Permits redistribution)
- **NixOS/flake-friendly:** Yes, NixOS and Home Manager modules provided
- **What it does:** Color palette generator and templating engine — extracts colors from images or hex codes and applies to templates at runtime.
- **How NervOS uses it:** Fork or depend on Home Manager module to inject pilot-specific colors into Hyprland and Waybar configurations.
- **Known issues:** Does not automatically symlink files; requires manual path management.

---

## Soundscape and Auditory Engineering

### arabianq/pipewire-soundpad
- **Repo:** https://github.com/arabianq/pipewire-soundpad
- **Stars / Last Commit:** ~150 / 2026-03-20
- **License:** MIT
- **NixOS/flake-friendly:** Yes, via Rust crate packaging
- **What it does:** Soundboard app that creates virtual microphones and routes audio through PipeWire graph.
- **How NervOS uses it:** Reference daemon-client architecture for the persistent "Pilot Ambience Service" that plays ambient loops.
- **Known issues:** Requires running PipeWire instance and specific virtual device configs to avoid latency.

### Legal Guidance for Audio Assets
- **Classical Music:** Use public domain recordings only. Do NOT use OST recordings.
- **Industrial Loops:** Create original assets via synthesis. The "MAGI hum" = composite of low-frequency oscillations.
- **Notification Sounds:** Recreate iconic mechanical sounds (e.g., NERV bridge "ping") from scratch using Audacity. Heavily-inspired but recreated sounds carry lower legal risk than distributing official .wav files.
- **Shiro Sagisu compositions:** Strictly copyrighted. CANNOT be included in any distributed ISO.

---

## Boot Experience

### adi1090x/plymouth-themes
- **Repo:** https://github.com/adi1090x/plymouth-themes
- **Stars / Last Commit:** 2.6k / 2024-05-26
- **License:** GPL-3.0
- **NixOS/flake-friendly:** Yes, packaged in nixpkgs as `plymouth-themes`
- **What it does:** Vast collection of Plymouth boot animations.
- **How NervOS uses it:** Reference angular/colorful_loop themes to build custom NERV "Booting System" animation.
- **Known issues:** Optimized for 1366x768; may require scaling for modern displays.

### rharish101/ReGreet (greetd greeter)
- **Repo:** https://github.com/rharish101/ReGreet
- **Stars / Last Commit:** 710 / 2026-04-15
- **License:** GPL-3.0
- **NixOS/flake-friendly:** Yes, unofficial NixOS module exists
- **What it does:** Clean GTK4-based greeter for greetd with custom CSS styling support.
- **How NervOS uses it:** Depend on module; use `extraCss` to implement EVA scanlines and industrial borders for Phase 9 login screen.
- **Known issues:** Primarily designed for single-monitor setups.

### wongmjane/nerv-theme
- **Repo:** https://github.com/wongmjane/nerv-theme
- **Stars / Last Commit:** 49 / 2026-01-15
- **License:** MIT
- **What it does:** Industrial aesthetic theme drawing from NERV headquarters aesthetic.
- **How NervOS uses it:** Extract color philosophy and asset styles for GRUB and Plymouth theme direction.

---

## ISO Generation and Installer

### pete3n/nix-offline-iso
- **Repo:** https://github.com/pete3n/nix-offline-iso
- **Stars / Last Commit:** 29 / 2026-02-18
- **License:** MIT
- **NixOS/flake-friendly:** Yes, provides flake template
- **What it does:** Creates offline ISOs of the Calamares installer; patches install script to include user-provided configurations.
- **How NervOS uses it:** Fork to create a "NERV Deployment Kit" ISO with all pilot specialisations in local Nix store.
- **Known issues:** **Main branch is broken — use v0.3.14 branch.**

### ISO Generation (NixOS 25.05+)
```bash
nixos-rebuild build-image --image-variant iso
```
Replaces most nixos-generators functionality natively.

### Calamares Integration
Use calamares-nixos-extensions from the NixOS community; override branding assets. Ensure username and desktop environment in installer match configuration.nix on the ISO to avoid dependency failures.

---

## Visual Assets and Typography

### Font Alternatives to Matisse EB

| Font | Category | Similarity | License |
|---|---|---|---|
| Nimbus Roman No. 9 | Serif | Used in English NERV logo | GPL / URW |
| Noto Serif Display | Serif | Strong geometric serifs | SIL OFL |
| Cinzel | Serif | Excellent "monumental" Roman | SIL OFL |
| Orbitron | Display | Geometric, industrial | SIL OFL |
| Archivo Black | Sans | Heavy, compressed industrial | SIL OFL |

**Implementation:** Apply `transform: scaleX(0.8)` in CSS/QML to any open-source font to replicate the Evangelion horizontally-compressed title card look. This works in QML and Astal — NOT in GTK CSS (Waybar).

### Asset Licensing
- **Wallpapers:** Official imagery strictly copyrighted. Use fan-made or AI-generated "inspired" landscapes (red oceans, Tokyo-3 skylines).
- **Pilot Portraits:** Fan-made assets or vectorized silhouettes safer than official production cels.
- **Reference:** xero/evangelion.nvim for high-quality aesthetic baseline that avoids direct copyright infringement.

---

## Interactive Components

### MAGI Dashboard Geometry
Hexagonal layout math for positioning eww/Astal widgets:

$$x = \text{size} \cdot \left( \frac{3}{2} \cdot q \right)$$
$$y = \text{size} \cdot \left( \frac{\sqrt{3}}{2} \cdot q + \sqrt{3} \cdot r \right)$$

### DigitalSmile/hexagon
- **Repo:** https://github.com/DigitalSmile/hexagon
- **License:** MIT (math reference only — Java library)
- **How NervOS uses it:** Reference the hexagonal grid math for positioning eww or Astal widgets.

---

## Top 10 Projects to Adopt First

1. **InioX/matugen** — Atomic palette generation across pilot identities
2. **rharish101/ReGreet** — GTK4 architecture for login and pilot selection screens
3. **pete3n/nix-offline-iso** (v0.3.14) — Custom-branded offline-capable NixOS ISO template
4. **caelestia-dots/shell** — High-quality aesthetic reference with Nix module
5. **fufexan/dotfiles** — Library structure for host-specific specialisations
6. **adi1090x/plymouth-themes** — Splash animation reference for boot experience
7. **wongmjane/nerv-theme** — NERV hex codes and aesthetic direction
8. **arabianq/pipewire-soundpad** — Virtual audio daemon architecture reference
9. **TheGreatGildo/nerv-ui** — Complete CSS design system for NERV console interfaces
10. **DigitalSmile/hexagon** — Math reference for MAGI hexagonal dashboard geometry

---

## Legal-Risk Mitigation

- **Typography:** Do NOT include FOT-MatissePro-EB. Use Noto Serif Display or Cinzel + scaleX(0.8).
- **Audio:** No Shiro Sagisu compositions. Use PipeWire generative industrial hums or public domain classical recordings.
- **Assets:** Replace official NERV/pilot iconography with original vector interpretations or silhouettes.

---

## Critical Gap Analysis (Must Build From Scratch)

1. **Unified Pilot Switching Daemon** — Matugen handles colors, specialisations handle state, but a unified service to synchronize auditory crossfade + wallpaper transition + shell reload into one seamless event is still needed.
2. **Hexagonal Astal/AGS Wrapper** — No native Vala/C wrapper exists for rendering hexagonal system monitors in Astal. Must build for Phase 8 MAGI dashboard.
3. **Identity Persistence Layer** — Mechanism to track and restore "Last Selected Pilot" across reboots (state file in `/var/lib/nervos`) integrated into greetd login process.
