{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.gh.enable = lib.mkEnableOption "github cli";

  config = lib.mkIf config.irene.programs.gh.enable {
    environment.systemPackages = [pkgs.gh];
  };
}
