{ ... }:
{
  # mako notification daemon (behavior only -- Stylix themes via stylix.targets.mako).
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      anchor = "top-right";
      margin = "10";
      border-radius = 0;   # MAGI straight-edge -- overrides default rounding
      border-size = 1;     # Clean single-pixel NERV border line
      # NO color options -- Stylix handles theming via stylix.targets.mako.
    };
  };
}
