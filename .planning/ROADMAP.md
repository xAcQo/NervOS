# Roadmap: NervOS

## Overview

NervOS is built in 10 phases following a strict dependency chain: a working NixOS flake first, then a complete desktop shell, then the NERV Command flagship profile to prove the architecture, then the remaining three EVA unit profiles, then the soundscape system as a first-class differentiator, then the switching daemon, then the GTK4 GUI and MAGI dashboard, then the boot pipeline, and finally the installable ISO. Every phase delivers a coherent, verifiable capability -- nothing ships half-finished.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Flake Foundation** - NixOS boots to a working Hyprland desktop with Stylix and home-manager integrated
- [ ] **Phase 2: Desktop Shell** - All desktop tools installed, configured, and functional with default styling
- [ ] **Phase 3: Typography & NERV Command Profile** - First complete visual identity proves the theming architecture end-to-end
- [ ] **Phase 4: EVA Unit Profiles** - Three remaining pilot identities (Shinji, Rei, Asuka) fully implemented
- [ ] **Phase 5: Soundscape System** - Per-profile ambient audio, notification sounds, event sounds, and crossfade transitions
- [ ] **Phase 6: Profile Switching Engine** - nervos-switcher daemon applies full profile switches at runtime in under 3 seconds
- [ ] **Phase 7: Pilot Selection GUI** - GTK4 app for visual profile switching with preview cards
- [ ] **Phase 8: MAGI Dashboard** - eww hexagonal widget overlay styled per active pilot profile
- [ ] **Phase 9: Boot Pipeline** - Themed GRUB, Plymouth animation, greetd login screen, and first-boot welcome app
- [ ] **Phase 10: ISO & Installation** - Bootable ISO with graphical installer that installs a complete NervOS system

## Phase Details

### Phase 1: Flake Foundation
**Goal**: A NixOS system boots to a working Hyprland desktop session with Stylix theming and home-manager integrated -- the architectural base everything else builds on
**Depends on**: Nothing (first phase)
**Requirements**: FOUND-01, FOUND-02, FOUND-03, FOUND-04, FOUND-05
**Success Criteria** (what must be TRUE):
  1. Running `nix build` produces a working NixOS system closure without evaluation errors or infinite recursion
  2. Booting the system lands on a Hyprland desktop with a visible cursor and working mouse/keyboard (no black screen, no TTY fallback)
  3. Stylix base16 palette colors are visibly applied to GTK apps and the terminal without per-app manual overrides
  4. home-manager user config is active (dotfiles appear in ~/.config/) alongside system-level NixOS config
  5. All flake inputs resolve without conflicts and `flake.lock` pins every dependency
**Plans**: TBD

Plans:
- [ ] 01-01: Flake structure and NixOS minimal boot
- [ ] 01-02: Hyprland compositor integration
- [ ] 01-03: Stylix theming layer and home-manager integration

### Phase 2: Desktop Shell
**Goal**: Every desktop tool a user touches daily is installed, configured, and functional -- the complete working environment before any EVA theming
**Depends on**: Phase 1
**Requirements**: DESK-01, DESK-02, DESK-03, DESK-04, DESK-05, DESK-06, DESK-07, DESK-08, DESK-09, DESK-10, DESK-11, KEY-01, KEY-02, KEY-06, KEY-07
**Success Criteria** (what must be TRUE):
  1. Waybar displays workspaces, clock, volume, network, and battery along the top of the screen
  2. Super+Space opens Rofi app launcher; Super+T opens Kitty terminal; Super+Q closes windows; Super+1-9 switches workspaces; Super+L locks the screen
  3. Screenshots capture to clipboard via PrtSc (area) and Shift+PrtSc (fullscreen)
  4. Audio plays through speakers/headphones with volume adjustable via keyboard media keys; WiFi connects without opening a terminal
  5. Super+V opens clipboard history; Thunar opens and browses files; mako shows test notifications; hyprlock activates and accepts password
**Plans**: TBD

Plans:
- [ ] 02-01: Status bar, launcher, and terminal
- [ ] 02-02: File manager, notifications, and lock screen
- [ ] 02-03: Wallpaper daemon and screenshot tooling
- [ ] 02-04: Audio, network, clipboard, and window management keybinds

### Phase 3: Typography & NERV Command Profile
**Goal**: The NERV Command profile is a complete visual identity applied across every pixel -- proving the theming architecture works end-to-end before building more profiles
**Depends on**: Phase 2
**Requirements**: PROF-01, TYPE-01, TYPE-02, TYPE-03, TYPE-04
**Success Criteria** (what must be TRUE):
  1. Switching to NERV Command profile turns the desktop true black (#000000) with NERV orange (#FF9830) accents visible in Waybar, Rofi, window borders, mako notifications, and hyprlock
  2. Matisse EB (or selected display font) appears in Waybar labels and Rofi header; JetBrains Mono appears in Kitty terminal
  3. Fonts are declared once in Stylix and inherited by all GTK apps, terminals, and Hyprland components without per-app font overrides
  4. NERV Command Waybar title text shows the mechanical compressed look via CSS scaleX(0.82) transform
  5. NERV Command wallpapers from the asset collection are set via swww; window gaps are tight (4px); animations use sharp ease-out timing
**Plans**: TBD

Plans:
- [ ] 03-01: Font system (Matisse EB, JetBrains Mono, Stylix font declaration)
- [ ] 03-02: NERV Command color palette and Stylix profile definition
- [ ] 03-03: NERV Command per-component styling (Waybar CSS, Rofi, mako, hyprlock, animations, wallpapers)

### Phase 4: EVA Unit Profiles
**Goal**: All three EVA unit profiles (Shinji, Rei, Asuka) are fully implemented with distinct visual identities that feel like different worlds, not just palette swaps
**Depends on**: Phase 3
**Requirements**: PROF-02, PROF-03, PROF-04
**Success Criteria** (what must be TRUE):
  1. Unit-01 Shinji profile shows dark purple (#1A0A2E) background with green (#4AF626) accents, organic animation with slight overshoot, and LCL amber overlay tint across all components
  2. Unit-00 Rei profile shows deep navy (#080C1A) background with cyan (#20F0FF) accents, slow melancholic animations, wider gaps (12px), and cold/sparse layout
  3. Unit-02 Asuka profile shows near-black red (#1A0000) background with red (#FF2020) accents, aggressive snap-in animations, tight gaps (2px), and dense/energetic layout
  4. Each profile applies its identity consistently across Waybar, Rofi, Kitty, mako, hyprlock, swww wallpaper, and Hyprland window borders -- no component is left unthemed
**Plans**: TBD

Plans:
- [ ] 04-01: Unit-01 Shinji profile (palette, Stylix definition, per-component styling)
- [ ] 04-02: Unit-00 Rei profile (palette, Stylix definition, per-component styling)
- [ ] 04-03: Unit-02 Asuka profile (palette, Stylix definition, per-component styling)

### Phase 5: Soundscape System
**Goal**: Every profile has its own audio world -- ambient loops, notification sounds, and event sounds that shift with the visual identity
**Depends on**: Phase 4
**Requirements**: SOUND-01, SOUND-02, SOUND-03, SOUND-04, SOUND-05, SOUND-06
**Success Criteria** (what must be TRUE):
  1. Logging in plays a startup sound (EVA startup sequence) and begins a looping ambient track matching the active profile (MAGI hum for NERV, LCL ambience for Shinji, cold silence for Rei, reactor charge for Asuka)
  2. Each mako notification triggers a per-profile sound clip (bridge ping for NERV, sync chime for Shinji, soft tone for Rei, alert klaxon for Asuka)
  3. Volume change, screenshot, and error events each play a distinct per-profile audio clip
  4. Switching profiles crossfades audio -- outgoing ambient fades out over 1.5s while incoming fades in, with an AT Field transition sound
  5. Replacing any sound file in ~/.config/nervos/sounds/ with a custom file changes that sound on next trigger
**Plans**: TBD

Plans:
- [ ] 05-01: nervos-audio service and ambient loop playback
- [ ] 05-02: Notification and system event sound triggers
- [ ] 05-03: Startup sound, crossfade engine, and user-configurable sound paths

### Phase 6: Profile Switching Engine
**Goal**: The nervos-switcher daemon can transform the entire desktop from one pilot identity to another in under 3 seconds, persisting the choice across reboots
**Depends on**: Phase 5
**Requirements**: PILOT-01, PILOT-05, KEY-04
**Success Criteria** (what must be TRUE):
  1. Running `nervos-switch nerv-command` (or any profile name) transforms colors, wallpaper, fonts, sounds, and animations across all components in under 3 seconds without a NixOS rebuild
  2. The ordered reload sequence executes visibly: Hyprland reloads -> wallpaper transitions via swww -> Waybar CSS changes -> mako restyles -> Kitty colors change -> soundscape crossfades
  3. After switching profiles and rebooting, the system comes back in the last-selected profile (persisted to ~/.config/nervos/active-profile)
  4. Super+Shift+P cycles to the next profile instantly without opening any GUI
**Plans**: TBD

Plans:
- [ ] 06-01: Pre-generated profile config sets and symlink swap mechanism
- [ ] 06-02: Ordered reload sequence (hyprctl, swww, Waybar, mako, kitty, soundscape)
- [ ] 06-03: Profile persistence, restore-on-login, and cycle-next keybind

### Phase 7: Pilot Selection GUI
**Goal**: Users can switch profiles through a beautiful GTK4 app showing pilot cards with previews -- no terminal required
**Depends on**: Phase 6
**Requirements**: PILOT-02, PILOT-03, PILOT-04, KEY-03
**Success Criteria** (what must be TRUE):
  1. Super+P opens the Pilot Selection app showing all 4 profiles as visual cards with preview thumbnail, pilot name, unit number, and color swatch
  2. Clicking a profile card triggers a full profile switch (via nervos-switcher) and the app closes
  3. The currently active profile is visually indicated (highlighted card, border, or label)
  4. The app launches and renders in under 1 second; clicking a card initiates the switch immediately
**Plans**: TBD

Plans:
- [ ] 07-01: GTK4 app scaffold and Nix packaging (wrapGAppsHook4, GResource)
- [ ] 07-02: Profile card UI with previews, active indicator, and click-to-switch
- [ ] 07-03: D-Bus/socket integration with nervos-switcher and Super+P keybind

### Phase 8: MAGI Dashboard
**Goal**: A hexagonal eww widget overlay displays real-time system metrics styled as the three MAGI supercomputers, themed per active profile
**Depends on**: Phase 6
**Requirements**: MAGI-01, MAGI-02, MAGI-03, MAGI-04, KEY-05
**Success Criteria** (what must be TRUE):
  1. Super+M toggles the MAGI overlay showing three hex widgets: CASPAR (CPU % + frequency), BALTHASAR (RAM used/total), MELCHIOR (network rx/tx rate)
  2. Metrics update in real-time (at least every 2 seconds) and reflect actual system load
  3. Each pilot profile shows distinct MAGI styling: orange hexagons with scanlines (NERV), green angular readouts (Shinji), blue minimal circles (Rei), red alert gauges (Asuka)
  4. The overlay uses absolute positioning, does not steal focus, and does not interfere with window management or keybinds
  5. Widget labels use Matisse EB / compressed display fonts with scaleX(0.82) for the NERV look
**Plans**: TBD

Plans:
- [ ] 08-01: eww widget scaffold and hexagonal layout
- [ ] 08-02: System metric polling (CPU, RAM, network) and real-time display
- [ ] 08-03: Per-profile MAGI styling and Super+M toggle keybind

### Phase 9: Boot Pipeline
**Goal**: From power-on to desktop, every screen the user sees is themed -- GRUB, Plymouth, login, and first-boot welcome
**Depends on**: Phase 7
**Requirements**: BOOT-01, BOOT-02, BOOT-03, BOOT-04
**Success Criteria** (what must be TRUE):
  1. GRUB displays the NERV maple leaf logo with orange/black color scheme and "NervOS -- Evangelion Edition" title
  2. Plymouth plays an EVA-themed animation (NERV logo fade-in with AT Field loading bar) during boot
  3. greetd greeter shows an EVA-themed login screen with the active profile's wallpaper, Matisse EB username field, and NERV logo
  4. On first-ever login, a welcome app launches showing "Welcome, Pilot -- Choose Your Unit" with all 4 profile cards; selecting one sets the starting profile and opens the desktop
**Plans**: TBD

Plans:
- [ ] 09-01: GRUB theme (NERV logo, color scheme, title)
- [ ] 09-02: Plymouth boot animation (NERV logo, AT Field loading bar)
- [ ] 09-03: greetd GTK4 greeter with EVA theming
- [ ] 09-04: First-boot welcome app with profile selection

### Phase 10: ISO & Installation
**Goal**: NervOS ships as a bootable ISO that installs like any standard Linux distro -- the complete experience from download to desktop
**Depends on**: Phase 9
**Requirements**: ISO-01, ISO-02, ISO-03, ISO-04, KEY-08
**Success Criteria** (what must be TRUE):
  1. A bootable ISO can be written to USB and boots to a live NervOS desktop with NERV Command profile active
  2. The graphical installer completes a full NervOS installation to disk without requiring the user to open a terminal
  3. First boot on installed hardware looks and sounds identical to the live ISO -- all theming, profiles, sounds, and the MAGI dashboard are present
  4. The ISO includes all firmware blobs (hardware.enableAllFirmware) and boots on AMD, Intel, and NVIDIA GPU hardware without manual driver configuration
  5. All keybinds are documented in ~/.config/nervos/keybinds.md and accessible from the desktop
**Plans**: TBD

Plans:
- [ ] 10-01: ISO generation via nixos-generators (install-iso format, firmware, live desktop)
- [ ] 10-02: Graphical installer integration (Calamares or nixos-install wrapper)
- [ ] 10-03: Post-install verification and keybind documentation

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 & 8 (parallel) -> 9 -> 10

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Flake Foundation | 0/3 | Not started | - |
| 2. Desktop Shell | 0/4 | Not started | - |
| 3. Typography & NERV Command Profile | 0/3 | Not started | - |
| 4. EVA Unit Profiles | 0/3 | Not started | - |
| 5. Soundscape System | 0/3 | Not started | - |
| 6. Profile Switching Engine | 0/3 | Not started | - |
| 7. Pilot Selection GUI | 0/3 | Not started | - |
| 8. MAGI Dashboard | 0/3 | Not started | - |
| 9. Boot Pipeline | 0/4 | Not started | - |
| 10. ISO & Installation | 0/3 | Not started | - |
