{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.eza.enable = lib.mkEnableOption "eza";

  config = lib.mkIf config.irene.programs.eza.enable {
    environment.systemPackages = [pkgs.eza];
  };
}
