{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.bottles.enable = lib.mkEnableOption "bottles";

  config = lib.mkIf config.irene.programs.bottles.enable {
    environment.systemPackages = [pkgs.bottles];
  };
}
