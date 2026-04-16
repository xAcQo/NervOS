{ config, pkgs, lib, ... }:
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
        gaps_in = 4;          # NERV Command: tight gaps (was 5)
        gaps_out = 8;         # NERV Command: tight outer gaps (was 10)
        border_size = 2;
        layout = "dwindle";
        "col.active_border" = lib.mkForce "rgba(ff9830ff)";    # NERV orange
        "col.inactive_border" = lib.mkForce "rgba(1a1a1aff)";  # Phase 1 dark bg
      };

      decoration = {
        rounding = 0;          # MAGI straight-edge (was 8)
        shadow.enabled = false; # Hyprland v0.41+ syntax
      };

      animations = {
        enabled = true;
        bezier = [ "nervOut, 0.16, 1, 0.3, 1" ];  # Sharp ease-out
        animation = [
          "windows, 1, 3, nervOut, popin 85%"
          "windowsIn, 1, 3, nervOut, popin 85%"
          "windowsOut, 1, 2, nervOut, popin 85%"
          "fade, 1, 3, nervOut"
          "workspaces, 1, 4, nervOut, slide"
          "border, 1, 5, nervOut"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
      };

      # Session-start autostarts (Hyprland does not implement XDG autostart, so
      # programs.nm-applet.enable alone will not launch the applet -- exec it here).
      exec-once = [
        "nm-applet --indicator"   # waybar tray WiFi/ethernet icon
        "hyprpolkitagent"         # graphical polkit prompts for mount/WiFi admin
      ];

      # Minimal keybinds for a working desktop
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod SHIFT, V, togglefloating,"
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
        # Phase 2 Plan 04 -- desktop shell wiring
        "$mainMod, SPACE, exec, rofi -show drun"
        "$mainMod, L, exec, loginctl lock-session"
        "$mainMod, V, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy screen"
      ];

      # Repeat-on-hold / locked-input keys: volume + brightness
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp,  exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown,exec, brightnessctl s 5%-"
      ];

      # Keys that work even when the session is locked (media transport)
      bindl = [
        ", XF86AudioPlay,  exec, playerctl play-pause"
        ", XF86AudioNext,  exec, playerctl next"
        ", XF86AudioPrev,  exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
