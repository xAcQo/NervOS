# Phase 3: Typography & NERV Command Profile - Research

**Researched:** 2026-04-16
**Domain:** NixOS Stylix font configuration, custom font packaging, Hyprland visual theming (borders, gaps, animations), per-component CSS overrides (Waybar, Rofi, mako, hyprlock)
**Confidence:** HIGH for Stylix API and Hyprland config patterns; MEDIUM for Matisse EB licensing/packaging; LOW for nerd-fonts.jetbrains-mono blank-character bug status.

---

## Summary

Phase 3 applies the full NERV Command visual identity on top of the Phase 2 skeleton. The theming architecture established in Phase 1 (Stylix as single source of truth, behavior-only home-manager modules) is correct and does not change. What changes is the *content* of `modules/nixos/stylix.nix`: the Phase 1 placeholder fonts (DejaVu) are swapped for the real ones, and the Phase 1 color palette (already tuned to NERV values) is finalized.

The critical insight is that Phase 3 has two distinct modes of operation for each component. **Mode A (Stylix-managed):** Stylix generates the CSS/config automatically from the base16 palette and font declarations. This covers kitty terminal font, mako colors/fonts, rofi colors/fonts, and Hyprland border colors. These require zero per-component work — just correct declarations in `stylix.nix`. **Mode B (Stylix + mkAfter override):** The component needs Stylix's base palette but also EVA-specific CSS (scaleX compression on Waybar title, MAGI straight-edge borders, tight layout). These use `lib.mkAfter` to append custom CSS after Stylix's generated output rather than replacing it.

The Matisse EB font situation is the largest ambiguity. Matisse EB (Fontworks) is the official EVA typeface and IS the target font per TYPE-01. It is NOT in nixpkgs. A TTF/OTF copy is widely circulated (Internet Archive, freefonts sites) under a personal-use license from Fontworks; the license has since lapsed because the product is discontinued. This creates a risk: the font must be vendored into the repo as a local file or fetched from a known URL, and the packaging adds complexity. The fallback path (Times New Roman Condensed Bold or a close serif) is simpler but less authentic. Research recommends committing a copy of `MatissePro-EB.otf` to `assets/fonts/` and packaging it with `stdenvNoCC.mkDerivation`, then pointing `stylix.fonts.sansSerif` at it.

**Primary recommendation:** Keep Stylix managing all color/font inheritance. For Waybar EVA styling, disable Stylix's Waybar `addCss` output (`stylix.targets.waybar.addCss = false`) and supply a full custom `programs.waybar.style` that uses `@base09` (NERV orange) etc. directly. For border colors and gaps, override with `lib.mkForce` in the Hyprland settings. For the Matisse EB font, vendor the OTF into `assets/fonts/` and package inline in the flake.

---

## Standard Stack

### Core (all already in the project, Phase 3 only configures them)

| Component | Module | Phase 3 Action | Confidence |
|-----------|--------|----------------|------------|
| Stylix | `modules/nixos/stylix.nix` | Swap DejaVu for Matisse EB + JetBrains Mono; finalize palette | HIGH |
| Waybar | `modules/home/waybar.nix` | Add `style = lib.mkAfter` with EVA CSS (or full custom CSS) | HIGH |
| Hyprland borders/gaps | `modules/home/hyprland.nix` | `lib.mkForce` border colors + tight gaps (4px) + animations block | HIGH |
| mako | `modules/home/mako.nix` | No changes needed — Stylix target auto-applies NERV palette | HIGH |
| Rofi | `modules/home/rofi.nix` | No changes needed — Stylix target auto-applies palette/font | HIGH |
| hyprlock | `modules/home/lock.nix` | No changes needed — Stylix target applies colors + wallpaper | HIGH |
| hyprpaper / wallpaper | `modules/home/wallpaper.nix` | Swap `assets/wallpaper.jpg` for actual NERV Command wallpaper from asset collection | HIGH |
| kitty | `modules/home/kitty.nix` | No changes — Stylix target auto-applies JetBrains Mono | HIGH |

### Font Packages

| Font | Nixpkgs Package | Status | Notes |
|------|-----------------|--------|-------|
| JetBrains Mono Nerd Font | `pkgs.nerd-fonts.jetbrains-mono` | In nixpkgs; has reported blank-glyph bug on nixos-unstable (issue #366979, status unclear) | Use name `"JetBrainsMono Nerd Font Mono"` |
| Matisse EB (display) | NOT in nixpkgs | Must vendor or fetch | Package with `stdenvNoCC.mkDerivation`; place OTF in `assets/fonts/` |
| Fallback if Matisse EB fails | `pkgs.liberation_ttf` (Liberation Serif Bold) or `pkgs.noto-fonts-cjk-serif` | In nixpkgs | Bold serif substitutes; less authentic |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Matisse EB vendored | Times New Roman Condensed Bold (corefonts) | Simpler packaging; less authentic EVA look; `pkgs.corefonts` is in nixpkgs |
| Matisse EB vendored | Source Han Serif Bold (`pkgs.source-han-serif`) | Available nixpkgs; Japanese-origin bold serif; closer aesthetic than Latin serifs |
| `lib.mkAfter` CSS override | `stylix.targets.waybar.enable = false` + full custom style | Full override gives more control; `mkAfter` is less brittle |
| `lib.mkForce` for Hyprland borders | `stylix.targets.hyprland.colors.enable = false` | Disabling colors target removes ALL Stylix Hyprland color management; mkForce is surgical |

---

## Architecture Patterns

### Recommended File Layout for Phase 3

```
modules/
├── nixos/
│   └── stylix.nix              # MODIFY: swap fonts, finalize palette
├── home/
│   ├── waybar.nix              # MODIFY: add style = lib.mkAfter with EVA CSS
│   └── hyprland.nix            # MODIFY: add mkForce borders, tight gaps, animations
assets/
├── wallpaper.jpg               # REPLACE: swap placeholder for NERV Command wallpaper
└── fonts/
    └── MatissePro-EB.otf       # ADD: vendored Matisse EB font file
pkgs/
└── matisse-eb/
    └── default.nix             # ADD: stdenvNoCC.mkDerivation package
```

All other home modules (rofi.nix, kitty.nix, mako.nix, lock.nix, wallpaper.nix) require NO changes — Stylix inheritance handles them.

### Pattern 1: Declaring a Custom Font Package in a Flake (no separate nixpkgs PR required)

**What:** Package a vendored OTF/TTF font as a derivation inline in the flake or as a `pkgs/` callPackage.
**When to use:** Any font not in nixpkgs.

```nix
# pkgs/matisse-eb/default.nix
{ stdenvNoCC, ... }:
stdenvNoCC.mkDerivation {
  pname = "matisse-eb";
  version = "1.0";
  src = ../../assets/fonts;   # directory containing MatissePro-EB.otf
  installPhase = ''
    runHook preInstall
    install -Dm644 MatissePro-EB.otf -t $out/share/fonts/opentype
    runHook postInstall
  '';
}
```

Then in `modules/nixos/stylix.nix`:
```nix
{ config, pkgs, ... }:
let
  matisseEB = pkgs.callPackage ../../pkgs/matisse-eb { };
in {
  stylix.fonts.sansSerif = {
    package = matisseEB;
    name = "MatissePro-EB";   # must match the font's internal PostScript/family name
  };
  fonts.packages = [ matisseEB ];  # also register for system fontconfig
}
```

**Source:** Verified against NixOS font packaging guidelines (https://wiki.nixos.org/wiki/Fonts and https://yildiz.dev/posts/packing-custom-fonts-for-nixos/)

### Pattern 2: Stylix + lib.mkAfter for Waybar Custom CSS

**What:** Stylix generates a base `style.css` from the palette. `programs.waybar.style` is a `lines`-type option (order-dependent). `lib.mkAfter` appends your CSS after Stylix's, ensuring overrides win.
**When to use:** When Stylix's auto-generated Waybar CSS is a good base but EVA-specific additions are needed (scaleX compression, custom padding, NERV-orange highlights).

```nix
# modules/home/waybar.nix  (add style block)
{ lib, config, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = { /* ... existing behavior config ... */ };

    style = lib.mkAfter ''
      /* NERV Command: mechanical compression on window title */
      #window {
        font-family: "MatissePro-EB";
        transform: scaleX(0.82);
        transform-origin: left center;
        letter-spacing: 0.05em;
      }

      /* NERV orange accent on active workspace */
      #workspaces button.active {
        color: @base09;
        border-bottom: 2px solid @base09;
      }
    '';
  };
}
```

**CSS color variables available (injected by Stylix):** `@base00` through `@base0F` map directly to the `base16Scheme` values in `stylix.nix`. `@base09` = NERV orange `#ff9830`, `@base08` = alert red `#ff3030`, `@base0C` = wire cyan `#20f0ff`.

**Source:** Stylix tricks page (https://nix-community.github.io/stylix/tricks.html) + Discourse confirmation.

### Pattern 3: Overriding Hyprland Border Colors with lib.mkForce

**What:** Stylix's `stylix.targets.hyprland.colors.enable = true` sets `col.active_border` from `base0D` (blue) by default. Override with `lib.mkForce` to use NERV orange without disabling the entire Hyprland colors target.
**When to use:** Whenever a specific Hyprland color must be a specific EVA value rather than a generic base16 slot.

```nix
# modules/home/hyprland.nix  (add inside settings)
{ lib, config, ... }:
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 4;
      gaps_out = 8;
      border_size = 2;
      # NERV Command: MAGI-style straight-edge borders in NERV orange
      "col.active_border"   = lib.mkForce "rgba(ff9830ff)";
      "col.inactive_border" = lib.mkForce "rgba(1a1a1aff)";
    };
    decoration = {
      rounding = 0;  # MAGI straight-edge — no rounding
    };
    # ... animations block (see Pattern 4)
  };
}
```

**Note:** The `"col.active_border"` key MUST be quoted in Nix because it contains a dot. Hyprland color format is `rgba(RRGGBBAA)` or `rgb(RRGGBB)`.

**Source:** Stylix discussion #1152 + NixOS Discourse base16 colors thread.

### Pattern 4: Hyprland Sharp Ease-Out Animation Block

**What:** Institutional/mechanical look requires sharp ease-out (fast settle, no bounce). Define a custom bezier and apply it to all window and workspace animations.
**When to use:** Phase 3 NERV Command profile; every profile can redefine these.

```nix
# modules/home/hyprland.nix  (add to settings)
animations = {
  enabled = true;
  bezier = [
    # Sharp ease-out: fast deceleration, no overshoot — mechanical/institutional feel
    "nervOut, 0.16, 1, 0.3, 1"
  ];
  animation = [
    "windows,    1, 3, nervOut, popin 85%"
    "windowsIn,  1, 3, nervOut, popin 85%"
    "windowsOut, 1, 2, nervOut, popin 85%"
    "fade,       1, 3, nervOut"
    "workspaces, 1, 4, nervOut, slide"
    "border,     1, 5, nervOut"
  ];
};
```

**Bezier `0.16, 1, 0.3, 1`** is `easeOutExpo` — maximum sharpness, snaps to position instantly with no spring. This is the most "mechanical" standard easing. Speed value `3` = 300ms effective duration at 60fps.

**Source:** Hyprland Animations wiki (https://wiki.hypr.land/Configuring/Animations/) + community dotfiles cross-check.

### Pattern 5: Swapping the Wallpaper (hyprpaper + Stylix)

**What:** `modules/nixos/stylix.nix` has `stylix.image = ../../assets/wallpaper.jpg` as a Phase 1 placeholder. Phase 3 replaces this path with a real NERV Command wallpaper from the asset collection. `modules/home/wallpaper.nix` uses `../../assets/wallpaper.jpg` via a `let wp = ...` binding. Both must point to the same new image.

**IMPORTANT — Stylix/hyprpaper conflict:** Stylix's hyprpaper target (`stylix.targets.hyprpaper`) also calls `services.hyprpaper` internally. Since the project already has `modules/home/wallpaper.nix` managing hyprpaper directly, there is a risk of double-definition. Disable Stylix's hyprpaper management:

```nix
# modules/nixos/stylix.nix  (add)
stylix.targets.hyprpaper.enable = false;
```

This leaves our `services.hyprpaper` declaration in `wallpaper.nix` as the sole manager. The wallpaper path shared between Stylix (`stylix.image`) and hyprpaper (`wallpaper.nix`) is the single source of truth established in Phase 1 — Phase 3 just updates the path.

**Source:** Stylix hyprpaper module docs (https://nix-community.github.io/stylix/options/modules/hyprpaper.html) + issue #499 analysis.

### Anti-Patterns to Avoid

- **Setting font names directly in kitty/rofi/mako:** Stylix targets for those apps auto-apply `stylix.fonts.monospace` and `stylix.fonts.sansSerif`. Any per-app font override will collide with Stylix on next rebuild.
- **Using `stylix.targets.waybar.addCss = false` without providing a full replacement:** This disables ALL Stylix Waybar CSS (colors AND layout), leaving Waybar unstyled. Use `lib.mkAfter` to append EVA CSS on top of Stylix's generated base instead.
- **Forgetting `fonts.packages` when adding a custom font:** `stylix.fonts.sansSerif.package` installs the font for Stylix-themed apps but may not register it with fontconfig for ALL apps. Add the package to `fonts.packages` (NixOS option) as well.
- **Using `rounding = 0` without also setting `decoration.shadow = false`:** Hyprland's default shadow adds a subtle glow that looks wrong on hard-edge MAGI windows. Set `shadow.enabled = false` (or `drop_shadow = false` on older Hyprland versions).
- **Quoting issues with col. variables:** In Nix home-manager Hyprland settings, `col.active_border` must be written as `"col.active_border"` (quoted key) because the dot is not valid in unquoted Nix attrset keys.
- **Using Stylix's `stylix.targets.hyprland.hyprpaper.enable`:** This option may not exist; use `stylix.targets.hyprpaper.enable = false` instead (separate module).

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Font inheritance across all apps | Per-app font settings in kitty.nix, rofi.nix, etc. | `stylix.fonts.*` declarations | Stylix targets propagate to all supported apps automatically |
| NERV orange in Waybar | Hard-coded hex in style.css | `@base09` CSS variable | Stylix injects CSS custom properties; changing palette auto-updates all |
| Custom CSS that survives Stylix rebuilds | Replace `programs.waybar.style = ...` | `programs.waybar.style = lib.mkAfter ...` | `lines`-type option is order-dependent; mkAfter guarantees your overrides land last |
| Color values in Hyprland config | Hard-coded `rgba(ff9830ff)` everywhere | `"rgba(${config.lib.stylix.colors.base09}ff)"` | Palette-driven; changing base09 in stylix.nix cascades |
| New wallpaper path in two places | Update both `stylix.image` and `wallpaper.nix` manually | Single `let wp = ...` binding; use same path in both files | Established in Phase 1; Phase 3 only changes one path |

**Key insight:** Every visual component in this phase either inherits from Stylix automatically or uses a two-line override (`lib.mkForce` / `lib.mkAfter`). There is no scenario where a component needs a fully custom config file.

---

## Common Pitfalls

### Pitfall 1: Matisse EB font name mismatch
**What goes wrong:** Stylix sets `stylix.fonts.sansSerif.name = "MatissePro-EB"` but no app renders it; they fall back to a system default.
**Why it happens:** The `name` field must match the font's internal PostScript name or family name exactly. Font files often have different display names vs. file names vs. PostScript names.
**How to avoid:** After building with the font installed, run `fc-list | grep -i matisse` on the live system to find the exact registered name. The OTF PostScript name for the common circulated file is `MatissePro-EB` — but verify this.
**Warning signs:** `fc-match MatissePro-EB` returns a fallback font name, not MatissePro.

### Pitfall 2: JetBrains Mono Nerd Font blank glyphs
**What goes wrong:** Kitty renders JetBrains Mono but Nerd Font icons (workspace indicators, powerline arrows) appear as blank boxes.
**Why it happens:** Issue #366979 in nixpkgs reports `nerd-fonts.jetbrains-mono` on nixos-unstable has blank Nerd Font characters (filed December 2024, status at time of research: closed but fix not confirmed as delivered).
**How to avoid:** Test after build. If glyphs are blank, switch to `pkgs.nerd-fonts.fira-code` or `pkgs.nerd-fonts.hack` as a temporary substitute, or pin nixpkgs to a commit after the fix. The font name for Kitty would be `"FiraCode Nerd Font Mono"` or `"Hack Nerd Font Mono"`.
**Warning signs:** Workspace numbers in Waybar show empty squares; `kitty +list-fonts | grep JetBrains` shows font but icon test (`printf '\ue0b0'`) renders as box.

### Pitfall 3: Stylix hyprpaper conflict with services.hyprpaper
**What goes wrong:** Build succeeds but wallpaper is set to Stylix's image instead of the project's `assets/wallpaper.jpg`, or `nixos-rebuild` fails with conflicting definition for `services.hyprpaper`.
**Why it happens:** `stylix.targets.hyprpaper` (auto-enabled by default) also writes to `services.hyprpaper.settings`. Our `modules/home/wallpaper.nix` also sets `services.hyprpaper`. Two writers, one option.
**How to avoid:** Add `stylix.targets.hyprpaper.enable = false;` to `modules/nixos/stylix.nix`. This disables Stylix's hyprpaper management entirely; `wallpaper.nix` is the sole source.
**Warning signs:** Desktop shows a different wallpaper than `assets/wallpaper.jpg`; `nix build` warns about conflicting definitions for `services.hyprpaper.settings`.

### Pitfall 4: Waybar CSS @base variables not resolving
**What goes wrong:** Custom Waybar CSS uses `@base09` but the Waybar bar renders with default colors or white text.
**Why it happens:** `@base09` variables are injected by Stylix's Waybar CSS target. If `stylix.targets.waybar.enable = false` (disabled entirely), the variables aren't injected and CSS fails silently.
**How to avoid:** Keep `stylix.targets.waybar.enable` at default (true). Only disable `stylix.targets.waybar.addCss = false` if you're writing a complete replacement CSS. When using `lib.mkAfter`, Stylix still writes its CSS first (including the `@base*` variable declarations), then your CSS appends.
**Warning signs:** `~/.config/waybar/style.css` doesn't contain `@define-color base09` at the top.

### Pitfall 5: Hyprland col.active_border format
**What goes wrong:** Border appears white or wrong color after setting `col.active_border`.
**Why it happens:** Hyprland uses `rgba(RRGGBBAA)` format (8 hex digits with alpha), not `#RRGGBB`. Omitting the alpha channel or using wrong format silently produces white.
**How to avoid:** Use `"rgba(ff9830ff)"` (full opacity) or `"rgb(ff9830)"`. When using Stylix colors: `"rgba(${config.lib.stylix.colors.base09}ff)"` (appending `ff` alpha).
**Warning signs:** Border renders white regardless of color setting.

### Pitfall 6: decoration.rounding vs shadow interaction
**What goes wrong:** Setting `rounding = 0` for MAGI straight-edge windows, but a faint shadow glow still makes corners look slightly rounded.
**Why it happens:** Hyprland's default drop shadow is enabled and creates a visual softening effect near corners.
**How to avoid:** Disable shadows for NERV Command profile: `decoration.shadow.enabled = false` (Hyprland v0.41+; earlier versions used `drop_shadow = false`).
**Warning signs:** Window corners appear slightly soft despite rounding = 0.

### Pitfall 7: Animation syntax list vs. single string in Nix
**What goes wrong:** Nix build fails with type error on the `animation` key.
**Why it happens:** Home-manager's Hyprland module accepts `animation` as either a list of strings or a single string. When Nix tries to merge a list from your config with a non-list from another module, a type conflict occurs.
**How to avoid:** Always use list syntax: `animation = [ "windows, 1, 3, nervOut" "fade, 1, 3, nervOut" ];`. Same for `bezier`.
**Warning signs:** `nix eval` error: "expected a list but got a string" or vice versa.

---

## Code Examples

### Complete stylix.nix for Phase 3

```nix
# modules/nixos/stylix.nix
{ config, pkgs, ... }:
let
  matisseEB = pkgs.callPackage ../../pkgs/matisse-eb { };
in {
  stylix = {
    enable = true;
    image = ../../assets/wallpaper.jpg;  # Phase 3: replace with NERV Command wallpaper
    polarity = "dark";

    base16Scheme = {
      base00 = "000000";  # Background: true black
      base01 = "1a1a1a";  # Lighter background
      base02 = "333333";  # Selection background
      base03 = "666666";  # Comments, muted
      base04 = "999999";  # Dark foreground
      base05 = "cccccc";  # Default foreground
      base06 = "e6e6e6";  # Light foreground
      base07 = "ffffff";  # Lightest foreground
      base08 = "ff3030";  # Red (alert red)
      base09 = "ff9830";  # Orange (NERV orange -- primary accent)
      base0A = "ffcc00";  # Yellow
      base0B = "40bf40";  # Green
      base0C = "20f0ff";  # Cyan (wire cyan highlight)
      base0D = "4080ff";  # Blue
      base0E = "9050ff";  # Purple
      base0F = "ff6030";  # Dark orange
    };

    fonts = {
      # Phase 3: swap DejaVu placeholder for Matisse EB display font
      sansSerif = {
        package = matisseEB;
        name = "MatissePro-EB";   # verify with fc-list after build
      };
      serif = {
        package = matisseEB;
        name = "MatissePro-EB";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 10;
        terminal = 12;
        popups = 10;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    opacity = {
      applications = 1.0;
      desktop = 0.9;
      terminal = 0.95;
      popups = 0.95;
    };
  };

  # Disable Stylix's hyprpaper management; wallpaper.nix owns services.hyprpaper
  stylix.targets.hyprpaper.enable = false;

  # Register Matisse EB for all fontconfig consumers
  fonts.packages = [ matisseEB ];
}
```

### Custom Font Derivation (pkgs/matisse-eb/default.nix)

```nix
# pkgs/matisse-eb/default.nix
{ stdenvNoCC, ... }:
stdenvNoCC.mkDerivation {
  pname = "matisse-eb";
  version = "1.0";
  src = ../../assets/fonts;  # directory containing MatissePro-EB.otf
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm644 $src/MatissePro-EB.otf -t $out/share/fonts/opentype
    runHook postInstall
  '';
}
```

### Waybar with EVA CSS Overrides

```nix
# modules/home/waybar.nix
{ lib, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 4;
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];

      "hyprland/workspaces" = { format = "{id}"; };
      clock = {
        format = "{:%Y-%m-%d  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };
      pulseaudio = {
        format = "{volume}% {icon}";
        format-muted = "MUTE";
        format-icons.default = [ "" "" "" ];
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      network = {
        format-wifi = "{essid} {signalStrength}%";
        format-ethernet = "eth";
        format-disconnected = "--";
        on-click = "nm-connection-editor";
      };
      battery = {
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
        states = { warning = 30; critical = 15; };
      };
      tray.spacing = 8;
    };

    # TYPE-04: scaleX(0.82) mechanical compression on Waybar window title
    # lib.mkAfter ensures this appends AFTER Stylix's generated CSS
    style = lib.mkAfter ''
      /* NERV Command: mechanical compression (TYPE-04) */
      #window {
        transform: scaleX(0.82);
        transform-origin: left center;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        font-weight: bold;
      }

      /* NERV orange accent on active workspace */
      #workspaces button.active {
        color: @base09;
        border-bottom: 2px solid @base09;
        background-color: @base01;
      }

      #workspaces button {
        color: @base04;
        border-bottom: 2px solid transparent;
      }

      /* Clock in wire cyan */
      #clock {
        color: @base0C;
        font-weight: bold;
      }

      /* Alert red for critical battery */
      #battery.critical {
        color: @base08;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to { color: @base00; background-color: @base08; }
      }
    '';
  };
}
```

### Hyprland with NERV Command Visual Settings

```nix
# modules/home/hyprland.nix (additions to existing settings block)
{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 4;
      gaps_out = 8;
      border_size = 2;
      "col.active_border"   = lib.mkForce "rgba(ff9830ff)";
      "col.inactive_border" = lib.mkForce "rgba(1a1a1aff)";
      layout = "dwindle";
    };
    decoration = {
      rounding = 0;           # MAGI straight-edge windows
      shadow = {
        enabled = false;      # no shadow glow on hard-edge windows
      };
    };
    animations = {
      enabled = true;
      bezier = [
        # easeOutExpo: sharp mechanical snap, no bounce
        "nervOut, 0.16, 1, 0.3, 1"
      ];
      animation = [
        "windows,    1, 3, nervOut, popin 85%"
        "windowsIn,  1, 3, nervOut, popin 85%"
        "windowsOut, 1, 2, nervOut, popin 85%"
        "fade,       1, 3, nervOut"
        "workspaces, 1, 4, nervOut, slide"
        "border,     1, 5, nervOut"
      ];
    };
  };
}
```

### Wallpaper Path Update (wallpaper.nix)

The NERV Command wallpaper selection: pick from `Neon Genesis Evangelion (Pics)/` folder. Good candidates visible in assets: `072b2093a5a10c8c7b10b8e94d01afb6.jpg` (dark institutional look) or others. Recommendation: copy the chosen image to `assets/wallpaper.jpg` (or a named path) so both Stylix and hyprpaper share the same reference without duplication.

```nix
# modules/home/wallpaper.nix  (update wp path)
{ ... }:
let
  wp = ../../assets/wallpaper.jpg;  # Phase 3: ensure this points to NERV Command image
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wp}" ];
      wallpaper = [ ",${wp}" ];
    };
  };
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `nerdfonts.override { fonts = ["JetBrainsMono"]; }` | `pkgs.nerd-fonts.jetbrains-mono` | nixpkgs 2024 split | Old syntax fails to build; new syntax has blank-glyph bug on some unstable revisions |
| Manually setting `programs.waybar.style = "..."` | `programs.waybar.style = lib.mkAfter "..."` | Stylix integration | Plain assignment conflicts with Stylix-generated CSS; mkAfter is required |
| `stylix.targets.hyprland.hyprpaper.enable = false` | `stylix.targets.hyprpaper.enable = false` | Module was separated | The hyprpaper sub-target is now its own Stylix module, not nested under hyprland |
| `decoration.drop_shadow = false` | `decoration.shadow.enabled = false` | Hyprland ~v0.41 | Shadow moved from flat bool to nested attrset; old syntax may warn or fail |
| `col.active_border = "0xFFff9830"` | `col.active_border = "rgba(ff9830ff)"` | Hyprland color format standardization | The `0x` prefix format may still work but `rgba()` is canonical |

**Deprecated/outdated:**
- `nerdfonts.override { ... }`: removed; use `nerd-fonts.<name>`.
- `hardware.pulseaudio.enable`: renamed to `services.pulseaudio.enable` (Phase 2 already uses correct name).
- `drop_shadow = true/false`: replaced by `shadow.enabled = true/false` in Hyprland v0.41+.

---

## Open Questions

1. **Matisse EB exact PostScript name after installation**
   - What we know: The font file typically uses `MatissePro-EB` as the family name in its metadata.
   - What's unclear: The exact string that `fc-list` and fontconfig will expose depends on the specific OTF copy. Some copies show `FOT-Matisse Pro EB`, others `MatissePro-EB`.
   - Recommendation: Build with the font installed; run `fc-list | grep -i matisse` and update the `name` field accordingly. Plan task should include a verification step for this.

2. **nerd-fonts.jetbrains-mono blank glyph bug resolution status**
   - What we know: Issue #366979 filed December 2024, closed. Exact fix status not confirmed — the WebFetch of the issue page returned incomplete content.
   - What's unclear: Whether the fix is present in the nixos-unstable commit the flake will resolve against.
   - Recommendation: Test after build. If icons are blank, fall back to `pkgs.nerd-fonts.hack` (`"Hack Nerd Font Mono"`) as a substitute. Document the fallback in the task.

3. **Which specific NERV Command wallpaper to select from the asset collection**
   - What we know: `Neon Genesis Evangelion (Pics)/` contains ~20+ images; `Steins;Gate (Pics)/` is out of scope.
   - What's unclear: The user has not declared a preferred wallpaper. The PROF-01 requirement says "NERV Command wallpapers from asset collection."
   - Recommendation: The planner should pick one dark/black-dominant JPG from the EVA folder (e.g., `072b2093a5a10c8c7b10b8e94d01afb6.jpg`) as the default and note others as alternatives. Alternatively, leave as a task action where the developer picks during implementation.

4. **Hyprland shadow syntax (v0.41+ vs. earlier)**
   - What we know: `decoration.shadow.enabled = false` is the current syntax; `drop_shadow = false` is the old form.
   - What's unclear: Exact Hyprland version shipped by nixos-unstable at build time.
   - Recommendation: Use `decoration.shadow.enabled = false` (current form). If build fails with "option not found," fall back to `decoration.drop_shadow = false`. A `lib.mkDefault` can be used to make this non-fatal.

---

## Sources

### Primary (HIGH confidence)
- https://nix-community.github.io/stylix/configuration.html — `stylix.fonts.*` API, `config.lib.stylix.colors` access, `autoEnable` behavior
- https://nix-community.github.io/stylix/options/modules/waybar.html — `stylix.targets.waybar` full options: enable, addCss, colors, fonts, opacity sub-options
- https://nix-community.github.io/stylix/options/modules/hyprland.html — `stylix.targets.hyprland` options: colors.enable, image.enable, hyprpaper.enable
- https://nix-community.github.io/stylix/options/modules/hyprlock.html — `stylix.targets.hyprlock` options: colors.enable, image.enable
- https://nix-community.github.io/stylix/options/modules/mako.html — `stylix.targets.mako` options: colors, fonts, opacity
- https://nix-community.github.io/stylix/options/modules/rofi.html — `stylix.targets.rofi` options: colors, fonts, opacity
- https://nix-community.github.io/stylix/options/modules/hyprpaper.html — `stylix.targets.hyprpaper` as separate module with `enable` and `image.enable`
- https://nix-community.github.io/stylix/tricks.html — `lib.mkAfter` pattern for CSS extension
- https://wiki.hypr.land/Configuring/Animations/ — animation/bezier syntax, popin/slide styles, SPEED parameter semantics
- https://wiki.nixos.org/wiki/Fonts — NixOS font packaging guidelines, `fonts.packages` option
- https://yildiz.dev/posts/packing-custom-fonts-for-nixos/ — `stdenvNoCC.mkDerivation` pattern for TTF/OTF packaging

### Secondary (MEDIUM confidence)
- https://github.com/nix-community/stylix/discussions/1152 — `lib.mkForce` pattern for Hyprland border color override (community-verified)
- https://discourse.nixos.org/t/use-specific-base16-colours-from-stylix-in-configuration/49531 — `config.lib.stylix.colors.base09` access pattern (multiple community confirmations)
- https://en.fontworks.co.jp/products/evamatisse/ — Matisse EB official Fontworks product page (confirms discontinued, personal-use license)
- https://archive.org/details/qjwi3h — Internet Archive copy of official Fontworks Matisse EB TTF release
- https://github.com/nix-community/stylix/issues/499 — Stylix hyprpaper autostart conflict analysis

### Tertiary (LOW confidence — flag for validation)
- https://github.com/NixOS/nixpkgs/issues/366979 — nerd-fonts.jetbrains-mono blank glyph bug; issue closed but fix delivery not confirmed
- Community bezier curve values for `easeOutExpo` (0.16, 1, 0.3, 1) — widely used in dotfiles but not sourced from official Hyprland wiki directly

---

## Metadata

**Confidence breakdown:**
- Standard stack (Stylix API, font declarations): HIGH — verified against official Stylix docs
- Architecture (lib.mkAfter/mkForce patterns): HIGH — verified in Stylix docs + community confirmation
- Font packaging (custom derivation): HIGH — standard NixOS pattern, well-documented
- Matisse EB font availability/licensing: MEDIUM — font exists and is circulated; exact PostScript name needs live verification
- nerd-fonts.jetbrains-mono bug status: LOW — issue closed but resolution not confirmed; plan must include fallback
- Animation bezier values: MEDIUM — standard easing values cross-verified across multiple dotfiles

**Research date:** 2026-04-16
**Valid until:** 2026-05-16 (30 days — Stylix API is stable; nixos-unstable font packages can shift; re-check nerd-fonts bug status at plan time)
