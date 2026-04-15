{ ... }:
{
  # mako notification daemon (behavior only -- Stylix themes via stylix.targets.mako).
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      anchor = "top-right";
      margin = "10";
      border-radius = 6;
      # NO color options -- Stylix handles theming via stylix.targets.mako.
    };
  };
}
