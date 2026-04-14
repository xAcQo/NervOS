{ config, lib, pkgs, ... }:
{
  # GPU-agnostic graphics enablement.
  # Works for AMD, Intel, and virtio (VM) out of the box.
  # NVIDIA users: see commented block below.
  hardware.graphics = {
    enable = true;
    # enable32Bit = true;  # Uncomment for Steam/gaming (Phase 2+)
  };

  # NVIDIA support (uncomment when deploying to NVIDIA hardware):
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = true;  # Use open kernel modules (Turing+ GPUs)
  #   nvidiaSettings = true;
  # };
  # services.xserver.videoDrivers = [ "nvidia" ];
}
