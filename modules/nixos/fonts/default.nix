{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf config.irene.fonts.enable {
    fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
  };
}
