{ lib, pkgs, ... }:
let
  wp = ../../assets/wallpaper.jpg;  # relative path from modules/home/ to repo root
in {
  # Disable both stylix hyprpaper integration AND our own hyprpaper service:
  # hyprpaper requires working EGL, which VMware's vmwgfx doesn't expose without
  # host 3D acceleration. swaybg works with software rendering.
  stylix.targets.hyprpaper.enable = lib.mkForce false;
  services.hyprpaper.enable = lib.mkForce false;

  home.packages = [ pkgs.swaybg ];

  # Launched by Hyprland exec-once (see modules/home/hyprland.nix).
  # Exposed as a systemd user service so it restarts if it crashes.
  systemd.user.services.swaybg = {
    Unit = {
      Description = "swaybg wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wp} -m fill";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
