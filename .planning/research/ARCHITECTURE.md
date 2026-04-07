# Architecture Research

**Domain:** NixOS-based custom Linux distribution with real-time theme switching
**Researched:** 2026-04-06
**Confidence:** MEDIUM (training data only -- WebSearch/WebFetch/Context7 unavailable)

## The Critical Architecture Decision: Runtime vs Rebuild

This is the single most important architectural question for NervOS. The answer is **hybrid**: use Stylix/NixOS rebuild for generating theme assets at build time, but apply themes at runtime by swapping pre-generated config files and reloading applications.

### Why Not Pure NixOS Rebuild?

A `nixos-rebuild switch` or `home-manager switch` takes 10-60 seconds depending on system speed. Users expect a theme switch to feel instant (under 1 second for visual change, under 3 seconds for full propagation). Rebuilding the entire NixOS generation for a color change is architecturally wrong for a "vibe switcher."

### Why Not Pure Runtime Config Swap?

Pure runtime config loses NixOS's reproducibility guarantees. Dotfiles scattered around `~/.config` become the source of truth instead of the Nix flake. This defeats the purpose of using NixOS.

### The Hybrid Approach (Recommended)

**Build time (Nix):** Pre-generate ALL theme variants as Nix derivations. Each theme produces a complete set of config files: Hyprland config, waybar CSS/config, rofi theme, GTK settings, terminal config, etc. These are built once during `nixos-rebuild` or ISO build.

**Runtime (Vibe Switcher):** The switcher symlinks or copies the pre-built config set for the chosen theme into the active locations, then sends reload signals to each application.

**Confidence:** MEDIUM -- this hybrid pattern is used by projects like ags/Hyprland rice setups, but I cannot verify current Stylix support for multi-theme pre-generation without live docs.

```
Build Time (Nix Evaluation)                Runtime (Vibe Switcher)
┌──────────────────────────┐              ┌────────────────────────────┐
│ flake.nix evaluates ALL  │              │ User clicks "EVA" in GUI   │
│ theme definitions         │              │         │                  │
│         │                 │              │         v                  │
│         v                 │              │ Switcher reads theme index │
│ Stylix generates base16  │              │         │                  │
│ colors per theme          │   builds     │         v                  │
│         │                 │  ────────>   │ Symlink/copy pre-built     │
│         v                 │  all themes  │ configs into active paths  │
│ home-manager templates    │  to store    │         │                  │
│ config files per theme    │              │         v                  │
│         │                 │              │ Send reload signals:       │
│         v                 │              │  - hyprctl reload          │
│ /nix/store/...theme-eva/  │              │  - kill -SIGUSR2 waybar    │
│ /nix/store/...theme-lain/ │              │  - gsettings set ...       │
│ /nix/store/...theme-sg/   │              │  - swww img <wallpaper>    │
└──────────────────────────┘              └────────────────────────────┘
```

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE LAYER                          │
│  ┌──────────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────┐   │
│  │ Vibe Switcher│  │ Hyprland │  │  Waybar  │  │  Rofi/Wofi    │   │
│  │   (GTK4)     │  │   (WM)   │  │  (Bar)   │  │  (Launcher)   │   │
│  └──────┬───────┘  └────┬─────┘  └────┬─────┘  └──────┬────────┘   │
│         │               │             │               │             │
├─────────┴───────────────┴─────────────┴───────────────┴─────────────┤
│                     THEME RUNTIME LAYER                              │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │                   nervos-switcher daemon                      │    │
│  │  Manages: symlinks, reload signals, wallpaper, sounds        │    │
│  └──────────────────────────┬───────────────────────────────────┘    │
│                             │                                        │
├─────────────────────────────┴────────────────────────────────────────┤
│                     THEME ASSET LAYER (pre-built)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐    │
│  │ EVA      │  │ Lain     │  │ Steins;  │  │ User Custom      │    │
│  │ configs  │  │ configs  │  │ Gate cfg │  │ themes           │    │
│  │ + assets │  │ + assets │  │ + assets │  │ + assets         │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘    │
│                   (all in /nix/store or ~/.local/share/nervos)       │
├──────────────────────────────────────────────────────────────────────┤
│                     NIX BUILD LAYER                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐    │
│  │ flake.nix│  │ Stylix   │  │ home-    │  │ NixOS modules    │    │
│  │ (root)   │  │ (colors) │  │ manager  │  │ (system config)  │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **flake.nix** | Root entry point. Defines inputs (nixpkgs, home-manager, stylix, hyprland), outputs (nixosConfigurations, ISO, packages) | All Nix modules |
| **NixOS modules** | System-level config: kernel, bootloader, display manager, Hyprland enable, audio (pipewire), networking | flake.nix, home-manager |
| **home-manager modules** | User-level config: Hyprland settings, waybar, rofi, terminal, GTK, shell, fonts | Stylix, NixOS modules |
| **Stylix module** | Generates base16 color scheme from image/palette, applies to all home-manager targets | home-manager, theme definitions |
| **Theme definitions** | Nix attribute sets defining: base16 colors, wallpaper path, font family, sound paths, custom overrides | Stylix, asset layer |
| **nervos-switcher (daemon)** | Runtime process that swaps active theme configs, sends reload signals, manages wallpaper/sound transitions | Vibe Switcher GUI, all desktop apps |
| **Vibe Switcher (GTK4 GUI)** | User-facing theme picker. Shows previews, triggers switches, manages custom theme creation | nervos-switcher daemon |
| **Theme asset packages** | Nix derivations containing wallpapers, fonts, sounds per theme | Nix store, nervos-switcher |
| **ISO builder** | Nix expression producing bootable ISO with all themes pre-built, installer included | flake.nix, all modules |

## Recommended Flake Structure

```
nervos/
├── flake.nix                    # Root: inputs, outputs, nixosConfigurations
├── flake.lock                   # Pinned dependency versions
│
├── hosts/
│   ├── default/                 # Default NervOS host configuration
│   │   ├── default.nix          # Hardware-agnostic system config
│   │   ├── hardware.nix         # Hardware-specific (generated per-machine)
│   │   └── disk-config.nix      # Disko partitioning (for installer)
│   └── iso/                     # ISO-specific host overrides
│       └── default.nix          # Live environment config
│
├── modules/
│   ├── nixos/                   # System-level NixOS modules
│   │   ├── core.nix             # Base system: boot, networking, locale
│   │   ├── hyprland.nix         # Hyprland enable + system deps
│   │   ├── audio.nix            # Pipewire + sound system
│   │   ├── display-manager.nix  # greetd/tuigreet or SDDM
│   │   └── fonts.nix            # System-wide font packages
│   │
│   └── home/                    # home-manager modules
│       ├── hyprland.nix         # Hyprland user config (keybinds, rules)
│       ├── waybar.nix           # Waybar config + per-theme style
│       ├── rofi.nix             # Rofi/wofi launcher config
│       ├── terminal.nix         # Kitty/Alacritty/foot config
│       ├── gtk.nix              # GTK2/3/4 theming
│       ├── shell.nix            # Zsh/fish + starship prompt
│       └── vibe-switcher.nix    # Install + configure the switcher app
│
├── themes/
│   ├── default.nix              # Theme type definition + loader
│   ├── eva/
│   │   ├── default.nix          # EVA theme definition (colors, fonts, overrides)
│   │   ├── wallpapers/          # Wallpaper images
│   │   ├── sounds/              # Notification/ambient sounds
│   │   └── extras/              # Theme-specific assets (boot splash, etc.)
│   ├── lain/
│   │   ├── default.nix
│   │   ├── wallpapers/
│   │   └── sounds/
│   └── steins-gate/
│       ├── default.nix
│       ├── wallpapers/
│       └── sounds/
│
├── packages/                    # Custom Nix packages
│   ├── vibe-switcher/           # The GTK4 app package
│   │   ├── default.nix          # Nix build expression
│   │   └── src/                 # Source code (or reference to separate repo)
│   └── nervos-switcher/         # The switching daemon
│       ├── default.nix
│       └── src/
│
├── overlays/                    # Nixpkgs overlays
│   └── default.nix              # Custom package overrides
│
├── lib/                         # Shared Nix helper functions
│   ├── theme.nix                # mkTheme function, theme schema validation
│   └── utils.nix                # Shared utilities
│
└── iso/                         # ISO build configuration
    ├── default.nix              # ISO build expression
    └── installer/               # Installer scripts/config
```

### Structure Rationale

- **hosts/**: Separates machine-specific config from reusable modules. The ISO host is a variant of the default host with live environment tweaks.
- **modules/nixos/ vs modules/home/**: Clean split between system-level (requires root/rebuild) and user-level (home-manager, can be switched faster) configuration.
- **themes/**: Each theme is a self-contained directory with a Nix expression + assets. This is the key organizational unit -- adding a theme means adding a folder.
- **packages/**: Custom applications (Vibe Switcher, nervos-switcher daemon) are proper Nix packages, buildable independently.
- **lib/**: Shared functions like `mkTheme` enforce consistent theme structure across all themes.

## Data Flow: Theme Switch Propagation

This is the most critical data flow in the entire system. Here is exactly what happens when a user clicks "EVA" in the Vibe Switcher.

### Full Theme Switch Sequence

```
User clicks "EVA" in Vibe Switcher GUI
    │
    v
Vibe Switcher sends D-Bus message (or Unix socket call)
to nervos-switcher daemon: { action: "switch", theme: "eva" }
    │
    v
nervos-switcher daemon:
    │
    ├─1─> Read theme manifest from /nix/store/.../nervos-theme-eva/manifest.json
    │     (contains paths to all config files and assets)
    │
    ├─2─> Atomically swap symlinks:
    │     ~/.config/hypr/hyprland.conf    -> /nix/store/.../theme-eva/hyprland.conf
    │     ~/.config/waybar/style.css      -> /nix/store/.../theme-eva/waybar-style.css
    │     ~/.config/waybar/config.jsonc   -> /nix/store/.../theme-eva/waybar-config.jsonc
    │     ~/.config/rofi/theme.rasi       -> /nix/store/.../theme-eva/rofi-theme.rasi
    │     ~/.config/kitty/current-theme.conf -> /nix/store/.../theme-eva/kitty.conf
    │     ~/.config/gtk-3.0/settings.ini  -> /nix/store/.../theme-eva/gtk3-settings.ini
    │     ~/.config/gtk-4.0/settings.ini  -> /nix/store/.../theme-eva/gtk4-settings.ini
    │
    ├─3─> Send reload signals (parallel):
    │     ├── hyprctl reload
    │     ├── pkill -SIGUSR2 waybar  (waybar reloads CSS on SIGUSR2)
    │     ├── swww img --transition-type grow /nix/store/.../theme-eva/wallpaper.png
    │     ├── gsettings set org.gnome.desktop.interface gtk-theme "..."
    │     ├── gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    │     └── Send kitty remote control: kitty @ set-colors --all <theme-colors>
    │
    ├─4─> Audio transition:
    │     ├── Fade out current ambient sound
    │     ├── Start new ambient sound (via mpv/pw-play)
    │     └── Switch notification sound set
    │
    └─5─> Write state file: ~/.local/state/nervos/current-theme = "eva"
          (persists across reboots, nervos-switcher reads on startup)
```

### Application-Specific Reload Mechanisms

| Application | Reload Method | Latency | Notes |
|-------------|---------------|---------|-------|
| Hyprland (borders, gaps, animations) | `hyprctl reload` | <100ms | Reads hyprland.conf on reload |
| Hyprland (wallpaper) | `swww img` with transition | 200-500ms | swww daemon must be running; supports animated transitions |
| Waybar | `pkill -SIGUSR2 waybar` or restart | <200ms | SIGUSR2 reloads CSS; full restart needed for config.jsonc changes |
| Rofi | No reload needed | 0ms | Reads theme file on each launch |
| Kitty terminal | `kitty @ set-colors` remote control | <100ms | Requires remote control enabled; affects open windows |
| Foot terminal | Config file reload (SIGUSR1) | <100ms | Alternative: foot reloads on SIGHUP |
| GTK apps | `gsettings` + may need app restart | Varies | Running GTK3 apps may need restart; GTK4 apps respond to gsettings changes |
| Cursor theme | `gsettings` + Hyprland reload | <100ms | `hyprctl setcursor` for immediate Hyprland change |

**Confidence:** MEDIUM -- reload signals are well-documented for Hyprland/waybar/kitty. The exact signal for waybar CSS-only reload (SIGUSR2) needs validation.

## Theme Data Model

A "theme" in NervOS is a Nix attribute set conforming to a schema. This is the data model.

```nix
# lib/theme.nix
{ lib }:
{
  mkTheme = { name, meta, colors, fonts, wallpaper, sounds ? {}, overrides ? {} }:
  {
    inherit name;

    # Metadata
    meta = {
      displayName = meta.displayName;          # "Neon Genesis Evangelion"
      description = meta.description;          # "NERV HQ Terminal aesthetic"
      author = meta.author or "NervOS";
      version = meta.version or "1.0";
      preview = meta.preview or null;          # Path to preview image for GUI
    };

    # Base16 color scheme (Stylix input)
    colors = {
      base00 = colors.base00;  # Default Background       (EVA: "0d0d0d")
      base01 = colors.base01;  # Lighter Background        (EVA: "1a1a2e")
      base02 = colors.base02;  # Selection Background       (EVA: "2d1b1b")
      base03 = colors.base03;  # Comments, Invisibles       (EVA: "4a3030")
      base04 = colors.base04;  # Dark Foreground            (EVA: "8b6914")
      base05 = colors.base05;  # Default Foreground         (EVA: "d4a017")
      base06 = colors.base06;  # Light Foreground           (EVA: "e8c547")
      base07 = colors.base07;  # Lightest Foreground        (EVA: "f5e6a3")
      base08 = colors.base08;  # Red / Error                (EVA: "cc2200")
      base09 = colors.base09;  # Orange                     (EVA: "e07000")
      base0A = colors.base0A;  # Yellow                     (EVA: "d4a017")
      base0B = colors.base0B;  # Green / Success            (EVA: "00cc44")
      base0C = colors.base0C;  # Cyan                       (EVA: "1abc9c")
      base0D = colors.base0D;  # Blue / Primary             (EVA: "d47500")
      base0E = colors.base0E;  # Purple / Accent            (EVA: "8b0000")
      base0F = colors.base0F;  # Dark Accent                (EVA: "6b0000")
    };

    # Font configuration
    fonts = {
      monospace = {
        package = fonts.monospace.package;    # e.g. pkgs.nerdfonts
        name = fonts.monospace.name;          # e.g. "JetBrainsMono Nerd Font"
      };
      sansSerif = {
        package = fonts.sansSerif.package;
        name = fonts.sansSerif.name;
      };
      serif = fonts.serif or fonts.sansSerif;
      sizes = {
        terminal = fonts.sizes.terminal or 12;
        desktop = fonts.sizes.desktop or 11;
        applications = fonts.sizes.applications or 11;
      };
    };

    # Wallpaper
    wallpaper = {
      path = wallpaper.path;              # Path to wallpaper image
      mode = wallpaper.mode or "fill";    # fill, fit, center, tile
    };

    # Sound configuration
    sounds = {
      ambient = sounds.ambient or null;          # Background loop audio file
      notification = sounds.notification or null; # Notification sound
      startup = sounds.startup or null;           # Boot/login sound
      volume = sounds.volume or 0.5;              # Default ambient volume
    };

    # Per-app overrides (escape hatch for theme-specific tweaks)
    overrides = {
      hyprland = overrides.hyprland or {};    # Extra hyprland settings
      waybar = overrides.waybar or {};        # Extra waybar config
      rofi = overrides.rofi or {};            # Extra rofi config
      gtk = overrides.gtk or {};              # Extra GTK settings
    };
  };
}
```

### How Users Add Custom Themes

Two paths, both producing the same data model:

**Path 1: GUI (Vibe Switcher)**
1. User opens "Create Theme" in GUI
2. GUI provides: color picker (generates base16), wallpaper file picker, font selector, sound file picker
3. GUI writes a JSON manifest to `~/.local/share/nervos/themes/<name>/manifest.json`
4. nervos-switcher generates config files from the manifest (using templates, NOT Nix rebuild)
5. Theme is immediately available for switching

**Path 2: Nix (Power Users)**
1. User creates `themes/<name>/default.nix` using `mkTheme`
2. User adds theme to the flake's theme list
3. `nixos-rebuild switch` or `home-manager switch` builds the theme configs
4. Theme is available after rebuild

The GUI path stores themes in `~/.local/share/nervos/themes/` as JSON + assets. The Nix path stores themes in `/nix/store/` as pre-built configs. The nervos-switcher daemon treats both sources equally by reading a unified theme registry.

## Architectural Patterns

### Pattern 1: Config Template Generation

**What:** Each home-manager module produces per-theme config files using Nix string interpolation, rather than one "active" config.

**When to use:** For all themeable applications (Hyprland, waybar, rofi, terminals, GTK).

**Trade-offs:** More Nix code upfront, but enables instant switching. The alternative (runtime template rendering) would require shipping a template engine.

```nix
# modules/home/waybar.nix
{ config, lib, pkgs, ... }:
let
  themes = config.nervos.themes;  # All registered themes
  
  mkWaybarStyle = theme: ''
    * {
      font-family: "${theme.fonts.sansSerif.name}";
      font-size: ${toString theme.fonts.sizes.desktop}px;
    }
    #waybar {
      background-color: #${theme.colors.base00};
      color: #${theme.colors.base05};
    }
    #workspaces button.active {
      background-color: #${theme.colors.base0D};
      color: #${theme.colors.base00};
    }
  '';
in
{
  # Generate waybar style for EACH theme
  home.file = lib.mapAttrs' (name: theme: {
    name = ".local/share/nervos/configs/${name}/waybar-style.css";
    value.text = mkWaybarStyle theme;
  }) themes;
}
```

### Pattern 2: Daemon + GUI Separation

**What:** The nervos-switcher daemon handles all system interaction (symlinks, signals, audio). The Vibe Switcher GUI is a thin client that communicates with the daemon.

**When to use:** Always. This separation means the GUI can crash without breaking the theme state, the daemon can be controlled via CLI/hotkeys independently of the GUI, and testing is easier.

**Communication:** D-Bus is the standard IPC on Linux desktops. The daemon exposes a D-Bus interface:
- `org.nervos.Switcher.Switch(theme_name)` -- switch to theme
- `org.nervos.Switcher.GetCurrent()` -- returns current theme name
- `org.nervos.Switcher.ListThemes()` -- returns available themes
- `org.nervos.Switcher.GetThemeInfo(name)` -- returns theme metadata

**Trade-offs:** D-Bus adds complexity vs a simple Unix socket. But D-Bus integrates naturally with GTK4 (GDBus), is standard on all Linux desktops, and supports introspection.

```
┌──────────────────┐     D-Bus      ┌──────────────────────┐
│  Vibe Switcher   │ ────────────> │  nervos-switcher     │
│  (GTK4 GUI)      │ <──────────── │  daemon               │
│                  │   signals      │                      │
│  Also:           │                │  Manages:            │
│  - Theme preview │                │  - Symlinks          │
│  - Color picker  │                │  - Reload signals    │
│  - Theme editor  │                │  - Sound playback    │
└──────────────────┘                │  - State persistence │
                                    └──────────────────────┘
       Also controlled by:
       - hyprctl dispatch exec (hotkey)
       - CLI: nervos-switch <theme>
```

### Pattern 3: Atomic Symlink Swap

**What:** Theme switching replaces a single top-level symlink (or a small set of symlinks) atomically, rather than copying files.

**When to use:** For switching between pre-built Nix theme configs.

**Trade-offs:** Symlinks can confuse applications that check realpath or don't follow symlinks. Mitigation: use `~/.config/hypr/current-theme.conf` as a `source` directive in the main `hyprland.conf`, rather than replacing `hyprland.conf` itself.

```nix
# hyprland.conf (static, never changes)
source = ~/.config/hypr/current-theme.conf

# current-theme.conf is a symlink:
# ~/.config/hypr/current-theme.conf -> /nix/store/...-nervos-theme-eva/hyprland-theme.conf
```

This pattern works well because Hyprland's `source` directive follows symlinks, and `hyprctl reload` re-reads everything.

### Pattern 4: State File for Persistence

**What:** A simple state file at `~/.local/state/nervos/current-theme` stores the active theme name. The daemon reads this on startup.

**When to use:** Always. This is how the theme persists across reboots without requiring a NixOS rebuild.

**Trade-offs:** This is mutable state outside Nix's control. Acceptable because it is user preference state (like "which wallpaper is active"), not system configuration.

## Anti-Patterns to Avoid

### Anti-Pattern 1: Full NixOS Rebuild Per Theme Switch

**What people do:** Run `nixos-rebuild switch` with different Stylix options every time the user changes themes.

**Why it's wrong:** Takes 10-60 seconds, requires root for NixOS-level rebuild, blocks user interaction, cannot be triggered from GUI without privilege escalation.

**Do this instead:** Pre-build all themes at `nixos-rebuild` time. Switch at runtime via config symlinks and reload signals.

### Anti-Pattern 2: Monolithic Theme Config

**What people do:** Put all theme config into a single massive Nix module that touches every application.

**Why it's wrong:** Adding a new themed application requires modifying the monolith. Testing one app's theming requires rebuilding everything. Hard to debug.

**Do this instead:** Each application module (waybar.nix, rofi.nix, etc.) owns its own per-theme config generation. The theme data model is input; each module produces its own output files.

### Anti-Pattern 3: Runtime Template Rendering

**What people do:** Ship Mustache/Jinja templates in the distro and render config files at runtime when switching themes.

**Why it's wrong:** Requires a template engine at runtime, introduces a category of runtime errors (bad templates), and the Nix language is already a superior template engine.

**Do this instead:** Use Nix string interpolation at build time. The only runtime operation should be symlink swap + reload signal, not template rendering. Exception: user-created themes via GUI must use runtime templating since they bypass Nix. For this, use simple string replacement in the daemon (sed-like, not a template engine).

### Anti-Pattern 4: GTK4 App with Electron/Web Stack

**What people do:** Build the theme switcher GUI in Electron, Tauri, or as a web app.

**Why it's wrong:** Massive footprint for a simple GUI, poor Wayland integration, dependency hell on NixOS, violates the ethos of a lightweight ricing distro.

**Do this instead:** GTK4 with either Python (PyGObject) or Vala. Python is faster to develop; Vala produces native binaries with no runtime dependency. Recommendation: **Python + PyGObject** for v1 (faster iteration), consider Vala rewrite if performance matters later.

## Vibe Switcher GTK4 Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Vibe Switcher (GTK4)                  │
│                                                       │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │ Theme Grid  │  │ Theme Editor │  │ Settings    │ │
│  │ (main view) │  │ (create/edit)│  │ (prefs)     │ │
│  │             │  │              │  │             │ │
│  │ - Cards w/  │  │ - Color pick │  │ - Hotkeys   │ │
│  │   previews  │  │ - Font select│  │ - Sounds on │ │
│  │ - Click to  │  │ - Wallpaper  │  │ - Startup   │ │
│  │   switch    │  │ - Sound pick │  │   theme     │ │
│  │ - Active    │  │ - Preview    │  │ - Auto-dark │ │
│  │   indicator │  │ - Save       │  │             │ │
│  └──────┬──────┘  └──────┬───────┘  └─────────────┘ │
│         │                │                            │
│  ┌──────┴────────────────┴──────────────────────────┐ │
│  │          D-Bus Client (GDBus)                     │ │
│  │  Connects to: org.nervos.Switcher                 │ │
│  └───────────────────────┬──────────────────────────┘ │
└──────────────────────────┼───────────────────────────┘
                           │ D-Bus
                           v
                ┌─────────────────────┐
                │ nervos-switcher     │
                │ daemon              │
                └─────────────────────┘
```

**Technology choice:** Python 3 + PyGObject + GTK4 + libadwaita

- **PyGObject** provides Python bindings for GTK4/GLib/GDBus
- **libadwaita** provides adaptive widgets and follows GNOME HIG (but respects custom theming)
- Built as a standard Python package, packaged via Nix `buildPythonApplication`
- Uses GTK4's `Gtk.GridView` for theme cards with preview images
- Color picker: `Gtk.ColorDialog` (GTK4 native)
- File picker: `Gtk.FileDialog` (GTK4 native, portal-aware for Wayland)

**Confidence:** MEDIUM -- PyGObject + GTK4 + libadwaita is the standard Python GTK4 stack. Whether libadwaita plays nicely with custom Stylix GTK4 theming needs validation (libadwaita historically overrides GTK themes).

**IMPORTANT NOTE on libadwaita:** libadwaita apps use their own theming and may ignore GTK theme settings. This could conflict with Stylix theming. Two options:
1. Use GTK4 WITHOUT libadwaita -- more control over theming but lose adaptive widgets
2. Use libadwaita and theme it via `@define-color` CSS overrides

Recommendation: Use GTK4 without libadwaita for the Vibe Switcher. A theme-switching app that doesn't respect its own themes would be embarrassing. Standard GTK4 widgets are sufficient for this UI.

## ISO Build Pipeline Architecture

```
flake.nix
    │
    v
nixosConfigurations.nervos-iso = nixpkgs.lib.nixosSystem {
    │
    ├── modules/nixos/core.nix        (base system)
    ├── modules/nixos/hyprland.nix    (WM)
    ├── hosts/iso/default.nix         (ISO-specific: live user, auto-login)
    │
    ├── ALL themes pre-built          (so switching works on live ISO)
    │
    └── installer module:
        ├── calamares or custom script
        ├── disk partitioning (disko)
        └── copy config to target system
    │
    v
nix build .#nixosConfigurations.nervos-iso.config.system.build.isoImage
    │
    v
result/iso/nervos-<version>-x86_64-linux.iso
```

### ISO Build Details

- Use NixOS's built-in ISO image builder: `config.system.build.isoImage`
- The ISO boots into a live Hyprland session with NervOS fully themed (EVA default)
- Installer options:
  - **Calamares**: Standard graphical installer used by many distros. Available in nixpkgs. Handles partitioning, user creation, locale. HIGH complexity to customize but familiar UX.
  - **Custom installer script**: Simpler, can be themed to match NervOS, uses `disko` for declarative partitioning. Recommendation: custom script for v1, Calamares if demand exists.
- ISO includes all theme assets (wallpapers, sounds, fonts) -- they are part of the Nix closure
- Live user auto-logs into Hyprland session via greetd

**Confidence:** MEDIUM -- NixOS ISO building via `isoImage` is well-documented. The exact integration of a themed Hyprland live session in an ISO needs testing.

## Theme Asset Organization

```
themes/
├── eva/
│   ├── default.nix              # Theme definition using mkTheme
│   ├── wallpapers/
│   │   ├── main.png             # Primary wallpaper
│   │   ├── alt-1.png            # Alternative wallpapers (user can cycle)
│   │   └── lock.png             # Lock screen wallpaper
│   ├── sounds/
│   │   ├── ambient.ogg          # Background loop (NERV HQ hum)
│   │   ├── notification.ogg     # Alert sound
│   │   └── startup.ogg          # Login sound
│   ├── preview.png              # Thumbnail for Vibe Switcher GUI
│   └── extras/
│       ├── plymouth-theme/      # Boot splash (if Plymouth used)
│       └── sddm-theme/          # Login screen theme (if SDDM used)
```

Assets are included in the Nix derivation via `pkgs.stdenv.mkDerivation` or just referenced as paths in the flake. Since they are in the flake directory, Nix will copy them to the store.

**User custom themes** stored at runtime:
```
~/.local/share/nervos/
├── themes/
│   ├── my-custom-theme/
│   │   ├── manifest.json        # Theme definition (same schema as Nix, but JSON)
│   │   ├── wallpapers/
│   │   ├── sounds/
│   │   └── preview.png
│   └── another-theme/
├── configs/                     # Pre-generated configs (from daemon templates)
│   ├── my-custom-theme/
│   │   ├── hyprland-theme.conf
│   │   ├── waybar-style.css
│   │   └── ...
│   └── ...
└── state/
    └── current-theme            # Name of active theme
```

## Integration Points

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Vibe Switcher <-> nervos-switcher | D-Bus (`org.nervos.Switcher`) | GUI is a thin client |
| nervos-switcher <-> Hyprland | `hyprctl` CLI + IPC socket | Standard Hyprland control |
| nervos-switcher <-> waybar | POSIX signals (SIGUSR2) + process restart | Signal for CSS, restart for config |
| nervos-switcher <-> swww | `swww img` CLI | Wallpaper transitions |
| nervos-switcher <-> audio | `pw-play` / `mpv --no-video` | Sound playback |
| nervos-switcher <-> GTK settings | `gsettings` CLI / GSettings API | GTK theme propagation |
| nervos-switcher <-> terminals | App-specific (kitty remote, foot SIGHUP) | Each terminal has its own mechanism |
| Nix build <-> Stylix | Nix module system | Stylix generates colors at eval time |
| Nix build <-> home-manager | Nix module system | home-manager generates dotfiles |
| ISO builder <-> NixOS system | `config.system.build.isoImage` | Standard NixOS ISO builder |

### External Services

None. NervOS is fully offline-capable. Theme assets are bundled. No cloud dependencies.

## Suggested Build Order (Dependencies)

This is the critical output for roadmap planning. Components must be built in this order due to dependencies.

```
Phase 1: Foundation (no dependencies)
├── flake.nix skeleton with inputs (nixpkgs, home-manager, stylix, hyprland)
├── Basic NixOS modules (core.nix, hyprland.nix, audio.nix)
├── Basic home-manager modules (hyprland.nix, waybar.nix, terminal.nix)
└── Single theme (EVA) working via standard Stylix

Phase 2: Theme Infrastructure (depends on Phase 1)
├── lib/theme.nix -- mkTheme function and schema
├── Refactor EVA theme to use mkTheme
├── Per-theme config generation in each home-manager module
├── Theme configs output to ~/.local/share/nervos/configs/
└── Second theme (Lain) to prove multi-theme works

Phase 3: Runtime Switching (depends on Phase 2)
├── nervos-switcher daemon (symlink swap + reload signals)
├── CLI interface: nervos-switch <theme>
├── State persistence (~/.local/state/nervos/current-theme)
├── Sound system integration
└── Test: can switch EVA <-> Lain via CLI

Phase 4: GUI (depends on Phase 3)
├── Vibe Switcher GTK4 app skeleton
├── D-Bus integration with nervos-switcher
├── Theme grid with previews
├── Theme switching via GUI click
└── Test: can switch themes via GUI

Phase 5: Theme Editing (depends on Phase 4)
├── Theme editor in GUI (color picker, wallpaper, fonts, sounds)
├── Custom theme JSON manifest format
├── nervos-switcher: runtime config generation from JSON manifests
├── User theme storage (~/.local/share/nervos/themes/)
└── Third theme (Steins;Gate) to stress-test

Phase 6: Distribution (depends on Phase 1-3, parallel with 4-5)
├── ISO build configuration
├── Live session setup (auto-login, default theme)
├── Installer (custom script or Calamares)
├── Hardware detection / driver inclusion
└── Test: boot ISO, install, themes work
```

### Dependency Graph

```
[Phase 1: Foundation]
        │
        v
[Phase 2: Theme Infrastructure]
        │
        ├──────────────────────┐
        v                      v
[Phase 3: Runtime Switching]  [Phase 6: ISO Build] (can start)
        │
        v
[Phase 4: GUI]
        │
        v
[Phase 5: Theme Editing]
```

Phase 6 (ISO) can begin after Phase 1 for the basic bootable image, but needs Phase 3 for theme switching to work on the live ISO.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 3 themes (v1) | All themes pre-built in Nix. No optimization needed. |
| 10-20 themes | Build times may increase. Consider lazy theme building (only build themes user has enabled). |
| 50+ themes (community) | Need a theme repository / registry. Themes become separate flakes that users add as inputs. Build only installed themes. |
| User-created themes | Already handled by JSON manifest path. No Nix rebuild required. |

### First Bottleneck: Nix Build Time

With many themes, `nixos-rebuild` will slow down because it evaluates all theme configs. Mitigation: lazy evaluation -- only build themes that are in the user's "installed" list. The `mkTheme` function can be wrapped to check an "enabled themes" config option.

### Second Bottleneck: ISO Size

Each theme adds wallpapers and sounds. A 4K wallpaper is 5-15MB; ambient sounds can be larger. With 10 themes, the ISO could grow by 200MB+. Mitigation: ship 3 bundled themes on ISO, additional themes downloadable post-install.

## Sources

- NixOS Flakes documentation (NixOS Wiki) -- training data, MEDIUM confidence
- Stylix GitHub repository (github.com/danth/stylix) -- training data, MEDIUM confidence
- Hyprland Wiki (hyprctl, IPC, configuration) -- training data, MEDIUM confidence
- home-manager documentation -- training data, MEDIUM confidence
- GTK4 Python bindings (PyGObject) -- training data, MEDIUM confidence
- swww (wallpaper daemon for Wayland) -- training data, MEDIUM confidence
- waybar reload mechanisms -- training data, LOW confidence (SIGUSR2 needs validation)
- NixOS ISO image building -- training data, MEDIUM confidence

**NOTE:** All sources are from training data. WebSearch, WebFetch, and Context7 were unavailable during research. All findings should be validated against current documentation before implementation.

---
*Architecture research for: NervOS (NixOS custom distro with Hyprland theming)*
*Researched: 2026-04-06*
