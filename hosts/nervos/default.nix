{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/gpu.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/stylix.nix
    ../../modules/nixos/file-manager.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/network.nix
  ];

  # Boot — GRUB BIOS (VM target). Switch to systemd-boot for EFI hardware.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = false;
  };

  # Networking
  networking.hostName = "nervos";
  networking.networkmanager.enable = true;

  # SSH — enabled for remote debugging of the VM
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User
  users.users.pilot = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nervos";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Existing
    kitty
    git
    vim

    # Screenshot toolchain (Plan 02-03)
    grimblast          # Hyprland-blessed screenshot wrapper
    grim               # Wayland screenshot primitive
    slurp              # region selector for grimblast area mode
    hyprpicker         # screen freeze during area select (optional but recommended)
    wl-clipboard       # provides wl-copy/wl-paste -- required by grimblast copy and by cliphist
    jq                 # grimblast dependency for JSON parsing of hyprctl output
    libnotify          # provides notify-send -- grimblast status notifications + manual mako test

    # Input helpers used by keybinds (Plan 02-04 will call these)
    brightnessctl      # XF86MonBrightness*
    playerctl          # XF86AudioPlay/Next/Prev
  ];

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Wayland environment hints.
  # WLR_* vars let wlroots/Hyprland run on VMware's virtual GPU (no DRM/EGL acceleration).
  # NIXOS_OZONE_WL enables native Wayland for Electron/Chromium apps.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_RENDERER = "pixman";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  system.stateVersion = "25.05";
}
