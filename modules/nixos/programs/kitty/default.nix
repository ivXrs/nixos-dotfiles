{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.irene.programs.kitty.enable {
    environment.systemPackages = [pkgs.kitty];
  };
}
