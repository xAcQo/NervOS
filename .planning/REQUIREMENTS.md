# Requirements: NervOS

**Defined:** 2026-04-07
**Core Value:** A single click or hotkey transports you visually, audibly, and spatially into the world of Neon Genesis Evangelion — every pixel, sound, and font shifts to match the chosen pilot's vibe.

## v1 Requirements

### Foundation

- [ ] **FOUND-01**: NixOS unstable flake boots to a minimal working system with all inputs resolving without conflicts
- [ ] **FOUND-02**: Hyprland runs as the Wayland compositor with a working desktop session (no black screen, GPU-agnostic default config)
- [ ] **FOUND-03**: Stylix is integrated as the theming layer, driving colors and fonts across all supported components from a single base16 palette definition
- [ ] **FOUND-04**: home-manager is integrated for user-level configuration alongside system-level NixOS config
- [ ] **FOUND-05**: All flake inputs use `follows = "nixpkgs"` to prevent incompatible library versions and closure bloat

### Desktop Completeness

- [ ] **DESK-01**: Waybar status bar displays workspaces, clock, volume, network, battery — all styled with per-profile NERV/EVA CSS
- [ ] **DESK-02**: Rofi app launcher is themed per active pilot profile (colors, font, border, layout)
- [ ] **DESK-03**: Kitty terminal runs with per-profile color scheme, font (JetBrains Mono), and opacity/blur settings
- [ ] **DESK-04**: Thunar file manager is themed via Stylix GTK integration and opens correctly under Wayland/XDG
- [ ] **DESK-05**: mako notification daemon displays notifications styled per active profile (colors, font, border-radius, position)
- [ ] **DESK-06**: hyprlock screen lock activates on inactivity/Super+L with per-profile background, color scheme, and input field
- [ ] **DESK-07**: swww wallpaper daemon sets per-profile wallpaper with animated transition on profile switch
- [ ] **DESK-08**: grimblast screenshot tool is bound to PrtSc (area), Shift+PrtSc (fullscreen), copies to clipboard
- [ ] **DESK-09**: PipeWire + wireplumber provides working system audio with volume keybinds (XF86Audio*) and a Waybar volume module
- [ ] **DESK-10**: NetworkManager provides WiFi/ethernet management with nm-applet or Waybar network widget — no terminal required
- [ ] **DESK-11**: wl-clipboard + cliphist provides clipboard history accessible via a Rofi keybind (Super+V)

### Pilot Profile System (The Vibe Switcher)

- [ ] **PILOT-01**: `nervos-switcher` daemon applies a pilot profile switch at runtime via ordered reload sequence: hyprctl reload → swww wallpaper transition → Waybar CSS hot-reload → mako config reload → kitty remote color change → soundscape crossfade — all under 3 seconds
- [ ] **PILOT-02**: GTK4 "Pilot Selection" app (`nervos-select`) displays all 4 pilot profiles as cards with preview thumbnail, pilot name, unit number, and color swatch — clicking a card switches the active profile
- [ ] **PILOT-03**: Keyboard shortcut (configurable, default Super+P) opens the Pilot Selection app
- [ ] **PILOT-04**: Keyboard shortcut (configurable, default Super+Shift+P) cycles to the next pilot profile without opening the GUI
- [ ] **PILOT-05**: Active pilot profile is persisted to `~/.config/nervos/active-profile` and restored on login so the user's last chosen pilot is always remembered across reboots

### EVA Pilot Profiles — Visual Identity

Each profile is a complete aesthetic system. All 4 profiles must implement every visual layer:

- [ ] **PROF-01**: **NERV Command** profile — true black `#000000` background, NERV orange `#FF9830` accent, alert red `#FF3030` secondary, wire cyan `#20F0FF` highlight; Matisse EB display font, JetBrains Mono terminal; MAGI-inspired straight-edge window borders; tight gaps (4px); institutional/mechanical animation (sharp ease-out); NERV Command wallpapers from asset collection
- [ ] **PROF-02**: **EVA Unit-01 — Shinji** profile — dark purple `#1A0A2E` background, Unit-01 green `#4AF626` accent, deep purple `#6B21A8` secondary; organic/uncertain animation (slight overshoot); Unit-01 purple-green wallpapers; cockpit LCL amber overlay tint
- [ ] **PROF-03**: **EVA Unit-00 — Rei** profile — deep navy `#080C1A` background, Rei blue `#20F0FF` accent, pale white `#C8D8E8` secondary, muted sage `#8FB3A5` highlight; slow/melancholic animation (long fade, minimal motion); Unit-00 blue-white wallpapers; cold, sparse layout with wider gaps (12px)
- [ ] **PROF-04**: **EVA Unit-02 — Asuka** profile — near-black `#1A0000` background, Unit-02 red `#FF2020` accent, flame orange `#FF6B00` secondary; aggressive/snappy animation (fast snap-in, no easing); Unit-02 red-orange wallpapers; dense/energetic layout with tight gaps (2px)

### Soundscape System

- [ ] **SOUND-01**: `nervos-audio` service starts automatically on login and plays a looping per-profile ambient audio track (NERV: MAGI system hum; Unit-01: LCL fluid/power-up ambience; Unit-00: cold silence/minimal tone; Unit-02: reactor charge hum)
- [ ] **SOUND-02**: System notification sound plays a per-profile audio clip on each mako notification (NERV: bridge terminal ping; Unit-01: synchronization chime; Unit-00: soft tone; Unit-02: alert klaxon)
- [ ] **SOUND-03**: System event sounds play per-profile clips for: volume change (MAGI register), screenshot taken (camera shutter with EVA HUD sound), error/warning (emergency alarm)
- [ ] **SOUND-04**: Startup sound plays once when the desktop session loads (EVA startup sequence: `We are the Warriors` intro hit or NERV boot chime)
- [ ] **SOUND-05**: Profile switch triggers an audio crossfade — outgoing ambient fades out over 1.5s while incoming ambient fades in, with a brief transition sound effect (AT Field activation)
- [ ] **SOUND-06**: All sound asset paths are configurable via `~/.config/nervos/sounds/` so users can replace any sound with their own files

### Typography

- [ ] **TYPE-01**: Matisse EB (or closest open alternative: Times New Roman Condensed Bold) is configured as the display/title font and applied to Waybar labels, Rofi header, and system intertitles
- [ ] **TYPE-02**: JetBrains Mono is configured as the terminal/monospace font and applied to Kitty, any code editors, and data-readout widgets
- [ ] **TYPE-03**: Fonts are declared in Stylix so all GTK apps, terminals, and Hyprland components inherit them without per-app overrides
- [ ] **TYPE-04**: NERV Command profile applies `scaleX(0.82)` mechanical compression to Waybar title text (CSS transform) to match the EVA institutional aesthetic

### MAGI Dashboard (eww Widgets)

- [ ] **MAGI-01**: eww hexagonal widget overlay (Super+M to toggle) displays real-time system metrics styled as MAGI cores: CASPAR (CPU usage % + frequency), BALTHASAR (RAM used/total), MELCHIOR (network rx/tx rate)
- [ ] **MAGI-02**: eww widgets are themed per active pilot profile — NERV Command: orange hexagons with scanlines; Unit-01: green angular readouts; Unit-00: blue minimal circles; Unit-02: red alert-style gauges
- [ ] **MAGI-03**: eww widgets use absolute positioning and are non-interactive overlays (do not steal focus or interfere with window management)
- [ ] **MAGI-04**: eww widget layout uses Matisse EB / compressed display fonts for labels with `scaleX(0.82)` for the NERV look

### Boot Pipeline

- [ ] **BOOT-01**: GRUB bootloader displays NERV maple leaf logo, uses NervOS orange/black color scheme, shows "NervOS — Evangelion Edition" title
- [ ] **BOOT-02**: Plymouth boot splash plays an EVA-themed animation sequence (NERV logo fade-in with loading bar styled as AT Field activation progress) using the adi1090x hexagon base customized with NERV assets
- [ ] **BOOT-03**: greetd + GTK4 greeter displays an EVA-themed login screen with active-profile wallpaper as background, Matisse EB username field, NERV logo, and profile color accents
- [ ] **BOOT-04**: First-boot welcome app launches automatically on first login, presents "Welcome, Pilot — Choose Your Unit" screen with all 4 profile cards, lets user select their starting profile, then dismisses and opens the desktop

### ISO & Installation

- [ ] **ISO-01**: Bootable ISO is generated via nixos-generators targeting the `install-iso` format, defaults to booting a live NervOS desktop with NERV Command profile active
- [ ] **ISO-02**: NixOS graphical installer (nixos-anywhere or Calamares if NixOS integration is stable) allows installing NervOS to disk with minimal steps — no terminal required for basic install
- [ ] **ISO-03**: Installed system retains all NervOS theming, profiles, and sounds — first boot on real hardware looks and sounds identical to the live ISO
- [ ] **ISO-04**: ISO includes all firmware blobs (`hardware.enableAllFirmware = true`) to maximize hardware compatibility out of the box

### Keybindings

- [ ] **KEY-01**: All standard Hyprland window management keybinds work: Super+Q (close), Super+T (terminal), Super+F (fullscreen), Super+arrow (focus), Super+Shift+arrow (move), Super+1-9 (workspaces)
- [ ] **KEY-02**: Super+Space launches Rofi app launcher
- [ ] **KEY-03**: Super+P opens Pilot Selection GUI
- [ ] **KEY-04**: Super+Shift+P cycles to next pilot profile instantly (no GUI)
- [ ] **KEY-05**: Super+M toggles MAGI eww widget overlay
- [ ] **KEY-06**: Super+L locks screen with hyprlock
- [ ] **KEY-07**: Super+V opens clipboard history via Rofi
- [ ] **KEY-08**: All keybinds are documented in `~/.config/nervos/keybinds.md` and accessible from the desktop (right-click or help keybind)

---

## v2 Requirements

### Gaming Optimization

- **GAME-01**: Steam + Proton configured and working out-of-box
- **GAME-02**: GameMode integration for CPU/GPU performance during games
- **GAME-03**: MangoHud overlay for FPS and GPU temp display
- **GAME-04**: NVIDIA-specific Hyprland fixes pre-applied (explicit sync, kernel modesetting)
- **GAME-05**: EVA-themed MangoHud skin (MAGI-style HUD)

### User Theme Creation

- **CUST-01**: GUI theme editor in Vibe Switcher for creating custom profiles (palette picker, wallpaper upload, font selection, sound upload)
- **CUST-02**: Theme manifest format (TOML) so community themes can be shared as single files
- **CUST-03**: Theme import — drag a `.nervos-theme` file into the Vibe Switcher to install
- **CUST-04**: Theme preview mode — apply theme temporarily without committing

### Polish & Extras

- **POLSH-01**: Steins;Gate profile (if user demand exists — Amadeus interface aesthetic)
- **POLSH-02**: Per-profile cursor theme (crosshair for NERV, Unit colors for EVA units)
- **POLSH-03**: Per-profile icon theme (Papirus colorized to match active profile)
- **POLSH-04**: Animated/video wallpapers via mpvpaper (GPU-permitting)
- **POLSH-05**: Voice command trigger for profile switching via whisper.cpp + Vocalinux

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| Lain / Steins;Gate themes in v1 | NervOS is a dedicated Evangelion distro — other franchises dilute the identity |
| Multiple window managers (Sway, i3, XFCE) | Hyprland is the identity; multi-WM support multiplies theming complexity impossibly |
| Flatpak / Snap store | Flatpak apps ignore system GTK themes, breaking color coordination |
| AI/LLM integration | Unrelated to theming; enormous dependency; out of scope entirely |
| Animated video wallpapers in v1 | GPU-intensive, Wayland support fragile; static wallpapers with swww transitions are sufficient |
| Per-monitor different profiles | Hyprland applies config globally; immersion means one world at a time |
| Automatic time-of-day theme switching | All NervOS themes are dark; adds cron complexity for zero value |
| X11 / Xorg session | Hyprland is Wayland-native; Xwayland handles compatibility passively |
| Built-in anime streaming | Licensing nightmare; a themed browser bookmark is sufficient |
| AniList / MAL integration | This is an OS, not an anime tracker |

---

## Traceability

*Populated during roadmap creation.*

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUND-01 through FOUND-05 | Phase 1 | Pending |
| DESK-01 through DESK-11 | Phase 1-2 | Pending |
| PROF-01 through PROF-04 | Phase 2 | Pending |
| TYPE-01 through TYPE-04 | Phase 2 | Pending |
| BOOT-01 through BOOT-04 | Phase 3 | Pending |
| PILOT-01 through PILOT-05 | Phase 3 | Pending |
| SOUND-01 through SOUND-06 | Phase 3-4 | Pending |
| MAGI-01 through MAGI-04 | Phase 4 | Pending |
| KEY-01 through KEY-08 | Phase 1-2 | Pending |
| ISO-01 through ISO-04 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 54 total
- Mapped to phases: 54
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-07*
*Last updated: 2026-04-07 after initial definition*
