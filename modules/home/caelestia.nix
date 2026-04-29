{ ... }:
{
  # Caelestia shell: unified QuickShell bar + launcher + notifications + lock + sidebar.
  # Replaces the hand-rolled waybar/rofi/mako/hyprlock/hyprpaper/cliphist stack.
  #
  # Theming note: Stylix does NOT target caelestia. Stylix still owns kitty,
  # GTK, Qt, cursor, and the system font stack. Caelestia themes its own QML
  # surfaces via programs.caelestia.settings. Do NOT try to bridge them here;
  # pilot-specific color injection is a later phase (matugen + specialisations).
  programs.caelestia = {
    enable = true;

    # Start via systemd user service bound to graphical-session.target.
    # Matches the Phase 2 waybar pattern (systemd.enable = true, no exec-once).
    # Do NOT also add `caelestia` to Hyprland exec-once -- that double-starts it.
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };

    # Put the `caelestia` CLI on PATH so Hyprland keybinds can invoke it
    # (launcher toggle, clipboard, screenshot, record). Handled in Plan 02.
    cli.enable = true;

    settings = {
      bar.status.showBattery = true;
      paths.wallpaperDir = "~/Pictures/wallpapers";
      # Phase 3: NERV Command font identity.
      # sans = caelestia bar/launcher display font; mono = OSD/terminal surfaces.
      # Do NOT set "material" (breaks Material Symbols Rounded icon rendering).
      appearance.font.family = {
        sans = "MatissePro-EB";
        mono = "JetBrainsMono Nerd Font Mono";
      };
    };
  };

  # Provision NGE wallpapers for caelestia to cycle through.
  # Keys are relative to homeDirectory (/home/pilot) — no tilde.
  home.file = {
    "Pictures/wallpapers/4-21012F64SA53.jpg".source =
      ../../"Neon Genesis Evangelion (Pics)"/"4-21012F64SA53.jpg";
    "Pictures/wallpapers/numbers-interfaces-neon-genesis-evangelion-preview.jpg".source =
      ../../"Neon Genesis Evangelion (Pics)"/"numbers-interfaces-anime-neon-genesis-evangelion-wallpaper-preview.jpg";
  };
}
