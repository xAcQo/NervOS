# Stack Research

**Domain:** Custom NixOS-based Linux distribution with Hyprland + Stylix theming
**Researched:** 2026-04-06
**Confidence:** MEDIUM (training data through May 2025; WebSearch/WebFetch unavailable -- versions and flake refs MUST be validated against current repos before use)

---

## Recommended Stack

### Core OS Foundation

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| NixOS | 24.11 (stable) or unstable | Base operating system | Declarative, reproducible system configuration. The entire distro IS a flake -- every component is pinned and reproducible. Use `nixos-unstable` for Hyprland/Wayland bleeding edge. |
| Nix Flakes | Built-in (Nix 2.18+) | Project structure and dependency pinning | Standard for NixOS projects since 2023. Provides lockfile-based reproducibility, composable inputs, and the `nixosConfigurations` output that defines the entire system. |
| home-manager | matches nixpkgs branch | User-space dotfile and application management | Manages per-user configs (Hyprland, Waybar, kitty, rofi, GTK settings) declaratively. Use as NixOS module (not standalone) for tighter system integration. |

**Confidence:** MEDIUM -- NixOS 24.11 was the stable release as of late 2024. By April 2026, NixOS 25.05 or 25.11 may be current stable. **Validate the current stable channel before pinning.**

### Window Manager and Desktop

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Hyprland | latest from flake | Wayland compositor / window manager | The dominant tiling Wayland compositor in the NixOS rice community. Dynamic tiling, animations, rounded corners, blur -- all configurable. Has first-class NixOS/home-manager module support. |
| Waybar | latest from nixpkgs | Status bar | The standard Wayland status bar. Fully CSS-themeable, Stylix has built-in support. Modules for workspaces, clock, battery, network, custom scripts. |
| rofi-wayland | latest from nixpkgs | Application launcher | Wayland-native fork of rofi. Themeable via CSS-like syntax. Stylix targets it directly. Use `rofi-wayland`, NOT the X11 `rofi` package. |
| dunst or mako | latest from nixpkgs | Notification daemon | Both are Wayland-compatible. Mako is simpler and more Wayland-native. Dunst is more configurable. Stylix supports both. **Recommend mako** for Wayland purity. |
| swww | latest from nixpkgs | Wallpaper daemon | Animated wallpaper transitions on Wayland. Supports GIF wallpapers. Used for theme-switching wallpaper changes. Alternative: `hyprpaper` (simpler, from Hyprland team). **Recommend swww** for animated transitions during theme switches. |

**Confidence:** HIGH for Hyprland/Waybar/rofi-wayland as the standard stack. This combination is near-universal in NixOS Hyprland setups.

### Theming System

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Stylix | latest from flake | System-wide theming engine | Automatically applies a base16 color scheme + fonts + wallpaper across ALL configured applications (GTK, Hyprland, Waybar, kitty, rofi, dunst/mako, etc). Single source of truth for the entire visual identity. |
| base16 schemes | via Stylix | Color palette definitions | Stylix uses the base16 system (16 named colors). You define a scheme or point to an existing one. Custom schemes are just attrsets with base00-base0F hex values. |
| nix-colors (optional) | latest from flake | Additional base16 scheme library | Large collection of pre-made base16 schemes. Can be used alongside Stylix or independently. **Not required** if you are defining custom schemes (which NervOS will). |

**Confidence:** HIGH for Stylix as the theming layer. It is the dominant NixOS theming solution and has replaced ad-hoc base16 approaches.

### Terminal and Shell

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| kitty | latest from nixpkgs | Terminal emulator | GPU-accelerated, image rendering support (useful for anime aesthetic), ligature support, Stylix auto-themes it. Alternative: foot (lighter, also Stylix-supported). **Recommend kitty** for image rendering capability. |
| fish or zsh | latest from nixpkgs | Shell | Either works. Fish has better out-of-box experience (syntax highlighting, autosuggestions). Zsh is more POSIX-compatible. **Recommend fish** for the target audience (users who want a polished, themed experience). |
| starship | latest from nixpkgs | Shell prompt | Cross-shell prompt with Nerd Font icons. Stylix-compatible. Fits the aesthetic-focused distro. |

### GTK4 Application Development (Vibe Switcher)

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| GTK4 | 4.14+ | GUI toolkit | Native Linux toolkit. Wayland-first. CSS-based theming aligns with Stylix. Use GTK4 (not GTK3) -- it is the current generation with better Wayland support. |
| libadwaita | 1.5+ | GTK4 design library | Provides modern GNOME-style widgets (AdwApplicationWindow, AdwPreferencesPage, etc). Handles dark/light mode. BUT: it enforces Adwaita style, which may conflict with custom theming. See pitfalls. |
| Python + PyGObject | Python 3.12+ | Language binding for GTK4 | Fastest development velocity for a GUI app on NixOS. `gi.repository.Gtk` and `gi.repository.Adw` bindings are mature. Alternative: Rust + gtk4-rs (better performance, harder to develop). **Recommend Python** for initial development speed; can port to Rust later if needed. |
| Blueprint (optional) | latest | GTK4 UI markup | Declarative UI definition language that compiles to GTK XML. Cleaner than raw XML for UI layout. **Nice to have**, not required. |

**Confidence:** MEDIUM for the GTK4 + Python choice. This is well-established for GNOME apps but packaging GTK4 Python apps on NixOS has specific quirks (GI_TYPELIB_PATH, wrapGAppsHook4). Needs phase-specific research.

### ISO Build Tooling

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| NixOS native ISO build | built-in | ISO generation | Use `nixos-generators` or the built-in `nixos-generate-config` + `nix build .#nixosConfigurations.nervos-iso.config.system.build.isoImage`. The native approach uses `installer/cd-dvd` profiles from nixpkgs. **Recommend the native nixpkgs ISO profile** over nixos-generators for a full custom distro, because you need full control over the installer experience. |
| nixos-generators | latest from flake | Alternative ISO/VM builds | Better for quick format generation (ISO, QCOW2, VirtualBox, etc). Use for development/testing VM images. Less control over the install experience than native ISO profiles. **Use for dev VMs, not for the final installer ISO.** |

**Confidence:** MEDIUM. The native ISO build approach is standard for NixOS distros (e.g., how NixOS official ISOs are built). nixos-generators is a convenience wrapper. Validate current API.

### File Manager and Extras

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| thunar or nautilus | latest | File manager | Thunar is lighter, GTK3. Nautilus is GTK4/libadwaita. **Recommend thunar** for lighter footprint and easier theming. |
| grim + slurp | latest | Screenshot tools | Standard Wayland screenshot pair. grim captures, slurp selects region. |
| wl-clipboard | latest | Clipboard manager | Wayland clipboard utility. Required for copy/paste to work properly across apps. |
| polkit + polkit-gnome | latest | Authentication agent | Required for privileged operations (mounting, network). polkit-gnome provides the GUI dialog. |
| networkmanager | latest | Network management | Standard. nm-applet for tray icon in Waybar. |

---

## Flake Structure

```nix
# flake.nix -- the root of the entire NervOS distro
{
  description = "NervOS - Anime-themed NixOS distribution";

  inputs = {
    # Pin to nixos-unstable for latest Hyprland/Wayland support
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager -- match nixpkgs branch
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland -- use the official flake for latest features
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix -- system-wide theming
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos-generators -- for dev VM builds
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: nix-colors for pre-built base16 schemes
    # nix-colors.url = "github:Misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, stylix, nixos-generators, ... }: {
    # The live system / installed system configuration
    nixosConfigurations.nervos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nervos/configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        hyprland.nixosModules.default  # verify current module name
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nervos = import ./home/default.nix;
        }
      ];
    };

    # ISO image build target
    nixosConfigurations.nervos-iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
        ./hosts/iso/configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        # ... same theming modules
      ];
    };

    # Dev VM via nixos-generators
    packages.x86_64-linux.vm = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "vm";  # or "qcow", "virtualbox", etc
      modules = [
        ./hosts/nervos/configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
```

**Confidence:** MEDIUM for exact module paths (e.g., `hyprland.nixosModules.default`). The flake structure pattern is standard but specific module export names change between versions. **Validate all `nixosModules.*` paths against current flake outputs.**

---

## Stylix Configuration API

```nix
# In your NixOS configuration (system-level)
{
  stylix = {
    # Enable Stylix
    enable = true;

    # Wallpaper -- REQUIRED, Stylix derives colors from this if no scheme specified
    image = ./wallpapers/eva-nerv-dark.png;

    # Base16 color scheme -- override auto-generated from wallpaper
    base16Scheme = {
      # EVA/NERV theme example
      base00 = "0a0a0f";  # Default Background (near-black)
      base01 = "131320";  # Lighter Background
      base02 = "1e1e2e";  # Selection Background
      base03 = "45475a";  # Comments, Invisibles
      base04 = "585b70";  # Dark Foreground
      base05 = "cdd6f4";  # Default Foreground
      base06 = "f5e0dc";  # Light Foreground
      base07 = "b4befe";  # Light Background
      base08 = "f38ba8";  # Red (errors, warnings)
      base09 = "fab387";  # Orange (NERV amber)
      base0A = "f9e2af";  # Yellow
      base0B = "a6e3a1";  # Green (EVA Unit-01)
      base0C = "94e2d5";  # Cyan
      base0D = "89b4fa";  # Blue
      base0E = "cba6f7";  # Purple
      base0F = "f2cdcd";  # Dark red / brown
    };

    # OR use a pre-built scheme name:
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 13;
        applications = 12;
        popups = 12;
        desktop = 11;
      };
    };

    # Opacity settings (0.0 to 1.0)
    opacity = {
      terminal = 0.9;
      applications = 0.95;
      desktop = 1.0;
      popups = 0.95;
    };

    # Cursor
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # Polarity: force dark or light
    polarity = "dark";

    # Per-target overrides
    targets = {
      # Disable Stylix for specific targets if you want manual control
      # gtk.enable = false;
      # hyprland.enable = true;  # enabled by default when Hyprland is detected
    };
  };
}
```

**Stylix-supported targets (auto-themed when detected):**
- GTK 2/3/4 themes
- Hyprland (border colors, gaps styling)
- Waybar (CSS colors)
- kitty, foot, alacritty (terminal colors)
- rofi/wofi (launcher colors)
- dunst/mako (notification colors)
- bat, btop, fzf, vim/neovim
- GRUB (boot screen)
- Plymouth (boot splash)
- SDDM / GDM (login screen)
- fish, starship (shell prompt colors)

**Confidence:** MEDIUM. The Stylix option structure (`stylix.image`, `stylix.base16Scheme`, `stylix.fonts`, `stylix.opacity`, `stylix.cursor`, `stylix.polarity`) is well-established. Exact option names for `targets` may have shifted. The `nerdfonts` package was being restructured in nixpkgs (moving to `nerd-fonts` with individual packages like `pkgs.nerd-fonts.jetbrains-mono`). **Validate font package names.**

---

## Hyprland Configuration via NixOS/home-manager

```nix
# In home-manager config
{
  wayland.windowManager.hyprland = {
    enable = true;
    
    settings = {
      # General
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        # Colors are auto-set by Stylix, but can be overridden:
        # "col.active_border" = "rgba(fab387ee) rgba(a6e3a1ee) 45deg";
        # "col.inactive_border" = "rgba(45475aaa)";
        layout = "dwindle";
      };

      # Decoration (blur, rounding, shadows)
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
        };
        drop_shadow = true;
        shadow_range = 15;
        shadow_render_power = 3;
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Key bindings
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, kitty"
        "$mod, D, exec, rofi -show drun"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        # ... workspace bindings
      ];

      # Autostart
      exec-once = [
        "waybar"
        "mako"
        "swww-daemon"
        "swww img ~/wallpapers/current.png"
      ];
    };

    # Extra config appended verbatim (escape hatch)
    extraConfig = ''
      # Any raw hyprland.conf syntax here
    '';
  };
}
```

**Confidence:** HIGH for the `wayland.windowManager.hyprland.settings` structure. This is the standard home-manager Hyprland module pattern. Specific config option names (like `drop_shadow` vs `shadow`) may change between Hyprland versions.

---

## GTK4 Vibe Switcher -- Development Approach

### Packaging Strategy

```nix
# devShell for GTK4 Python development
{
  devShells.x86_64-linux.default = pkgs.mkShell {
    buildInputs = with pkgs; [
      python312
      python312Packages.pygobject3
      gtk4
      libadwaita
      gobject-introspection
      glib
      wrapGAppsHook4
      # For blueprint compiler (optional)
      blueprint-compiler
    ];

    shellHook = ''
      export GI_TYPELIB_PATH="${pkgs.gtk4}/lib/girepository-1.0:${pkgs.libadwaita}/lib/girepository-1.0:$GI_TYPELIB_PATH"
    '';
  };
}

# Package definition for the Vibe Switcher app
{
  nervos-vibe-switcher = pkgs.python312Packages.buildPythonApplication {
    pname = "nervos-vibe-switcher";
    version = "0.1.0";
    src = ./apps/vibe-switcher;

    nativeBuildInputs = [ pkgs.wrapGAppsHook4 pkgs.gobject-introspection ];
    buildInputs = [ pkgs.gtk4 pkgs.libadwaita ];
    propagatedBuildInputs = [ pkgs.python312Packages.pygobject3 ];

    # Prevent double-wrapping
    dontWrapGApps = true;
    preFixup = ''
      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';
  };
}
```

### How the Vibe Switcher Works (Architecture)

The app does NOT modify Nix configuration directly (that would require a rebuild). Instead:

1. **Theme files** are pre-built Nix configurations OR runtime-switchable assets
2. **Runtime switching** changes: wallpaper (via `swww`), GTK CSS overrides, Waybar CSS reload, Hyprland `hyprctl` color commands, terminal color escape sequences
3. **Persistent switching** writes a theme selection file that the Nix config reads on next rebuild

Two-tier approach:
- **Instant preview**: Runtime changes via IPC/CSS hot-reload (no rebuild)
- **Permanent apply**: Updates a symlink/config file, optionally triggers `nixos-rebuild switch`

**Confidence:** MEDIUM. The two-tier approach is the only sane architecture -- Nix rebuilds are too slow for real-time theme preview. The specific IPC commands (`hyprctl keyword`, `swww img`, GTK CSS reload) are well-known. But the full integration (making Stylix respect a runtime theme selection) needs custom engineering.

---

## Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| base16-schemes | via nixpkgs | Pre-built color scheme collection | Reference for creating custom schemes; provides YAML format templates |
| swww | latest | Animated wallpaper daemon | Theme switching with smooth wallpaper transitions |
| hyprctl | ships with Hyprland | Hyprland IPC CLI | Runtime border color changes, layout toggles from Vibe Switcher |
| wrapGAppsHook4 | via nixpkgs | GTK4 app packaging helper | Required for any GTK4 app packaged on NixOS; sets up GI paths |
| nix-your-shell | latest | Nix shell integration | Makes `nix develop` work properly with fish/zsh |
| dconf | via nixpkgs | GSettings backend | Required for GTK theme settings to persist |

---

## Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `nix develop` | Enter devShell with all deps | Use for GTK4 app development |
| `nix build .#nixosConfigurations.nervos-iso.config.system.build.isoImage` | Build ISO | Long build; cache with Cachix |
| `nixos-rebuild build-vm` | Quick VM testing | Faster iteration than ISO builds |
| `nix flake check` | Validate flake structure | Run in CI |
| `cachix` | Binary cache | Cache builds to avoid recompilation; essential for ISO builds |
| `nixos-anywhere` | Remote deployment | Optional; useful for testing on real hardware |

---

## Alternatives Considered

| Category | Recommended | Alternative | When to Use Alternative |
|----------|-------------|-------------|-------------------------|
| Compositor | Hyprland | Sway | If you want stability over features; Sway is more mature but less flashy. Hyprland's animations and blur are essential for an anime-aesthetic distro. |
| Theming | Stylix | nix-colors | If you only need color schemes without auto-application to targets. nix-colors is lighter but requires manual per-app configuration. Stylix wraps nix-colors and adds auto-application. |
| Terminal | kitty | foot | If you want a lighter terminal. foot lacks image rendering but is faster. For anime-themed distro, kitty's image protocol is valuable. |
| Launcher | rofi-wayland | wofi | wofi is simpler but less customizable. rofi-wayland has more theme control, which matters for a themed distro. |
| Wallpaper | swww | hyprpaper | hyprpaper is simpler and from the Hyprland team. Use if you do not need animated transitions. swww's transition effects are worth it for theme switching UX. |
| GTK4 language | Python + PyGObject | Rust + gtk4-rs | Rust for production quality and performance. Python for faster prototyping. Start with Python, consider Rust port for v2 if performance matters. |
| ISO build | Native nixpkgs profiles | nixos-generators | nixos-generators for quick multi-format output. Native profiles for full control over installer UX (which a custom distro needs). |
| Notification | mako | dunst | dunst is more configurable but heavier. mako is Wayland-native and simpler. Either works; Stylix supports both. |
| Login manager | SDDM | GDM / greetd+tuigreet | SDDM has the best theming support (QML themes). GDM is GNOME-coupled. greetd+tuigreet for minimal TUI login. **SDDM for a visual distro.** |
| Boot splash | Plymouth | None | Plymouth provides themed boot animation. Stylix can theme it. Worth including for polished distro experience. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| X11 / Xorg | Legacy display server. Hyprland is Wayland-only. All X11-dependent tools will not work. | Wayland-native equivalents (rofi-wayland, grim+slurp, wl-clipboard) |
| rofi (X11 version) | Will not work under Hyprland/Wayland | rofi-wayland |
| polybar | X11-only status bar | Waybar |
| picom | X11 compositor for transparency/blur | Hyprland has built-in blur/opacity/animations |
| i3 / bspwm | X11 tiling WMs | Hyprland (Wayland equivalent with more features) |
| GTK3 for new apps | Deprecated for new development; GTK4 is current | GTK4 + libadwaita |
| home-manager standalone mode | Adds complexity; harder to share state between system and user config | home-manager as NixOS module (`home-manager.nixosModules.home-manager`) |
| channels (non-flake NixOS) | Legacy package management; no lockfile, not reproducible | Flakes with `flake.lock` |
| nix-env | Imperative package installation; defeats declarative model | Declare packages in NixOS config or home-manager |
| electron-based theme apps | Heavy, poor Wayland integration, bloated for a single-purpose app | Native GTK4 app |

---

## Version Compatibility Matrix

| Component | Must Be Compatible With | Notes |
|-----------|-------------------------|-------|
| nixpkgs branch | Hyprland flake, home-manager, Stylix | All flake inputs should `follows = "nixpkgs"` to avoid multiple nixpkgs instances. Use `nixos-unstable` for Hyprland compatibility. |
| Hyprland version | Waybar, hyprctl, Hyprland plugins | Waybar must support the Hyprland IPC version. Usually fine on unstable. |
| Stylix | nixpkgs branch, home-manager version | Stylix tracks nixpkgs; ensure branch alignment. |
| GTK4 version | libadwaita version, PyGObject version | These are tightly coupled in nixpkgs; using same nixpkgs ensures compatibility. |
| Python version | PyGObject, GTK4 typelibs | Use the Python version from the same nixpkgs. Do not mix. |

**Critical rule:** ALL flake inputs must `follows = "nixpkgs"` to use a single nixpkgs instance. Multiple nixpkgs versions cause build failures, incompatible libraries, and bloated closures.

---

## Stack Patterns by Variant

**If targeting NixOS stable (24.11/25.05):**
- Hyprland from its own flake (not nixpkgs stable, which lags)
- Stylix from its own flake
- home-manager from its own flake matching stable branch
- May encounter version mismatches between stable nixpkgs and bleeding-edge Hyprland

**If targeting nixos-unstable (RECOMMENDED):**
- All components from nixpkgs unstable where possible
- Hyprland still from its own flake for latest features
- Least friction, most community support for Hyprland setups
- Trade-off: occasional breakage from unstable channel

**If building for distribution (ISO):**
- Pin ALL flake inputs to specific revisions in `flake.lock`
- Use Cachix to provide binary cache for users (avoids hours-long builds)
- Test ISO builds in CI before release
- Consider a `nixos-stable` base with Hyprland overlay for user stability

---

## Sources

- Training data knowledge (May 2025 cutoff) -- **MEDIUM confidence overall**
- GitHub: `github:danth/stylix` -- Stylix flake and module structure
- GitHub: `github:hyprwm/Hyprland` -- Hyprland flake and home-manager module
- GitHub: `github:nix-community/home-manager` -- home-manager NixOS module integration
- GitHub: `github:nix-community/nixos-generators` -- ISO/VM generation
- NixOS Wiki patterns for custom distro ISO builds
- Community dotfiles repositories (common Hyprland+Stylix patterns)

**IMPORTANT: WebSearch and WebFetch were unavailable during this research. All version numbers, module paths, and flake input URLs are from training data (May 2025). Before implementing:**

1. **Validate flake input URLs** -- run `nix flake metadata github:danth/stylix` etc. to confirm they resolve
2. **Validate module export names** -- run `nix flake show github:danth/stylix` to see actual `nixosModules` names
3. **Validate NixOS stable version** -- check which NixOS release is current (likely 25.05 or 25.11 by April 2026)
4. **Validate nerdfonts package name** -- the nixpkgs `nerdfonts` package was being split into individual packages; check current nixpkgs
5. **Validate Stylix option paths** -- `stylix.targets.*` namespace may have changed
6. **Validate Hyprland config option names** -- Hyprland frequently renames config options between releases

---
*Stack research for: NervOS -- NixOS-based anime-themed Linux distribution*
*Researched: 2026-04-06*
