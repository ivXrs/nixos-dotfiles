{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.zapzap.enable = lib.mkEnableOption "zapzap";

  config = lib.mkIf config.irene.programs.zapzap.enable {
    environment.systemPackages = [pkgs.zapzap];
  };
}
