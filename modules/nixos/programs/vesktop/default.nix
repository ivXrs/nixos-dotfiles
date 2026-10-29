{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.vesktop.enable = lib.mkEnableOption "vesktop";

  config = lib.mkIf config.irene.programs.vesktop.enable {
    environment.systemPackages = [pkgs.vesktop];
  };
}
