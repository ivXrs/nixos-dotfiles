{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.alejandra.enable = lib.mkEnableOption "alejandra";

  config = lib.mkIf config.irene.programs.alejandra.enable {
    environment.systemPackages = [pkgs.alejandra];
  };
}
