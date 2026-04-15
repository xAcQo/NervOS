{ ... }:
{
  services.cliphist = {
    enable = true;
    allowImages = true;
    # Hyprland reaches graphical-session.target, but being explicit with
    # hyprland-session.target avoids regressions (RESEARCH.md Pitfall 8).
    systemdTargets = [ "hyprland-session.target" ];
  };
}
