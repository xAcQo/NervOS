{ config, pkgs, ... }:
{
  # Hyprland compositor (upstreamed nixpkgs module -- no flake input needed)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # Do NOT enable UWSM -- conflicts with home-manager systemd integration
    # and has mixed community reception. Skip for Phase 1.
  };

  # Display manager: greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Required for Hyprland session management
  security.polkit.enable = true;

  # XDG portal for screen sharing, file dialogs
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
