{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.fzf.enable = lib.mkEnableOption "fzf";

  config = lib.mkIf config.irene.programs.fzf.enable {
    environment.systemPackages = [pkgs.fzf];
  };
}
