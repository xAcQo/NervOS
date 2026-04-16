{ pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;   # REQUIRED -- plain rofi does not render correctly on Hyprland
    terminal = "${pkgs.kitty}/bin/kitty";
    font = lib.mkForce "MatissePro-EB 12";    # Matisse EB font guarantee -- overrides Stylix default
    # Do NOT set `theme` or `extraConfig` with colors. Stylix owns theming.
  };
}
