{ config, pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./kitty.nix
    ./caelestia.nix
    # Stylix auto-integrates via the NixOS module -- do NOT import stylix.homeModules.stylix here.
    # waybar/rofi/mako/lock/wallpaper/clipboard removed 2026-04-17 (Phase 2.1): superseded by caelestia shell.
  ];

  home.username = "styx";
  home.homeDirectory = "/home/styx";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
