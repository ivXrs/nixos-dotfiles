{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.boot.enable = lib.mkEnableOption "boot configuration";

  config = lib.mkIf config.irene.boot.enable {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
      };
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
