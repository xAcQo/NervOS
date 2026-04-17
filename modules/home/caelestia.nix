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

    # Behaviour-only settings. Fonts/colors deferred -- caelestia ships
    # Rubik + CaskaydiaCove by default; font pivot to Cinzel/Noto Serif
    # Display is deferred out of Phase 2.1 (see roadmap Phase 3 rework).
    settings = {
      bar.status.showBattery = true;
      paths.wallpaperDir = "~/Pictures/wallpapers";
    };
  };
}
