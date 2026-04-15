{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;   # REQUIRED -- plain rofi does not render correctly on Hyprland
    terminal = "${pkgs.kitty}/bin/kitty";
    # Do NOT set `theme` or `extraConfig` with colors. Stylix owns theming.
  };
}
