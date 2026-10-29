{
  config,
  lib,
  pkgs,
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

    # vaapi on the nvidia gpu, used with: LIBVA_DRIVER_NAME=nvidia nvidia-offload <app>
    # LIBVA_DRIVER_NAME, __GLX_VENDOR_LIBRARY_NAME and GBM_BACKEND stay unset:
    # with prime offload they would move every app to the dgpu
    hardware.graphics.extraPackages = [pkgs.nvidia-vaapi-driver];
    environment.sessionVariables.NVD_BACKEND = "direct";

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      # nvidia-settings is unfree and compiled locally on every nixpkgs bump
      nvidiaSettings = false;
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

    users.users =
      lib.mapAttrs (_name: _profile: {
        extraGroups = ["video"];
      })
      config.irene.users.profiles;
  };
}
