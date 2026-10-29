{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.fastfetch.enable = lib.mkEnableOption "fastfetch";

  config = lib.mkIf config.irene.programs.fastfetch.enable {
    environment.systemPackages = [pkgs.fastfetch];
  };
}
