{
  config,
  lib,
  ...
}: {
  options.irene.nvidia = {
    enable = lib.mkEnableOption "nvidia drivers with prime offload";

    intelBusId = lib.mkOption {
      type = lib.types.str;
      description = "pci bus id of the intel gpu, e.g. PCI:0:2:0.";
    };

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      description = "pci bus id of the nvidia gpu, e.g. PCI:1:0:0.";
    };
  };

  config = lib.mkIf config.irene.nvidia.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = config.irene.nvidia.intelBusId;
        nvidiaBusId = config.irene.nvidia.nvidiaBusId;
      };
    };
  };
}
