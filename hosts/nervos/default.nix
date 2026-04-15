{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/gpu.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/stylix.nix
    ../../modules/nixos/file-manager.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nervos";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User
  users.users.pilot = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nervos";
  };

  # System packages (minimal for Phase 1)
  environment.systemPackages = with pkgs; [
    kitty
    git
    vim
  ];

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Wayland environment hint for Electron/Chromium apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  system.stateVersion = "25.05";
}
