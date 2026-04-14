{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # systemd.enable defaults to true -- integrates with systemd user session.
    # Do NOT disable unless using UWSM (which we are not).

    settings = {
      # Monitor: auto-detect resolution and position (GPU-agnostic)
      monitor = ",preferred,auto,auto";

      "$mainMod" = "SUPER";
      "$terminal" = "kitty";

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
      };

      # Minimal keybinds for a working desktop
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        # Window focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
