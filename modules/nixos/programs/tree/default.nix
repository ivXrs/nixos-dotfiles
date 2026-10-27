{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.tree.enable = lib.mkEnableOption "tree";

  config = lib.mkIf config.irene.programs.tree.enable {
    environment.systemPackages = [pkgs.tree];
  };
}
