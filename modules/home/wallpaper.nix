{ ... }:
let
  wp = ../../assets/wallpaper.jpg;  # relative path from modules/home/ to repo root
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wp}" ];
      wallpaper = [ ",${wp}" ];   # "," = all monitors (no specific monitor name)
    };
  };
}
