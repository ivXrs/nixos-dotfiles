{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.lutris.enable = lib.mkEnableOption "lutris";

  config = lib.mkIf config.irene.programs.lutris.enable {
    environment.systemPackages = [pkgs.lutris];
  };
}
