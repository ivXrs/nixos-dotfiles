{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.nodejs.enable = lib.mkEnableOption "nodejs";

  config = lib.mkIf config.irene.programs.nodejs.enable {
    environment.systemPackages = [pkgs.nodejs_latest];
  };
}
