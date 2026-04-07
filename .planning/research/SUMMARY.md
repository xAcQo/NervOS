# Project Research Summary

**Project:** NervOS
**Domain:** NixOS-based custom Linux distribution with EVA/NERV anime aesthetic, Hyprland compositor, Stylix theming engine, and a real-time GTK4 Vibe Switcher GUI
**Researched:** 2026-04-06
**Confidence:** MEDIUM (training data through early 2025; no live web verification possible)

---

## Executive Summary

NervOS is a full-stack custom Linux distribution -- not a dotfile collection, not a skin pack. It targets the intersection of NixOS declarative reproducibility and the Wayland ricing community aesthetic ambition. The recommended approach is a NixOS flake using nixos-unstable as the base channel, with Hyprland pulled from its own upstream flake, Stylix as the single source of truth for color propagation, and home-manager integrated as a NixOS module (not standalone). Every theme variant -- EVA, Lain, Steins;Gate -- is pre-built at Nix evaluation time as a full config set in the Nix store. Theme switching at runtime is a file-symlink swap plus ordered reload signals, never a full nixos-rebuild. This hybrid build-time/runtime architecture is the central design decision the entire project depends on.

The killer differentiator is the Vibe Switcher: a GTK4 application backed by a nervos-switcher daemon that swaps pre-generated theme config sets and sends reload signals to Hyprland (via hyprctl reload), Waybar (via SIGUSR2), the wallpaper daemon (via swww img), and the terminal (via kitty remote color set), achieving a full visual transformation in under three seconds. No other anime-themed distro or r/unixporn rice implements live theme switching. The second major differentiator is per-theme soundscapes -- ambient audio loops plus event-driven notification sounds -- which are entirely absent from the ecosystem and are the single strongest immersion layer available. These two features together separate NervOS from wallpaper with matching colors into stepping inside a world.

The dominant risk cluster is threefold: (1) NixOS module composition creating infinite recursion if Stylix and Hyprland modules conflict over shared options -- must be addressed in Phase 1; (2) Stylix not theming all visible components (Plymouth, lock screen, GTK4/libadwaita apps have known gaps) -- must be audited in Phase 2 with manual gap-filling modules; (3) the live theme switch leaving stale components (cursor requires logout, running GTK3 apps require restart) -- the Vibe Switcher must handle a defined ordered reload sequence and document known limitations. NVIDIA GPU support is a persistent background risk across all phases.

---

## Key Findings

### Recommended Stack

The core runtime stack is well-established with HIGH confidence: Hyprland (from its own flake, not nixpkgs) as the Wayland compositor, Stylix (from danth/stylix flake) as the base16 theming engine, home-manager as a NixOS module, Waybar for the status bar, rofi-wayland for the launcher, mako for notifications, swww for animated wallpaper transitions, and kitty as the terminal emulator. All flake inputs must follow nixpkgs to avoid multiple nixpkgs instances in the closure -- this is a non-negotiable structural rule. The nixos-unstable channel is preferred over stable because Hyprland rapid development means the stable channel always lags by 2-4 months.

The Vibe Switcher application should be built with Python 3.12 + PyGObject (GTK4 bindings) for initial development velocity, packaged with wrapGAppsHook4 and a GResource bundle for assets. Rust + gtk4-rs is the v2 path if performance matters. ISO generation uses native NixOS installer profiles (not nixos-generators) for the release ISO, with nixos-generators for dev VM builds. SDDM is recommended as the login manager for its QML theming depth; Plymouth provides the themed boot animation, both configured declaratively in NixOS.

**Core technologies:**
- NixOS (nixos-unstable): base OS -- reproducibility, declarative config, flake lockfile
- Nix Flakes: project structure -- pins all dependencies, single flake.lock for the whole distro
- Hyprland (upstream flake): Wayland compositor -- dynamic tiling, blur, animations, hyprctl IPC
- Stylix (danth/stylix flake): base16 theming engine -- single palette propagates to GTK, Waybar, kitty, rofi, mako, Hyprland borders, GRUB, SDDM
- home-manager (as NixOS module): user-space config -- keeps system and user config aligned
- swww: wallpaper daemon -- animated transitions between wallpapers during theme switches
- GTK4 + Python/PyGObject: Vibe Switcher GUI -- native Wayland app, no Electron
- nervos-switcher daemon: theme switching backend -- symlink swaps + ordered reload signals

### Expected Features

**Must have (table stakes) -- without these NervOS is a broken distro:**
- Working Hyprland desktop on boot, including NVIDIA detection -- GPU issues are a DOA experience
- Fully coordinated color scheme across Hyprland borders, Waybar, rofi, kitty, GTK apps, mako notifications, lock screen -- one unthemed element breaks immersion
- Themed Waybar with workspace, clock, volume, and network modules
- Themed rofi-wayland launcher matching the active theme
- Wallpaper management with swww animated transitions
- Themed hyprlock lock screen
- Notification system (mako) with per-theme colors
- Screenshot tooling (grim + slurp) bound to PrtSc
- Working audio (PipeWire + WirePlumber), clipboard (wl-clipboard), network (NetworkManager)
- Bootable ISO with graphical or scripted installer
- Plymouth + GRUB/systemd-boot themed to match active theme
- Themed greetd greeter (login screen)

**Should have (differentiators) -- what makes NervOS worth using over a dotfile repo:**
- Live theme switching via Vibe Switcher GTK4 GUI -- the primary differentiator
- Per-theme soundscapes: ambient audio loop + themed notification/event sounds
- Per-theme Hyprland animation presets (sharp/mechanical for EVA, glitchy for Lain)
- Keyboard shortcut for theme cycling (Super+Space or similar)
- At least two fully implemented themes (EVA + Lain) to validate the switching system
- First-boot welcome app guiding initial theme selection
- eww-based in-world system monitor widgets (MAGI-styled for EVA) -- v1.x polish
- Per-theme cursor and icon packs

**Defer (v2+):**
- Steins;Gate theme (validates extensibility but not needed for core validation)
- User theme creation GUI (add once early users ask how to make their own)
- Gaming optimization (scope explosion; users can self-serve via Nix)
- Animated/video wallpapers (GPU-intensive, niche demand)
- Theme marketplace / community sharing (requires infrastructure)
- Flatpak/app store integration (breaks GTK theming consistency)

### Architecture Approach

NervOS uses a four-layer architecture: the Nix build layer (flake.nix, Stylix, home-manager, NixOS modules) generates all theme config sets at build time as Nix store derivations; the theme asset layer stores pre-built config files and assets per theme; the theme runtime layer (nervos-switcher daemon) performs atomic symlink swaps and ordered reload signals; and the user interface layer (Vibe Switcher GTK4 app, Hyprland, Waybar, rofi) exposes everything to the user. This hybrid approach -- build everything at Nix eval time, switch by symlink at runtime -- preserves NixOS reproducibility without imposing rebuild latency on theme changes.

**Major components:**
1. flake.nix -- root entry point, defines all inputs (nixpkgs, home-manager, Hyprland, Stylix, nixos-generators), all outputs (nixosConfigurations for install + ISO, packages, devShells)
2. Stylix module -- system-wide base16 palette engine; single source of truth for all colors; runs at build time to generate per-app config files
3. Theme definitions (themes/) -- Nix attribute sets per theme (EVA, Lain, Steins;Gate); each defines base16 colors, wallpaper path, fonts, sounds, animation presets, per-app overrides; validated by a mkTheme library function in lib/theme.nix
4. nervos-switcher daemon -- runtime process, reads theme manifest from Nix store, atomically swaps symlinks in ~/.config, sends ordered reload signals: hyprctl reload -> SIGUSR2 to Waybar -> swww img with transition -> gsettings for GTK -> kitty remote color set -> ambient sound crossfade -> writes ~/.local/state/nervos/current-theme
5. Vibe Switcher (GTK4) -- user-facing GUI, communicates with nervos-switcher via D-Bus or Unix socket, shows theme previews, triggers switches
6. ISO builder -- uses native NixOS installer profiles; all themes pre-built into the ISO; firmware packages included for broad hardware support
7. NixOS + home-manager modules -- system config (kernel, audio, display manager, networking) cleanly separated from user config (Hyprland settings, Waybar, rofi, terminal, GTK)

**Recommended flake structure:**
```
nervos/
├── flake.nix / flake.lock
├── hosts/default/ + hosts/iso/
├── modules/nixos/  (core, hyprland, audio, display-manager, fonts)
├── modules/home/   (hyprland, waybar, rofi, terminal, gtk, shell, vibe-switcher)
├── themes/eva/ + themes/lain/ + themes/steins-gate/
├── packages/vibe-switcher/ + packages/nervos-switcher/
├── lib/  (theme.nix mkTheme function, utils.nix)
└── iso/  (default.nix, installer/)
```

### Critical Pitfalls

1. **Infinite recursion in NixOS module composition** -- Stylix and Hyprland both set overlapping options (cursor, fonts, GTK). Avoid by never referencing config.* inside options blocks, using lib.mkDefault/lib.mkForce to establish priority, and keeping import flow strictly top-down. Test each new module with nix eval in isolation. Address in Phase 1 -- cannot be fixed cheaply after the fact.

2. **Stylix does not theme everything** -- Known gaps: Plymouth (not managed by Stylix), GTK4/libadwaita apps (use their own AdwStyleManager), lock screen layout/images, some login manager configs. Audit every visual touchpoint in Phase 2; build standalone Nix modules for gaps that read from the same base16 palette Stylix exposes.

3. **Hyprland version pinning vs. nixpkgs lag** -- Always pull Hyprland from its upstream flake (not nixpkgs stable). Pin to a specific release tag, never follow main. Update Hyprland and nixpkgs together in CI. Address in Phase 1.

4. **Real-time theme switching requires ordered reload sequences** -- GTK3 apps do not hot-reload themes; cursor changes require logout; Waybar needs SIGUSR2 not just a file swap; ambient sound needs a PipeWire-ready startup delay. The nervos-switcher daemon must implement a defined reload sequence and document known limitations. Accept cursor updates require logout. Address in Phase 3.

5. **NixOS ISO missing firmware for real hardware** -- Include hardware.enableRedistributableFirmware = true and broadcom/Intel/Realtek WiFi firmware packages. Test on AMD, Intel, and NVIDIA VM configurations. NVIDIA requires specific environment variables and driver version 555+. Address in Phase 4, but create the nvidia.nix module in Phase 1.

6. **GTK4 app packaging requires wrapGAppsHook4 and GResource bundling** -- The Vibe Switcher will build locally but fail at runtime without correct GI_TYPELIB_PATH, GSETTINGS_SCHEMA_DIR, and XDG_DATA_DIRS. Use wrapGAppsHook4, bundle all assets via GResource XML, and run nix build .#vibe-switcher against a clean NixOS install early in Phase 3.

---

## Implications for Roadmap

### Phase 1: Flake Foundation and EVA Theme

**Rationale:** Everything in NervOS depends on a correctly structured flake. Module composition, Stylix integration, and Hyprland version pinning must be resolved before any feature work. EVA is the flagship theme -- complete it first, prove the architecture works, then the second theme validates that themes are composable rather than hardcoded.

**Delivers:** Buildable NixOS flake booting into a fully themed EVA desktop. Hyprland working on AMD/Intel. Stylix applying the EVA base16 palette across all supported targets. All table-stakes features present (audio, clipboard, screenshots, network, file manager, lock screen, themed greeter, Plymouth). Stylix gap audit document produced. nvidia.nix module created (tested minimally).

**Features addressed:** All table-stakes items, EVA theme fully implemented, themed GRUB + Plymouth, themed greetd greeter, basic Hyprland keybindings.

**Pitfalls addressed:** Infinite recursion (module structure correct from day one), Hyprland version pinning (upstream flake, pinned tag), NVIDIA module foundation, Stylix gap audit (gap list produced for Phase 2).

**Research flag:** Needs /gsd:research-phase -- Stylix current module API (stylix.targets.* namespace), Hyprland nixosModules.* current export name, nerdfonts package restructure, and current NixOS stable channel version all require live verification before implementation.

### Phase 2: Theming Layer Completeness and Lain Theme

**Rationale:** Stylix covers the majority of components but has documented gaps. Phase 2 fills those gaps with manual Nix modules reading from the same base16 palette, achieving the every-pixel-matches standard immersion requires. Lain is built simultaneously because the switching system (Phase 3) cannot be built without two themes to switch between. Per-theme animation presets and soundscape infrastructure are built here -- they enhance but do not structurally depend on the switching GUI.

**Delivers:** 100% visual coverage across all seven touchpoints (boot splash, login, desktop, lock screen, notifications, app chrome, terminal). Lain theme fully implemented. Per-theme Hyprland animation presets. Soundscape system (PipeWire ambient loop + event sounds) for EVA and Lain. Theme coverage matrix with pass/fail per component.

**Features addressed:** Lain theme, per-theme animations, soundscape system, themed lock screen, CJK font fallback, HiDPI/multi-monitor wallpaper handling.

**Pitfalls addressed:** Stylix theming gaps (gap-fill modules), GTK4 dark mode via dconf color-scheme prefer-dark, font fallback for Japanese text, sound system startup race condition (After=pipewire.service).

**Research flag:** Soundscape architecture (PipeWire event hooks, mpv vs. pw-play for ambient loops) may need a targeted spike. Stylix gap-fill pattern is community-established -- likely skippable.

### Phase 3: Vibe Switcher and nervos-switcher Daemon

**Rationale:** The switching infrastructure is the product primary differentiator. It cannot be built until at least two complete themes exist. The daemon is built before the GUI -- the CLI-driven switching mechanism is validated first (nervos-switch eva / nervos-switch lain), then the GTK4 GUI wraps it. This prevents building a GUI around a backend that does not actually work.

**Delivers:** nervos-switcher daemon with atomic symlink swaps + ordered reload sequence (Hyprland -> Waybar -> wallpaper -> GTK -> terminal -> audio). Vibe Switcher GTK4 GUI with theme previews and one-click switching. Keyboard shortcut for theme cycling. State persistence across reboots. Known limitations documented (cursor requires logout).

**Features addressed:** Live theme switching (CLI + GUI), keyboard shortcut theme cycling, animated wallpaper transitions (swww transition types per theme), Vibe Switcher GTK4 application.

**Pitfalls addressed:** Ordered reload sequence (not just config swap), GTK4 packaging with wrapGAppsHook4 and GResource bundles, theme switch preserving Hyprland window layout.

**Research flag:** Needs /gsd:research-phase -- D-Bus vs. Unix socket for GUI-to-daemon IPC in Wayland, kitty remote control API surface, swww transition type enumeration, and current wrapGAppsHook4 + PyGObject packaging patterns all need validation.

### Phase 4: ISO Builder and Hardware Support

**Rationale:** The ISO is the distribution artifact. It should not be built until the desktop experience is fully validated in a VM -- ISO debugging is an order of magnitude slower than VM debugging. All themes, the Vibe Switcher, and the soundscape must be stable before the ISO is cut.

**Delivers:** Bootable ISO with all themes pre-built, installer (Calamares or custom script), firmware packages for broad hardware support (Intel/AMD/NVIDIA/Broadcom WiFi), NVIDIA module tested, first-boot welcome app for initial theme selection, ISO size under 4GB, Cachix binary cache published.

**Features addressed:** Bootable ISO, first-boot welcome app, NVIDIA GPU support, hardware firmware coverage, keyboard layout selection in installer.

**Pitfalls addressed:** Missing firmware blobs (hardware.enableRedistributableFirmware), first boot dropping to TTY (autologin + Hyprland autostart verified), ISO size bloat (closure size check), NVIDIA env vars and driver 555+ requirement.

**Research flag:** Needs /gsd:research-phase -- NixOS flake-based installer tooling (Calamares NixOS integration is historically fragile; may need a custom nixos-install wrapper instead) and current nixos-generators vs. native ISO profiles community guidance.

### Phase 5: Polish, Steins;Gate Theme, and v1.x Features

**Rationale:** After a working, installable NervOS with two themes and the Vibe Switcher, this phase addresses polish and features deferred from v1. Starts only after early user feedback is gathered. Steins;Gate theme validates the theme extensibility story for community contributors.

**Delivers:** Steins;Gate theme, eww in-world widgets per theme (MAGI for EVA), per-theme cursor packages, onboarding flow polish, documentation.

**Features addressed:** Steins;Gate theme, eww in-world system monitors, per-theme cursors + icon packs.

**Research flag:** eww/Astal widget framework status by 2026 needs verification -- the ecosystem may have shifted. Otherwise standard patterns -- likely skippable.

### Phase Ordering Rationale

- Phase 1 before anything: flake structure and module boundaries must be correct or all downstream work breaks; cannot be refactored cheaply after the fact.
- Phase 2 before Phase 3: Vibe Switcher is meaningless without two complete themes; soundscape and animation presets are easier to integrate before the switching daemon adds complexity.
- Phase 3 before Phase 4: never build the ISO until the desktop is stable in a VM; ISO debugging is slow and disruptive.
- Phase 5 after user feedback: eww widgets and theme extensibility are community-facing features that need real usage to inform design decisions.

### Research Flags

**Needs /gsd:research-phase before implementation:**
- Phase 1: Stylix current API (stylix.targets.* namespace, config.lib.stylix.colors path, nerdfonts package split), Hyprland nixosModules.* current export name, NixOS current stable version
- Phase 3: D-Bus vs. Unix socket for GUI-daemon IPC in Wayland, kitty remote control API, swww transition types, wrapGAppsHook4 + PyGObject current packaging patterns
- Phase 4: NixOS flake-based installer tooling (Calamares integration stability)

**Standard patterns (skip research-phase):**
- Phase 2 soundscape system: PipeWire + mpv for ambient audio is well-documented
- Phase 2 Stylix gap-filling: pattern (standalone Nix module reading base16 palette) is community-established
- Phase 5 theme additions: mkTheme schema defined in Phase 1; adding themes is mechanical

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Core pattern (Hyprland + Stylix + home-manager + swww + rofi-wayland) is HIGH; specific module export names, nerdfonts package restructure, and current stable NixOS version need live validation |
| Features | MEDIUM | Feature landscape grounded in observable community patterns; soundscape differentiator is strongly reasoned but has no reference implementation to validate against |
| Architecture | MEDIUM | Hybrid build-time/runtime pattern is sound; Stylix multi-theme pre-generation capability and exact D-Bus/socket IPC design need validation before Phase 3 |
| Pitfalls | HIGH | Pitfalls are consistent across multiple documented community sources; NVIDIA issues, GTK4 packaging, Stylix gaps, and module recursion are all extensively reported |

**Overall confidence:** MEDIUM -- architectural approach and technology choices are well-grounded; specific API surfaces require validation before each phase begins.

### Gaps to Address

- **Stylix multi-theme pre-generation:** The architecture assumes Stylix can generate config sets for ALL themes at build time. Verify -- Stylix may only support a single active theme per build. If true, home-manager templating outside Stylix becomes the primary path for pre-generating per-theme config files.
- **Current NixOS stable channel version:** Research references 24.11/25.05; by April 2026 a newer stable may be current. Validate before pinning any channel.
- **Calamares + NixOS flake integration:** Historically fragile. Decide on installer strategy (Calamares vs. custom nixos-install wrapper vs. guided TUI) with a targeted research spike before Phase 4 begins.
- **swww vs. hyprpaper current status:** swww animated transitions are recommended; verify swww is still actively maintained and has better Wayland protocol support than hyprpaper in current versions.
- **nerdfonts package restructure:** nixpkgs was splitting nerdfonts into individual packages. Verify current package name before any font configuration is written.
- **eww vs. Astal:** The eww widget framework may have been superseded or significantly changed by Astal or other projects by 2026. Verify before Phase 5.

---

## Sources

### Primary (HIGH confidence)
- NixOS module system documentation -- module composition, infinite recursion patterns, lib.mkDefault/lib.mkForce priority
- Hyprland Wiki (Nix page, NVIDIA page) -- NixOS integration, GPU-specific pitfalls, hyprctl IPC
- GTK4 documentation -- app lifecycle, theme reload behavior, libadwaita AdwStyleManager
- Wayland protocol specifications -- cursor theme propagation constraints

### Secondary (MEDIUM confidence)
- github:danth/stylix -- flake structure, supported targets, base16Scheme API, opacity, cursor, polarity options
- github:hyprwm/Hyprland -- flake inputs, home-manager module, hyprctl IPC, wayland.windowManager.hyprland.settings pattern
- github:nix-community/home-manager -- NixOS module integration, user config separation
- github:nix-community/nixos-generators -- ISO/VM format generation
- NixOS Discourse and r/NixOS -- GTK4 packaging patterns, Stylix gap reports, custom distro ISO experiences
- r/unixporn Hyprland rice analysis -- feature landscape, immersion gaps, animation and typography patterns

### Tertiary (LOW confidence)
- LainOS project analysis -- competitor feature baseline; claims are observational, not from official docs
- Custom NixOS distro ISO build patterns -- derived from NixOS official ISO structure; distro-specific tooling may differ
- Soundscape system architecture -- no reference implementation in the anime rice ecosystem; design is reasoned from PipeWire + mpv capabilities

---
*Research completed: 2026-04-06*
*Synthesized: 2026-04-07*
*Ready for roadmap: yes*
