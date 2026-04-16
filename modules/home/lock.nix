{ lib, ... }:
{
  # hyprlock + hypridle pair: lock-now + lock-on-idle for the pilot session.
  # PAM is auto-configured on the NixOS side via programs.hyprlock.enable = true.
  # Do NOT set colors or fonts here -- Stylix themes hyprlock via stylix.targets.hyprlock.
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      # mkForce overrides stylix.targets.hyprlock's background (path+color) with our screenshot+blur
      background = lib.mkForce [{
        path = "screenshot";
        blur_passes = 3;
      }];
      input-field = lib.mkForce [{
        size = "200, 50";
        position = "0, -80";
        placeholder_text = "Pilot authentication";
        fade_on_empty = false;
      }];
      label = lib.mkForce [{
        text = "NERV COMMAND";
        position = "0, 160";
        halign = "center";
        valign = "center";
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
