{ config, pkgs, ... }:
let
  matisse-eb = pkgs.callPackage ../../pkgs/matisse-eb {};
in {
  stylix = {
    enable = true;

    # hyprlock disabled: caelestia provides its own WlSessionLock surface.
    targets.hyprlock.enable = false;

    # Wallpaper (required -- Stylix fails to evaluate without an image)
    # Phase 3 replaces this with real NERV Command wallpaper from asset collection.
    image = ../../assets/wallpaper.jpg;

    # Dark theme (all NervOS profiles are dark)
    polarity = "dark";

    # NERV Command base16 palette (Phase 3 complete -- NERV Command palette finalized)
    base16Scheme = {
      base00 = "000000";  # Background: true black
      base01 = "1a1a1a";  # Lighter background
      base02 = "333333";  # Selection background
      base03 = "666666";  # Comments, muted
      base04 = "999999";  # Dark foreground
      base05 = "cccccc";  # Default foreground
      base06 = "e6e6e6";  # Light foreground
      base07 = "ffffff";  # Lightest foreground
      base08 = "ff3030";  # Red (alert red)
      base09 = "ff9830";  # Orange (NERV orange -- primary accent)
      base0A = "ffcc00";  # Yellow
      base0B = "40bf40";  # Green
      base0C = "20f0ff";  # Cyan (wire cyan highlight)
      base0D = "4080ff";  # Blue
      base0E = "9050ff";  # Purple
      base0F = "ff6030";  # Dark orange
    };

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      # Phase 3: Matisse EB display font -- NERV Command visual identity
      sansSerif = {
        package = matisse-eb;
        name = "MatissePro-EB";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 12;
        desktop = 10;
        terminal = 12;
        popups = 10;
      };
    };

    # Cursor
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # Opacity
    opacity = {
      applications = 1.0;
      desktop = 0.9;
      terminal = 0.95;
      popups = 0.95;
    };
  };

  # Register Matisse EB for all fontconfig consumers (GTK apps, fc-list queries)
  fonts.packages = [ matisse-eb ];
}
