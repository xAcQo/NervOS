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
    # Stylix owns base waybar theming; lib.mkAfter appends after Stylix CSS.
    style = lib.mkAfter ''
      /* NERV Command: mechanical title styling.
         GTK CSS does not support `transform: scaleX()`, so horizontal
         compression comes from font-stretch + letter-spacing + uppercase. */
      #window label {
        font-stretch: condensed;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        font-weight: bold;
      }

      /* Active workspace: NERV orange accent + bottom bar */
      #workspaces button.active {
        color: @base09;
        border-bottom: 2px solid @base09;
        background: transparent;
      }

      /* Clock: wire cyan */
      #clock {
        color: @base0C;
        font-weight: bold;
      }

      /* Battery critical: alert red */
      #battery.critical {
        color: @base08;
      }
    '';
  };
}
