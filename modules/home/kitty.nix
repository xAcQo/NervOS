{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      # NO font, NO colors -- Stylix provides via stylix.targets.kitty.
    };
  };
}
