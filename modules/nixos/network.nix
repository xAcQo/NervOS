{ ... }:
{
  # NetworkManager is already enabled in hosts/nervos/default.nix from Phase 1.
  # This module centralizes network-related config and adds the applet.
  networking.networkmanager.enable = true;   # idempotent with host-level setting
  programs.nm-applet.enable = true;          # installs applet + XDG autostart entry
}
