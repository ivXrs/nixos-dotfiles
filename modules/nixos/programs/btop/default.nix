{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf config.irene.programs.btop.enable {
    environment.systemPackages = [pkgs.btop];
  };
}
