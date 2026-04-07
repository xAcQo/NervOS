# Feature Research

**Domain:** Custom NixOS Linux distribution with anime aesthetic theming (NervOS)
**Researched:** 2026-04-06
**Confidence:** MEDIUM (training data only -- WebSearch/WebFetch unavailable, no live verification)

## Ecosystem Context

The "anime-themed Linux" space sits at the intersection of two communities: the NixOS/Hyprland declarative-config power-user scene and the r/unixporn aesthetic-ricing scene. Key reference points:

- **LainOS**: An Arch-based distro with Lain theming. Ships a custom openbox desktop with Lain wallpapers, terminal color schemes, and thematic startup. Shallow theming -- mostly wallpapers and color palette, no soundscape, no theme switching, no GUI config tool. Feels like a rice packaged as an ISO.
- **r/unixporn top Hyprland rices**: The best ones include: coordinated Waybar + Rofi + terminal + GTK theming, custom Hyprland animations (bezier curves, fade effects), matching wallpapers via swww with smooth transitions, notification styling (mako/dunst), lock screen theming (hyprlock), and sometimes custom fetch scripts. The gap: these are always one-theme setups. Nobody ships a *switching* system.
- **NixOS dotfile repos** (e.g., Misterio77/nix-colors, danth/stylix users): Declarative theming through Nix is well-established. Stylix in particular generates base16 color schemes that propagate to GTK, terminal, Waybar, Hyprland borders, etc. But switching themes requires a `nixos-rebuild` -- there is no live-switching built into Stylix itself.
- **Hyprland ecosystem**: Mature Wayland compositor with extensive animation controls, IPC for runtime config changes (`hyprctl`), plugin system, and strong community. Hyprland supports runtime keyword changes via `hyprctl keyword`, which enables live color/gap/border changes without restart.

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete or "broken distro."

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Working Hyprland desktop on boot** | Every custom distro boots to a usable desktop. If Hyprland crashes or shows a black screen, it's DOA | HIGH | Must handle GPU driver detection (NVIDIA is notoriously painful on Wayland). Needs fallback or clear error messaging |
| **Coordinated color scheme across all apps** | r/unixporn standard -- mismatched colors between terminal/bar/menus signals amateur hour | MEDIUM | Stylix handles this declaratively. Must cover: Hyprland borders, Waybar, Rofi, terminal (foot/kitty), GTK apps, dunst/mako notifications |
| **Themed Waybar (status bar)** | Every Hyprland rice has a styled Waybar. Unstyled Waybar = broken | MEDIUM | Per-theme Waybar CSS. Include workspaces, clock, volume, network, battery modules |
| **Themed Rofi (app launcher)** | Standard Hyprland launcher. Must match the vibe | LOW | Rofi theming is CSS-like, well-documented. Per-theme rofi config |
| **Themed terminal emulator** | Users will open terminals constantly. Must feel "in-world" | LOW | Foot or Kitty with per-theme color scheme + font. Stylix propagates this |
| **Wallpaper management** | Every rice has wallpapers. Static wallpaper per theme minimum | LOW | Use swww for animated transitions between wallpapers when switching themes |
| **Lock screen theming** | Locking the screen and seeing a generic lock screen breaks immersion | MEDIUM | hyprlock with per-theme background, colors, and input field styling |
| **Themed file manager** | Users expect to browse files. Unstyled file manager looks jarring | LOW | Thunar or Nautilus with GTK theming via Stylix. Does not need custom file manager |
| **Notification system** | Desktop notifications must exist and be themed | LOW | mako or dunst with per-theme colors, font, positioning |
| **Screenshot tool** | Users expect to screenshot their rice (literally the community's main activity) | LOW | grimblast or grim + slurp. Bind to PrtSc. Include copy-to-clipboard |
| **Audio controls** | Volume up/down, mute must work out of box | LOW | pipewire + wireplumber, keybinds in Hyprland config, Waybar volume module |
| **Network management** | WiFi must work. No terminal-only networking | LOW | NetworkManager + nm-applet or Waybar network module |
| **Bootable ISO that installs** | It is a distro. Must install like one | HIGH | NixOS has nixos-generators for ISO creation. Calamares is the standard graphical installer, but NixOS integration is non-trivial. Many NixOS distros use a custom install script instead |
| **Readable default fonts** | System font must be legible, not just aesthetic | LOW | Stylix font config. Need a readable mono font (terminal) + UI font (GTK/Waybar). Theme fonts can be stylistic but must be readable |
| **Basic keybindings that work** | Window management, app launching, workspace switching | LOW | Standard Hyprland keybind config. Must be documented/discoverable |
| **Clipboard manager** | Copy-paste must work across Wayland apps | LOW | wl-clipboard + cliphist. Invisible but essential |

### Differentiators (Competitive Advantage)

Features that set NervOS apart from "just another rice." This is where anime-themed becomes anime-*immersive*.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Live theme switching via Vibe Switcher GUI** | THE killer feature. No other distro or rice offers one-click full-environment transformation. LainOS is one theme forever. r/unixporn rices are static. NervOS lets you *move between worlds* | HIGH | GTK4 app that triggers: Stylix palette swap, swww wallpaper transition, Hyprland border/gap/animation changes, Waybar CSS swap, notification style swap, sound theme swap, lock screen swap. Must use hyprctl for runtime Hyprland changes + hot-reload for other components. Stylix itself does NOT support runtime switching -- this requires an overlay system |
| **Per-theme soundscapes** | Sound is 50% of immersion and 0% of existing rices. An EVA theme without the NERV alert klaxon or the hum of MAGI systems is just an orange wallpaper | HIGH | Ambient background audio (looped), system notification sounds (per event: notification, error, volume change, screenshot), startup sound. Needs a sound daemon -- likely a lightweight custom service using pipewire or mpv for ambient + libcanberra or custom event sounds |
| **Per-theme Hyprland animations** | Different vibes need different motion. EVA: sharp mechanical snaps. Lain: glitchy digital dissolves. Steins;Gate: CRT flicker fades | MEDIUM | Hyprland animation bezier curves and durations are runtime-configurable via hyprctl. Per-theme animation presets stored in theme config |
| **Themed boot sequence (Plymouth)** | First impression. An EVA-themed boot animation (NERV logo sequence, MAGI boot text) makes the experience feel *complete* from power-on | MEDIUM | Plymouth theme with per-active-theme splash. NixOS supports Plymouth declaratively. Creating custom Plymouth themes requires scripting in Plymouth's script language |
| **In-world system monitors** | Instead of generic htop, show MAGI-styled system status (CPU = CASPAR, RAM = BALTHASAR, etc. for EVA). Lain: Wired connection status. Steins;Gate: divergence meter | HIGH | Custom conky/eww widgets per theme. eww (ElKowar's Wacky Widgets) is the standard for custom Hyprland overlays -- Wayland-native, scriptable, supports complex layouts. Per-theme eww configs |
| **Theme-specific cursor and icon packs** | Deep theming. Cursor changes to match (crosshair for EVA, digital cursor for Lain) | MEDIUM | Hyprcursor for Hyprland-native cursors. Icon themes via Stylix/GTK. Must be bundled per theme |
| **Keyboard shortcut theme cycling** | Super+Space (or configurable) to cycle themes without opening GUI. Power users want this | LOW | Trigger the same backend as Vibe Switcher via CLI. Hyprland keybind -> shell command |
| **Wallpaper transitions with swww** | Not just "set wallpaper" but animated transition (fade, wipe, grow) that matches the vibe when switching | LOW | swww supports transition types: fade, wipe, grow, wave, outer. Different transition per theme-switch |
| **User theme creation workflow** | Users can create their own anime themes (provide palette, wallpapers, sounds, font, and the system generates a full theme) | HIGH | Needs: theme manifest format (TOML/JSON), Vibe Switcher GUI for theme creation, validation that all required assets exist, preview capability |
| **Themed GRUB/systemd-boot** | Even the bootloader matches. NERV logo at boot menu | LOW | NixOS supports custom GRUB themes declaratively. systemd-boot is simpler but less customizable |
| **First-boot welcome app** | Guided intro: "Welcome to NervOS. Choose your first vibe." Theme preview + selection + quick config (timezone, user) | MEDIUM | GTK4 app shown on first login. Sets initial theme, explains keybinds, offers tour. Prevents "I booted and don't know what to do" |
| **Login manager (greeter) theming** | The login screen should be in-world too. No generic SDDM | MEDIUM | greetd + gtkgreet or ReGreet (GTK4 greeter for greetd). Per-theme greeter background and colors. greetd is the standard for Hyprland setups |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems in v1. Deliberately do NOT build these.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **Gaming optimization (GameMode, Steam, GPU perf)** | "I want to game on my anime OS" | Massive scope explosion. GPU drivers, Vulkan, gamescope, Steam Flatpak, MangoHud, etc. Each has Wayland-specific issues. Doubles the QA surface | Ship a working desktop first. Gaming milestone later. Users can install Steam themselves via nix |
| **Multiple window managers (Sway, i3, XFCE fallback)** | "What if I don't like Hyprland?" | Theming must work identically across WMs -- impossible without N x M config complexity. Sway has different IPC, different animation model, different config format | Hyprland only. It is the identity of the distro. Users who want Sway can use vanilla NixOS |
| **X11 / Xwayland-heavy compatibility layer** | "Some apps need X11" | Xwayland comes with Hyprland by default for compatibility. But actively optimizing for X11 apps (electron flags, X11-specific theming) is a rabbit hole | Let Xwayland handle it passively. Document known issues. Do not invest engineering time |
| **AI/LLM integration (chat assistant, voice commands)** | Trendy feature | Enormous dependency (local LLM = GPU memory, API = cost/privacy). Zero relation to theming. Distracts from core value | Out of scope entirely. Users can install whatever they want |
| **Tiling layout presets per-app** | "Auto-tile my terminal + browser + music player" | Hyprland window rules exist but per-app tiling is fragile (app class names change, multi-monitor is complex). High maintenance | Ship sensible default Hyprland window rules. Let users customize via config. Do not build a GUI for this |
| **Built-in anime content (streaming, AniList, MAL)** | "It's an anime OS, it should play anime" | Licensing nightmare. Bundling streaming apps = maintenance burden. AniList integration is a webapp, not an OS feature | Include a themed Firefox/Librewolf with bookmarks to common anime sites. That is sufficient |
| **Flatpak/Snap store integration** | "I need an app store" | NixOS has its own package manager with 100k+ packages. Adding Flatpak creates theming inconsistency (Flatpak apps ignore system GTK themes) and packaging confusion | Use Nix packages. Document how to search/install. Flatpak breaks theming consistency |
| **Real-time wallpaper engine (video/animated wallpapers)** | "I want my wallpaper to move like Wallpaper Engine" | GPU-intensive, battery-draining, complex to implement on Wayland. mpvpaper exists but is fragile and resource-heavy | Static wallpapers with smooth swww transitions between them. Maybe animated wallpapers in v2 if demand exists |
| **Per-monitor different themes** | "Left monitor EVA, right monitor Lain" | Hyprland applies config globally. Waybar can be per-monitor but colors/fonts/borders are system-wide. Implementing this doubles all theme logic | One theme at a time, system-wide. This is simpler, more immersive, and actually how "being in a world" works |
| **Automatic theme scheduling (time-of-day switching)** | "Dark theme at night, light during day" | All NervOS themes are dark. This feature implies light themes exist. Also adds cron/timer complexity for low value | Defer entirely. If users want it later, it is a simple cron + theme-switch-CLI addition |

## Feature Dependencies

```
[Stylix base theming]
    ├──requires──> [NixOS flake structure]
    └──enables──> [Coordinated colors across apps]
                      ├──> [Waybar theming]
                      ├──> [Rofi theming]
                      ├──> [Terminal theming]
                      ├──> [GTK app theming]
                      ├──> [Notification theming]
                      └──> [Lock screen theming]

[Hyprland base config]
    ├──requires──> [NixOS flake structure]
    ├──enables──> [Keybindings]
    ├──enables──> [Per-theme animations]
    └──enables──> [Window rules]

[Single working theme (EVA)]
    ├──requires──> [Stylix base theming]
    ├──requires──> [Hyprland base config]
    ├──requires──> [All "coordinated colors" items above]
    └──requires──> [Wallpaper management (swww)]

[Theme switching runtime layer]
    ├──requires──> [Single working theme (EVA)]
    ├──requires──> [Second theme (Lain) to switch between]
    └──enables──> [Vibe Switcher GUI]
                      └──enables──> [User theme creation]

[Soundscape system]
    ├──requires──> [pipewire audio working]
    └──enhances──> [Single working theme (EVA)]

[Bootable ISO]
    ├──requires──> [NixOS flake structure]
    ├──requires──> [Working desktop (all table stakes)]
    └──enables──> [First-boot welcome app]

[Plymouth boot theme]
    ├──independent (NixOS declarative Plymouth config)
    └──enhances──> [Bootable ISO experience]

[Greeter theming (greetd)]
    ├──requires──> [Stylix base theming]
    └──enhances──> [Bootable ISO experience]

[eww in-world widgets]
    ├──requires──> [Single working theme (EVA)]
    └──enhances──> [Theme immersion]
```

### Dependency Notes

- **Stylix base theming requires NixOS flake structure:** Stylix is consumed as a flake input. The entire theme system is built on this foundation.
- **Theme switching runtime layer requires at least two themes:** You cannot demonstrate or test switching with only one theme. EVA must be complete first, then Lain, before the switching system can be validated.
- **Vibe Switcher GUI requires the runtime switching layer:** The GUI is a frontend to the switching mechanism. Build the mechanism (CLI-driven) first, then wrap it in GTK4.
- **Soundscape enhances but does not block themes:** A theme can ship without sounds initially. Sound is additive immersion, not structural.
- **Bootable ISO requires all table stakes working:** Do not build the ISO until the desktop experience is stable. ISO debugging is painful -- fix everything in a VM/local build first.

## MVP Definition

### Launch With (v1)

Minimum viable product -- what is needed to validate the "immersive anime OS" concept.

- [x] **NixOS flake with Hyprland + Stylix** -- foundation for everything
- [ ] **EVA theme fully implemented** -- Waybar, Rofi, terminal, GTK, notifications, lock screen, wallpapers, borders, animations. This is the flagship
- [ ] **Lain theme fully implemented** -- proves the system supports multiple themes, not hardcoded for EVA
- [ ] **Runtime theme switching (CLI)** -- `nervos-switch eva` / `nervos-switch lain` applies all changes live via hyprctl + swww + config reloads
- [ ] **Vibe Switcher GTK4 GUI** -- wraps the CLI in a visual interface with theme previews
- [ ] **Soundscape system (EVA + Lain)** -- ambient audio + notification sounds per theme. This is what separates NervOS from a dotfile repo
- [ ] **Bootable ISO** -- installable on real hardware. Calamares or custom script
- [ ] **Themed GRUB + Plymouth** -- boot experience matches the active theme
- [ ] **Themed greetd greeter** -- login screen matches the active theme
- [ ] **Keyboard shortcut for theme cycling** -- Super+Space or similar
- [ ] **All table stakes from above** -- clipboard, screenshots, audio, network, file manager

### Add After Validation (v1.x)

Features to add once core is working and early users provide feedback.

- [ ] **Steins;Gate theme** -- third theme, validates theme extensibility
- [ ] **User theme creation via GUI** -- trigger: users asking "how do I make my own theme?"
- [ ] **eww in-world widgets** -- MAGI system monitors for EVA, Wired display for Lain
- [ ] **Per-theme cursor + icon packs** -- deeper visual polish
- [ ] **First-boot welcome/onboarding app** -- trigger: user confusion reports during install

### Future Consideration (v2+)

Features to defer until the core experience is validated and community exists.

- [ ] **Gaming optimization milestone** -- large scope, separate effort
- [ ] **Additional community themes** -- once theme format is stable
- [ ] **Animated/video wallpapers** -- GPU-intensive, niche demand
- [ ] **Theme marketplace/sharing** -- requires community infrastructure
- [ ] **Voice command triggers** -- gimmick until core is rock-solid

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| NixOS flake + Hyprland + Stylix foundation | HIGH | HIGH | P1 |
| EVA theme (complete) | HIGH | HIGH | P1 |
| Lain theme (complete) | HIGH | MEDIUM | P1 |
| Runtime theme switching (CLI) | HIGH | HIGH | P1 |
| Vibe Switcher GTK4 GUI | HIGH | HIGH | P1 |
| Soundscape system | HIGH | MEDIUM | P1 |
| Bootable ISO | HIGH | HIGH | P1 |
| Themed GRUB + Plymouth | MEDIUM | LOW | P1 |
| Themed greetd greeter | MEDIUM | MEDIUM | P1 |
| Keybind theme cycling | MEDIUM | LOW | P1 |
| All table-stakes features | HIGH | MEDIUM | P1 |
| Steins;Gate theme | MEDIUM | MEDIUM | P2 |
| eww in-world widgets | HIGH | HIGH | P2 |
| User theme creation GUI | MEDIUM | HIGH | P2 |
| Per-theme cursors + icons | LOW | MEDIUM | P2 |
| First-boot welcome app | MEDIUM | MEDIUM | P2 |
| Animated wallpapers | LOW | HIGH | P3 |
| Gaming optimization | MEDIUM | HIGH | P3 |
| Theme marketplace | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for launch -- without these, NervOS is not NervOS
- P2: Should have, add after core validated
- P3: Nice to have, future milestones

## Competitor Feature Analysis

| Feature | LainOS | Top r/unixporn Hyprland Rices | NervOS Approach |
|---------|--------|-------------------------------|-----------------|
| Themed desktop | Single Lain theme, openbox-based, X11 | Single theme, Hyprland, manually configured | Multiple themes, Hyprland, declaratively managed via Stylix + flakes |
| Theme switching | None | None (rebuild config manually) | One-click GUI + keyboard shortcut, live switching |
| Soundscape | None | None | Per-theme ambient audio + event sounds |
| Boot theming | Basic | N/A (not distros) | Themed GRUB + Plymouth + greeter, all matching active theme |
| Installation | ISO with basic installer | N/A (dotfile repos, not distros) | Bootable ISO with graphical installer |
| Customization | Edit config files | Edit config files | GUI for theme switching + Nix config for deep customization |
| Animation theming | Basic openbox animations | Sometimes custom Hyprland beziers | Per-theme animation presets (sharp for EVA, glitchy for Lain) |
| Community/sharing | Small community | Reddit posts of individual setups | Theme format standard enabling community theme packs |
| Widget overlays | conky (basic) | eww or ags (advanced) | eww per-theme in-world widgets (MAGI for EVA, etc.) |
| Color coordination | Partial (terminal + wallpaper) | Full (all components match) | Full via Stylix (single palette drives everything) |

### What Makes the Best Rices Feel Immersive (vs Wallpaper Swap)

Analysis of what separates a "wow" r/unixporn post from a generic themed desktop:

1. **Every pixel matches.** The Waybar, terminal prompt, Rofi, notification popups, file manager sidebar, and even the fetch script output all use the same palette. A single unstyled element breaks the illusion.

2. **Custom animations reinforce the mood.** The best Hyprland rices use bezier curves that *feel* like the aesthetic. Snappy mechanical animations for cyberpunk. Slow dreamy fades for lo-fi. This is underexploited -- most rices use default animations.

3. **Typography is intentional.** Monospace fonts in terminals feel "hacker." A specific display font for the bar feels "designed." Mixing too many fonts feels chaotic. The best rices pick 2-3 fonts max.

4. **Negative space and gaps are designed.** Window gaps, bar padding, border width -- these affect the feel enormously. Tight gaps feel dense/serious. Wide gaps feel airy/minimal. Per-theme gap/padding values are trivial to implement but rarely done.

5. **The bar tells a story.** Generic Waybar modules (CPU%, RAM%) feel utilitarian. The best rices customize module labels, icons, and formatting to match the aesthetic (e.g., using kanji, custom separator glyphs, anime-specific iconography).

6. **Sound is completely absent from all rices.** This is the single biggest gap in the entire ecosystem. No one does themed sounds because it requires a sound daemon, event hooks, and audio management -- it is OS-level work, not dotfile work. This is NervOS's strongest differentiator.

7. **Consistency across states.** Lock screen, logout screen, boot screen, app launcher -- if ANY of these break the theme, the immersion fractures. The best desktop rices ignore boot/login because they are dotfile repos, not distros. NervOS can own the full boot-to-desktop pipeline.

## The Immersion Gap: What NervOS Must Get Right

The difference between "anime wallpaper on Linux" and "feeling inside NERV HQ" comes down to:

| Layer | Wallpaper Swap | True Immersion |
|-------|---------------|----------------|
| Colors | Changed terminal colors | Every UI element, border, shadow, highlight uses the palette |
| Wallpaper | Set one wallpaper | Wallpaper + lock screen + greeter + boot splash all coordinated |
| Sound | Silent | Ambient audio loop + themed notification sounds + startup sound |
| Typography | Default system font | Intentional display font + mono font matched to the aesthetic |
| Motion | Default animations | Animation timing/easing matched to the mood (mechanical, digital, organic) |
| Widgets | None | In-world system monitors styled as MAGI terminals or divergence meters |
| Boot sequence | Default GRUB + Plymouth | Themed bootloader + Plymouth + greeter, seamless from power-on |
| Interaction | Same keybinds | Themed launcher, themed app list, themed context menus |

NervOS needs to nail at least: colors, wallpaper, sound, typography, and boot sequence in v1. Motion and widgets can be v1.x polish.

## Sources

- Training data knowledge of: NixOS flake ecosystem, Stylix (danth/stylix), Hyprland configuration and IPC, swww wallpaper daemon, eww widgets, LainOS project, r/unixporn community patterns, Plymouth theming, greetd/gtkgreet, Rofi theming, Waybar configuration, NixOS ISO generation (nixos-generators)
- **Confidence note:** All findings are MEDIUM confidence (training data only). WebSearch and WebFetch were unavailable during this research session. Key claims to verify against current docs: Stylix runtime switching limitations, Hyprland hyprctl keyword capabilities, swww transition types, Plymouth NixOS integration, greetd Hyprland compatibility

---
*Feature research for: NervOS (anime-themed NixOS distribution)*
*Researched: 2026-04-06*
