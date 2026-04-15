{ config, pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
    ./kitty.nix
    ./mako.nix
    ./lock.nix
    ./wallpaper.nix
    ./clipboard.nix
    # Do NOT import Stylix here -- it auto-integrates via the NixOS module.
    # Manually importing stylix.homeModules.stylix causes double-definition errors.
  ];

  home.username = "pilot";
  home.homeDirectory = "/home/pilot";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}
