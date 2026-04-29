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
  users.users.styx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nervos";
  };

  # NOPASSWD nixos-rebuild so SSH remote rebuilds work without a TTY.
  security.sudo.extraRules = [
    {
      users = [ "styx" ];
      commands = [
        { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "/nix/var/nix/profiles/system/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    # Existing
    kitty
    git
    vim

    # Screenshot toolchain (Phase 2.1: grimblast/slurp removed -- caelestia handles region via
    # built-in WlScreencopy area picker; fullscreen screenshot calls grim directly)
    grim               # Wayland screenshot primitive (used by caelestia screenshot fullscreen)
    wl-clipboard       # wl-copy/wl-paste -- used by caelestia screenshot fullscreen output
    jq                 # general JSON utility
    libnotify          # notify-send -- general system notifications

    # Input helpers used by keybinds (Plan 02-04 will call these)
    brightnessctl      # XF86MonBrightness*
    playerctl          # XF86AudioPlay/Next/Prev
  ];

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Wayland environment hints.
  # Hyprland hardcodes EGL init and ignores WLR_RENDERER=pixman, so we force
  # Mesa to use llvmpipe (software GL) via LIBGL_ALWAYS_SOFTWARE. That gives
  # a working EGL without needing VMware's 3D acceleration enabled on the host.
  # NIXOS_OZONE_WL enables native Wayland for Electron/Chromium apps.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBGL_ALWAYS_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  system.stateVersion = "25.05";
}
