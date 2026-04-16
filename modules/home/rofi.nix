{ pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;   # rofi-wayland was merged into rofi in nixpkgs-unstable
    terminal = "${pkgs.kitty}/bin/kitty";
    font = lib.mkForce "MatissePro-EB 12";    # Matisse EB font guarantee -- overrides Stylix default
    # Do NOT set `theme` or `extraConfig` with colors. Stylix owns theming.
  };
}
