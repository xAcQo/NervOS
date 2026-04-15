{ pkgs, ... }:
{
  # Thunar file manager (XFCE) -- system-level so gvfs/tumbler services register.
  # See RESEARCH.md Pitfall 5: without gvfs, click-to-mount silently fails and trash
  # does not work; without tumbler, thumbnails never render; without thunar-volman,
  # auto-open dialogs on inserting media do not appear; without thunar-archive-plugin,
  # right-click extract/compress is missing.
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;      # mount removable media + trash + network shares
  services.tumbler.enable = true;   # image/doc thumbnails in Thunar
}
