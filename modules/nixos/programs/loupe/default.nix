{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.loupe.enable = lib.mkEnableOption "loupe";

  config = lib.mkIf config.irene.programs.loupe.enable {
    environment.systemPackages = [pkgs.loupe];
  };
}
