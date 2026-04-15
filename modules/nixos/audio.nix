{ ... }:
{
  # IMPORTANT: option was renamed from hardware.pulseaudio to services.pulseaudio in 24.11.
  # On nixos-unstable we use the new name. Explicitly disable to prevent PA/PW fighting.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;   # required for PipeWire realtime priority

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;          # PulseAudio protocol shim -- existing PA apps work unchanged
    wireplumber.enable = true;
    # jack.enable = true;         # enable only for pro-audio; not needed for Phase 2
  };
}
