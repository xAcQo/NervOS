# Phase 2: Desktop Shell - Research

**Researched:** 2026-04-15
**Domain:** NixOS + home-manager declarative configuration of a Hyprland Wayland desktop shell (status bar, launcher, terminal, file manager, notifications, lock screen, wallpaper, screenshots, audio, network, clipboard, keybinds)
**Confidence:** HIGH (ecosystem is mature and well-trodden; every tool in scope has an upstream home-manager/NixOS module)

## Summary

Phase 2 builds the complete working desktop environment on top of the Phase 1 foundation (Hyprland + Stylix + home-manager). Every tool in scope (waybar, rofi, kitty, Thunar, mako, hyprlock, hypridle, swww/hyprpaper, grimblast, PipeWire, NetworkManager, cliphist) has a first-class NixOS or home-manager module — there is essentially no need to drop down to `home.file` / raw config file management. The correct split is: **system services** (audio, networking, PAM, thunar+gvfs, xdg-portal) belong in `modules/nixos/`; **user-facing UI tools** (waybar, rofi, kitty, mako, hyprlock, hypridle, cliphist, wallpaper daemon) belong in `modules/home/`.

The single largest risk is **Stylix target collisions**. Stylix auto-enables theming for nearly every tool in this phase (waybar, rofi, kitty, mako, hyprlock, GTK/Thunar). That is desirable — it means we get consistent EVA theming for free — but it also means manual `style.css` or color overrides in individual modules will fight Stylix. The correct pattern is: let Stylix own colors/fonts; override per-target with `stylix.targets.<name>.enable = false` only when a Phase 3 EVA-specific look demands it. For Phase 2 we embrace Stylix defaults.

Two ecosystem decisions are worth flagging up-front: (1) **rofi vs rofi-wayland** — upstream rofi added Wayland support in 2025, but nixpkgs still ships `rofi-wayland` as the blessed Wayland variant and plugin ecosystems are more stable there; use `rofi-wayland`. (2) **swww vs hyprpaper** — swww is archived as of late 2024/2025; hyprpaper is the actively-maintained first-party Hyprland wallpaper daemon and has a home-manager `services.hyprpaper` module. Use **hyprpaper**, not swww, despite requirement DESK-07 mentioning swww by name.

**Primary recommendation:** Use upstream NixOS/home-manager modules exclusively (no hand-rolled `home.file` configs for any tool in scope). Let Stylix own theming. Use hyprpaper (not swww). Use rofi-wayland. Split modules/nixos ↔ modules/home along the system-service ↔ user-session axis.

## Standard Stack

### Core (one module per requirement)

| Tool | Scope | Module | Purpose | Why Standard |
|------|-------|--------|---------|--------------|
| waybar | home-manager | `programs.waybar` | Status bar: workspaces, clock, volume, network, battery | Official home-manager module; Stylix autotheme target |
| rofi-wayland | home-manager | `programs.rofi` (with `package = pkgs.rofi-wayland`) | App launcher + clipboard picker | Default Wayland launcher on Hyprland; pairs natively with cliphist |
| kitty | home-manager | `programs.kitty` | Terminal | Stylix autotheme target; fastest GPU-accelerated terminal |
| Thunar | NixOS | `programs.thunar` + plugins | File manager | Lightweight GTK3 FM; works on Wayland; auto-picks up Stylix GTK theming |
| mako | home-manager | `services.mako` | Notification daemon | Stylix autotheme target; layer-shell native |
| hyprlock | home-manager | `programs.hyprlock` | Lock screen | First-party Hyprland tool; NixOS module auto-configures PAM |
| hypridle | home-manager | `services.hypridle` | Idle daemon (triggers hyprlock on timeout) | First-party pairing with hyprlock |
| hyprpaper | home-manager | `services.hyprpaper` | Wallpaper daemon | First-party, actively maintained; swww is archived |
| grimblast | system package | `pkgs.grimblast` (from `hyprwm/contrib`) | Screenshot helper | Wraps grim+slurp+hyprctl+wl-copy; blessed by Hyprland |
| PipeWire + wireplumber | NixOS | `services.pipewire` | Audio server | Default modern audio stack; replaces PulseAudio |
| NetworkManager | NixOS | `networking.networkmanager` + `programs.nm-applet` | Network management + tray | Standard NixOS networking; nm-applet provides waybar tray icon |
| cliphist | home-manager | `services.cliphist` | Clipboard history | Wayland-native; rofi picker integration is one-liner |

### Supporting

| Tool | Scope | Module/Package | Purpose | When to Use |
|------|-------|----------------|---------|-------------|
| wl-clipboard | system pkg | `pkgs.wl-clipboard` | Provides `wl-copy`/`wl-paste` | Required by grimblast and cliphist |
| slurp | system pkg | `pkgs.slurp` | Region selector | Required by grimblast `area` target |
| grim | system pkg | `pkgs.grim` | Screenshot primitive | Required by grimblast |
| hyprpicker | system pkg | `pkgs.hyprpicker` | Screen freeze during area select | Optional but recommended grimblast dep |
| jq | system pkg | `pkgs.jq` | JSON | Grimblast dependency |
| libnotify | system pkg | `pkgs.libnotify` | `notify-send` | Grimblast + mako test notifications |
| gvfs | NixOS | `services.gvfs.enable` | Mount/trash for Thunar | Required for Thunar removable-media + trash |
| tumbler | NixOS | `services.tumbler.enable` | Thumbnails | Image previews in Thunar |
| thunar-volman | NixOS | `programs.thunar.plugins` | Removable media auto-mount | Expected file-manager UX |
| thunar-archive-plugin | NixOS | `programs.thunar.plugins` | Archive ops in Thunar | Expected file-manager UX |
| brightnessctl | system pkg | `pkgs.brightnessctl` | Backlight control | `XF86MonBrightness*` keys |
| wireplumber CLI (`wpctl`) | shipped by pipewire | — | Volume control from keybinds | `XF86AudioRaiseVolume`/etc. |
| playerctl | system pkg | `pkgs.playerctl` | Media keys (play/pause/next) | `XF86AudioPlay` etc. |
| polkit agent | home-manager | `hyprpolkitagent` service | Graphical polkit prompts | Sudo prompts in GUI apps (nm-connection-editor, Thunar mount) |
| xdg-desktop-portal-gtk | NixOS | extraPortals | File pickers for non-Hyprland apps | Already paired with xdg-desktop-portal-hyprland in Phase 1 |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| hyprpaper | swww | swww is archived; only use if animated transitions between wallpapers are required (which they're not for Phase 2 -- Phase 3 may revisit) |
| rofi-wayland | wofi, fuzzel, anyrun | wofi/fuzzel are simpler but rofi has best plugin ecosystem (needed for cliphist+emoji+calc in later phases); decision: stay rofi |
| mako | dunst, swaync | dunst X11-first; swaync has richer UI but heavier. Mako is sway/Hyprland-native and Stylix-themed |
| hyprlock | swaylock-effects, gtklock | hyprlock is first-party, GPU-accelerated, Stylix-themed |
| grimblast | hyprshot, manual grim+slurp | hyprshot is fine but less featureful; manual pipeline duplicates grimblast's logic |
| Thunar | nautilus, nemo, pcmanfm-qt | Thunar is lightest + GTK3 (Stylix integrates). Nautilus pulls GNOME session deps |
| NetworkManager + nm-applet | iwd + iwgtk, connman | NM is de-facto NixOS default; nm-applet has waybar tray integration out of the box |
| waybar | eww, ags, hyprpanel | Waybar is simplest declarative JSON+CSS; Stylix supports it. Others are more powerful but custom-scripted |

**Installation (aggregate):** `home-manager` modules listed above enable everything. System packages (`environment.systemPackages`) needed: `grim slurp grimblast hyprpicker wl-clipboard jq libnotify brightnessctl playerctl`.

## Architecture Patterns

### Recommended Project Structure

```
modules/
├── nixos/                    # System-wide concerns
│   ├── hyprland.nix          # (exists) compositor + portal
│   ├── stylix.nix            # (exists) theming foundation
│   ├── audio.nix             # NEW: pipewire + wireplumber + rtkit
│   ├── network.nix           # NEW: NetworkManager + nm-applet program
│   ├── file-manager.nix      # NEW: programs.thunar + gvfs + tumbler
│   └── gpu.nix               # (exists)
├── home/                     # User session concerns
│   ├── default.nix           # (exists) aggregates imports
│   ├── hyprland.nix          # (exists) extend with media/screenshot/app keybinds
│   ├── waybar.nix            # NEW: status bar
│   ├── rofi.nix              # NEW: launcher + clipboard picker config
│   ├── kitty.nix             # NEW: terminal
│   ├── mako.nix              # NEW: notifications
│   ├── lock.nix              # NEW: hyprlock + hypridle together
│   ├── wallpaper.nix         # NEW: hyprpaper
│   └── clipboard.nix         # NEW: cliphist
hosts/nervos/
└── configuration.nix         # imports the new modules/nixos/*.nix
```

**Rationale for split:** PAM, audio, networking, dbus-integrated file-manager services are system-level and must persist across users. Status bar, launcher, terminal, notifications, lock screen UI, wallpaper, clipboard history are per-user session state and belong in home-manager.

### Pattern 1: Import-only aggregator modules

Each new module file is a self-contained unit that enables one tool. `modules/home/default.nix` grows imports; `hosts/nervos/configuration.nix` grows imports. No cross-module coupling except via well-defined module options.

```nix
# modules/home/default.nix
{ ... }:
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
    ./kitty.nix
    ./mako.nix
    ./lock.nix
    ./wallpaper.nix
    ./clipboard.nix
  ];
}
```

### Pattern 2: Let Stylix own theming; each module configures *behavior* only

**What:** Do not hard-code colors, fonts, or opacity in individual tool configs. Stylix auto-applies them.
**When to use:** Always in Phase 2. Phase 3 may opt specific targets out for EVA-specific visuals.
**Example:**

```nix
# modules/home/waybar.nix -- NOTE: no colors, no style.css
{ ... }:
{
  programs.waybar = {
    enable = true;
    # Stylix auto-generates style.css via stylix.targets.waybar
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];
      clock.format = "{:%Y-%m-%d %H:%M}";
      pulseaudio = {
        format = "{volume}% {icon}";
        on-click = "pavucontrol";
      };
      network.format-wifi = "{essid} ({signalStrength}%)";
      battery = {
        format = "{capacity}% {icon}";
        states = { warning = 30; critical = 15; };
      };
    };
  };
}
```

### Pattern 3: PAM auto-wiring via `programs.hyprlock.enable`

**What:** The NixOS `programs.hyprlock` module exists specifically to set `security.pam.services.hyprlock = {}` for us. Do NOT install hyprlock as a plain package.
**When:** Any time home-manager declares `programs.hyprlock.enable = true`, add `programs.hyprlock.enable = true` on the NixOS side too.
**Example:**

```nix
# modules/nixos/hyprland.nix (extend)
programs.hyprlock.enable = true;   # installs binary + sets up PAM
```

```nix
# modules/home/lock.nix
{ ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      background = [{ path = "screenshot"; blur_passes = 3; }];
      input-field = [{
        size = "200, 50";
        position = "0, -80";
        placeholder_text = "Pilot authentication";
        fade_on_empty = false;
      }];
      label = [{
        text = "NERV COMMAND";
        position = "0, 160";
        halign = "center"; valign = "center";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        { timeout = 300; on-timeout = "loginctl lock-session"; }
        { timeout = 600; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
      ];
    };
  };
}
```

### Pattern 4: nm-applet via NixOS program module + autostart via Hyprland

**What:** `programs.nm-applet.enable = true` installs the applet + sets XDG autostart. But Hyprland does not execute XDG autostart by default, so add `exec-once = nm-applet --indicator` in Hyprland settings.

### Pattern 5: cliphist → rofi wiring

**What:** `services.cliphist.enable = true` starts a systemd user service watching the clipboard. `Super+V` keybind pipes `cliphist list` into `rofi -dmenu` and the selection back into `cliphist decode | wl-copy`.

```nix
# modules/home/hyprland.nix (add to bind =)
"$mainMod, V, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
```

### Anti-Patterns to Avoid

- **Writing raw `~/.config/waybar/config.jsonc`:** Use `programs.waybar.settings` instead — you lose nothing and get type-checking.
- **Hard-coding colors in kitty/rofi/mako:** Stylix will overwrite them on rebuild and users get confused. Set via Stylix only.
- **Using `swww` for wallpaper:** Archived upstream. Use hyprpaper.
- **Installing hyprlock as a plain package:** PAM won't be wired. Always use `programs.hyprlock.enable` on NixOS side.
- **Skipping `services.gvfs.enable` for Thunar:** Mounts silently fail, trash doesn't work, network shares invisible.
- **Setting `hardware.pulseaudio.enable = true` alongside pipewire:** They fight. Use `services.pulseaudio.enable = false` explicitly (the option was renamed from `hardware.pulseaudio` in 24.11; on unstable it's `services.pulseaudio`).
- **Forgetting `bindel` flag for volume keys:** Without it, volume keys don't repeat on hold.
- **Adding `networkmanagerapplet` to `home.packages`:** Icons won't resolve. Use the NixOS `programs.nm-applet` module instead.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Waybar style.css | Custom CSS with EVA colors | Stylix waybar target (`stylix.targets.waybar.enable` is auto-on) | Stylix already generates from base16 palette; collisions guaranteed otherwise |
| Screenshot pipeline | Bash script chaining grim+slurp+wl-copy+notify-send | `grimblast` from `hyprwm/contrib` | Edge cases: active-window geometry, hyprpicker freeze, notification, save+copy — all handled |
| Clipboard history | Polling script / xclip wrappers | `services.cliphist` + rofi | Wayland has no clipboard-polling API; cliphist uses wl-clipboard's watch mode correctly |
| Lock screen auth | Custom PAM config | `programs.hyprlock.enable` (NixOS) | Module literally exists to set `security.pam.services.hyprlock = {}` |
| Idle→lock timer | Shell loop / systemd timer | `services.hypridle` | Handles DPMS + before-sleep + on-resume transitions correctly |
| Audio routing | PulseAudio + custom modules | `services.pipewire` with `pulse.enable = true` | PipeWire provides PA API; no app changes needed |
| Keybind media-key repeat | Scripting held-key detection | Hyprland `bindel =` (the `e` = repeat, `l` = locked) flags | Built into Hyprland's bind system |
| Network tray icon | Custom waybar script hitting nmcli | `programs.nm-applet` + waybar `tray` module | nm-applet exposes standard StatusNotifierItem |

**Key insight:** The Hyprland + NixOS ecosystem has spent 2+ years productizing every piece of this phase. Any time we feel tempted to write a shell script or a `home.file."..." = ...`, there is a `programs.*` or `services.*` module that does it better.

## Common Pitfalls

### Pitfall 1: Stylix target conflicts with manual styling

**What goes wrong:** You write `programs.waybar.style = "..."` or put colors in `programs.kitty.settings`. On next rebuild, Stylix overwrites them — or they silently stack and produce ugly results.
**Why it happens:** Stylix's `autoEnable = true` (default) turns on theming for every supported target, including waybar, rofi, kitty, mako, hyprlock, GTK (Thunar).
**How to avoid:** For Phase 2, set *no* colors anywhere except in `modules/nixos/stylix.nix`. If Phase 3 needs a custom look for one tool, use `stylix.targets.<tool>.enable = false` to opt that tool out entirely.
**Warning signs:** Rebuild succeeds but colors don't match; `~/.config/waybar/style.css` differs from what you wrote.

### Pitfall 2: nm-applet tray icon missing in waybar

**What goes wrong:** Waybar shows an empty tray module; `nm-applet` is running.
**Why it happens:** nm-applet autostarts via XDG spec, but Hyprland doesn't implement XDG autostart natively. Or the applet is installed as a user package without icon theme paths.
**How to avoid:** Use `programs.nm-applet.enable = true` on the NixOS side (not home-manager package), and add `exec-once = nm-applet --indicator` in Hyprland `settings.exec-once`. Ensure waybar config includes `"tray"` in `modules-right`.
**Warning signs:** `pgrep nm-applet` returns a PID but waybar tray is empty.

### Pitfall 3: hyprlock accepts no input / blank screen

**What goes wrong:** hyprlock launches but password field doesn't accept keystrokes, or unlock fails silently.
**Why it happens:** PAM is not configured. On NixOS the home-manager-installed binary cannot authenticate without `security.pam.services.hyprlock = {}`.
**How to avoid:** Always pair `programs.hyprlock.enable = true` on the NixOS side (which auto-sets PAM) with the home-manager configuration.
**Warning signs:** journalctl shows `pam_authenticate: Authentication service cannot retrieve authentication info`.

### Pitfall 4: PipeWire vs PulseAudio option name drift

**What goes wrong:** Build fails with "option `hardware.pulseaudio.enable` does not exist" or audio silently runs through PA instead of PW.
**Why it happens:** On nixos-unstable the PulseAudio options were moved from `hardware.pulseaudio.*` to `services.pulseaudio.*`. The correct disable line is `services.pulseaudio.enable = false`.
**How to avoid:** Use the current option name; also set `security.rtkit.enable = true` (required for PipeWire realtime priority).
**Warning signs:** `pactl info` says server is "PulseAudio" not "PulseAudio (on PipeWire ...)".

### Pitfall 5: Thunar can't mount USB / empty "Network" sidebar

**What goes wrong:** Plug in USB drive, Thunar shows it but click-to-mount fails; or right-click "Open in Terminal" does nothing.
**Why it happens:** `services.gvfs.enable` and/or `thunar-volman` plugin missing; polkit agent not running.
**How to avoid:** Enable gvfs, tumbler, thunar-volman, thunar-archive-plugin; run hyprpolkitagent (or polkit_gnome) in Hyprland `exec-once`.
**Warning signs:** Mount dialog appears then vanishes; `journalctl --user` shows polkit auth failures.

### Pitfall 6: hyprlock background = "screenshot" shows black

**What goes wrong:** Lock screen is fully black instead of blurred last-frame.
**Why it happens:** Hyprland requires `misc:allow_session_lock_restore = true` in some versions, or permission to capture the screen is missing.
**How to avoid:** Confirm `programs.hyprland.enable` has xwayland (done in Phase 1). If still black, set `background.path = "<path to wallpaper>"` instead.
**Warning signs:** hyprlock logs "could not grab screen copy".

### Pitfall 7: Screenshot keybind fires but clipboard is empty

**What goes wrong:** `Print` key triggers but `wl-paste` returns nothing.
**Why it happens:** `wl-clipboard` is not installed in the user env, or grimblast was called with `save` instead of `copy`/`copysave`.
**How to avoid:** Install `wl-clipboard` system-wide; use `grimblast copy area` (PrtSc area → clipboard) and `grimblast copy screen` (Shift+PrtSc → clipboard). Per requirements these go to clipboard only.
**Warning signs:** `wl-paste` empty; notification "screenshot saved" but no file appears (if misconfigured).

### Pitfall 8: cliphist empty after reboot / service not running

**What goes wrong:** `Super+V` shows empty list.
**Why it happens:** cliphist systemd user service depends on `wayland-session.target` which must be reached. Under home-manager this is automatic if `services.cliphist.enable = true` but the `systemdTargets` option must include `hyprland-session.target` when using Hyprland.
**How to avoid:** Set `services.cliphist.systemdTargets = [ "hyprland-session.target" ];` (the default may be `graphical-session.target` which Hyprland does reach, but being explicit avoids regressions).
**Warning signs:** `systemctl --user status cliphist` shows inactive.

### Pitfall 9: Waybar invisible / wrong size on HiDPI

**What goes wrong:** Bar renders at 1px tall or off-screen.
**Why it happens:** Stylix font size applies; `height` option in waybar overrides. Interaction with output scale.
**How to avoid:** Let Stylix set the font; set `height` explicitly (e.g. 30); do not set `width`.

### Pitfall 10: rofi-wayland plugins fail to load

**What goes wrong:** `rofi -show calc` or `rofi -show emoji` gives "Mode X not found".
**Why it happens:** Plugins built against `pkgs.rofi` cannot load into `pkgs.rofi-wayland`. Known nixpkgs gap.
**How to avoid:** For Phase 2 only the built-in `drun` and `dmenu` modes are required — no plugin issues. Defer plugin use to a later phase, or use a nixpkgs overlay that rebuilds plugins against `rofi-wayland-unwrapped`.

## Code Examples

### Audio (NixOS)

```nix
# modules/nixos/audio.nix
# Source: https://wiki.nixos.org/wiki/PipeWire
{ ... }:
{
  services.pulseaudio.enable = false;   # replaces old hardware.pulseaudio
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;                 # PulseAudio API shim
    wireplumber.enable = true;
    # jack.enable = true;                # enable only if pro-audio users
  };
}
```

### NetworkManager + applet (NixOS)

```nix
# modules/nixos/network.nix
# Source: https://wiki.nixos.org/wiki/NetworkManager
{ ... }:
{
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;   # installs applet + sets XDG autostart

  # Add pilot user to networkmanager group (in host configuration.nix):
  # users.users.pilot.extraGroups = [ "networkmanager" ];
}
```

### Thunar (NixOS)

```nix
# modules/nixos/file-manager.nix
# Source: https://wiki.nixos.org/wiki/Thunar
{ pkgs, ... }:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
```

### Waybar (home-manager)

```nix
# modules/home/waybar.nix
# Source: https://github.com/nix-community/home-manager/blob/master/modules/programs/waybar.nix
{ ... }:
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
    # NO style block -- Stylix owns this.
  };
}
```

### Rofi (home-manager)

```nix
# modules/home/rofi.nix
# Source: https://github.com/nix-community/home-manager/blob/master/modules/programs/rofi
{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;   # REQUIRED for Wayland
    terminal = "${pkgs.kitty}/bin/kitty";
    # Stylix handles theming; do not set theme here
  };
}
```

### Kitty (home-manager)

```nix
# modules/home/kitty.nix
{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      # NO font, NO colors -- Stylix provides via stylix.targets.kitty
    };
  };
}
```

### Mako (home-manager)

```nix
# modules/home/mako.nix
# Source: https://github.com/nix-community/home-manager/blob/master/modules/services/mako.nix
{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      anchor = "top-right";
      margin = "10";
      border-radius = 6;
      # NO color options -- Stylix handles via stylix.targets.mako
    };
  };
}
```

### Hyprpaper (home-manager)

```nix
# modules/home/wallpaper.nix
# Source: https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
{ config, ... }:
let
  wp = ../../assets/wallpaper.jpg;  # same as Stylix wallpaper for consistency
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wp}" ];
      wallpaper = [ ",${wp}" ];   # "," = all monitors
    };
  };
}
```

### Cliphist (home-manager)

```nix
# modules/home/clipboard.nix
# Source: https://github.com/nix-community/home-manager/blob/master/modules/services/cliphist.nix
{ ... }:
{
  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = [ "hyprland-session.target" ];
  };
}
```

### Hyprland extension: screenshot + media keys + new keybinds

```nix
# modules/home/hyprland.nix  (extend the existing settings.bind list)
# Source: https://wiki.hypr.land/Configuring/Binds/
# Additions -- merged with existing binds from Phase 1:

settings = {
  exec-once = [
    "nm-applet --indicator"
    "hyprpolkitagent"
  ];

  bind = [
    # ...existing binds...
    "$mainMod, SPACE, exec, rofi -show drun"
    "$mainMod, L, exec, loginctl lock-session"
    "$mainMod, V, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
    # Screenshots -- to clipboard per requirements
    ", Print, exec, grimblast copy area"
    "SHIFT, Print, exec, grimblast copy screen"
  ];

  bindel = [
    ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ", XF86MonBrightnessUp,  exec, brightnessctl s +5%"
    ", XF86MonBrightnessDown,exec, brightnessctl s 5%-"
  ];

  bindl = [
    ", XF86AudioPlay,  exec, playerctl play-pause"
    ", XF86AudioNext,  exec, playerctl next"
    ", XF86AudioPrev,  exec, playerctl previous"
  ];
};
```

Bind-flag reference: `bindel` = repeat on hold + works while locked-input; `bindl` = works even when screen is locked (needed for media keys on lock screen).

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `hardware.pulseaudio.enable` | `services.pulseaudio.enable = false` + pipewire | 24.11 | Build error if you use old name on unstable |
| swww for wallpaper | hyprpaper | swww archived late 2024 | Must not pin swww; it gets no fixes |
| `rofi` for Wayland | `rofi-wayland` (still separate package in nixpkgs) | Upstream rofi gained Wayland in 2025; nixpkgs still uses fork | Use `pkgs.rofi-wayland` |
| Manual PAM config for hyprlock | `programs.hyprlock.enable` on NixOS | 24.05+ | One-liner; don't copy old tutorials |
| `hardware.sound.enable` | deprecated; not needed with pipewire | 24.05 | Remove from any old config references |
| dunst on Wayland | mako | long-established | dunst works but has X11 assumptions |

**Deprecated/outdated:**
- **swww**: archived, no maintenance. Replaced by hyprpaper.
- **hardware.pulseaudio**: renamed to services.pulseaudio.
- **hardware.sound.enable**: removed; pipewire doesn't need it.
- **`bind = ... ,e,...` single-letter flag**: replaced by distinct `bindel`/`bindl`/`bindr` variants.

## Open Questions

1. **Does Stylix's waybar target produce output that satisfies "EVA look" goals, or will Phase 3 need per-target opt-out?**
   - What we know: Stylix writes `style.css` from base16 palette; the NERV Command palette is already defined.
   - What's unclear: whether the default CSS layout matches Phase 3's "HUD with orange accents" vision.
   - Recommendation: Accept Stylix defaults in Phase 2. Phase 3 may set `stylix.targets.waybar.enable = false` and ship a custom CSS if needed. Defer the decision.

2. **Should Phase 2 include a polkit agent, or defer to Phase 3?**
   - What we know: Thunar mount, nm-connection-editor, and mount prompts require a graphical polkit agent.
   - What's unclear: whether the `/gsd:discuss-phase` step treats this as in-scope.
   - Recommendation: Include `hyprpolkitagent` service in Phase 2 — without it, Success Criterion #4 (WiFi without terminal) may break when NM asks for admin auth.

3. **Is `hardware.bluetooth.enable` in scope?**
   - What we know: Not in the requirement list (DESK-01..11 + KEY-\*).
   - Recommendation: Out of scope for Phase 2.

4. **Which user (`pilot`) group memberships are needed?**
   - What we know: `networkmanager` (for NM without sudo), `video` (brightnessctl), `audio` (legacy; not needed with pipewire but harmless), `input` (for some peripherals).
   - Recommendation: Set `users.users.pilot.extraGroups = [ "wheel" "networkmanager" "video" ]` in host configuration. Confirm during planning.

5. **Should screenshot files also be saved to disk, or clipboard-only?**
   - What we know: Success Criterion #3 explicitly says "capture to clipboard". Nothing about saving.
   - Recommendation: Clipboard-only (`grimblast copy ...`). If disk-save is later wanted, change to `grimblast copysave ...`.

## Sources

### Primary (HIGH confidence)
- https://wiki.nixos.org/wiki/PipeWire — official NixOS wiki, pipewire config
- https://wiki.nixos.org/wiki/NetworkManager — official NixOS wiki
- https://wiki.nixos.org/wiki/Thunar — official NixOS wiki, thunar+gvfs setup
- https://wiki.nixos.org/wiki/Waybar — official NixOS wiki
- https://wiki.nixos.org/wiki/Hyprpaper — official NixOS wiki
- https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/ — official Hyprland wiki
- https://wiki.hypr.land/Hypr-Ecosystem/hypridle/ — official Hyprland wiki
- https://wiki.hypr.land/Configuring/Binds/ — official bind flag reference
- https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/wayland/hyprlock.nix — confirms programs.hyprlock auto-sets PAM
- https://github.com/nix-community/home-manager/blob/master/modules/programs/waybar.nix — module source
- https://github.com/nix-community/home-manager/blob/master/modules/services/hyprpaper.nix — module source
- https://github.com/nix-community/home-manager/blob/master/modules/services/cliphist.nix — module source
- https://github.com/nix-community/home-manager/blob/master/modules/programs/hyprlock.nix — module source
- https://github.com/hyprwm/contrib/blob/main/grimblast/grimblast.1.scd — grimblast manpage
- https://nix-community.github.io/stylix/options/platforms/home_manager.html — stylix autoEnable behavior confirmed

### Secondary (MEDIUM confidence)
- https://discourse.nixos.org/t/programs-program-enable-doesnt-auto-start-waybar-and-nm-applet-with-hyprland-and-sddm/32768 — nm-applet autostart gotcha under Hyprland
- https://discourse.nixos.org/t/home-manager-services-cliphist-not-working/64399 — cliphist systemdTargets for Hyprland
- https://github.com/nix-community/home-manager/issues/5899 — hyprlock/hypridle home-manager issue history (systemd env PATH)
- https://haseebmajid.dev/posts/2025-01-15-til-how-to-fix-pipewire-wireplumber-issues-on-nixos/ — pipewire troubleshooting (Jan 2025)

### Tertiary (LOW confidence)
- https://x.com/vaxryy/status/1821616620373963162 — Vaxry (Hyprland author) recommending alternatives to hyprpaper is ambiguous; swww's archival is the harder signal. Flag: verify current state of swww repo at plan time.
- https://petronellatech.com/blog/hyprland-setup-guide-install-configure-2026/ — generic setup guide; useful for cross-check, not authoritative.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — every tool has a verified upstream module with source-code confirmation.
- Architecture: HIGH — module split follows well-established NixOS conventions; Phase 1 structure already proves the pattern works here.
- Pitfalls: HIGH for Stylix conflicts, PAM, nm-applet, pulseaudio rename (all verified in multiple sources); MEDIUM for cliphist systemdTargets edge case.
- swww vs hyprpaper: MEDIUM — swww archival state should be re-verified at plan time (single recent signal).

**Research date:** 2026-04-15
**Valid until:** 2026-05-15 (30 days — stable ecosystem, but nixos-unstable option renames can happen; re-verify pulseaudio option name at plan time if rebuild fails)
