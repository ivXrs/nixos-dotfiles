{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.papers.enable = lib.mkEnableOption "papers";

  config = lib.mkIf config.irene.programs.papers.enable {
    environment.systemPackages = [pkgs.papers];
  };
}
