{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf config.irene.fonts.enable {
    fonts.packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.ubuntu
      # microsoft fonts: arial, times new roman... and calibri, cambria...
      pkgs.corefonts
      pkgs.vista-fonts
    ];
  };
}
