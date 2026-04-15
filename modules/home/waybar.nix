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
    # NO style block -- Stylix owns waybar theming via stylix.targets.waybar.
  };
}
