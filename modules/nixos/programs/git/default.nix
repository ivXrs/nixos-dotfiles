{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf config.irene.programs.git.enable {
    environment.systemPackages = [pkgs.git];
  };
}
