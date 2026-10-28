{
  config,
  lib,
  ...
}: {
  options.irene.suites.desktop.enable = lib.mkEnableOption "desktop programs suite";

  config = lib.mkIf config.irene.suites.desktop.enable {
    irene.programs = {
      brave.enable = true;
      kitty.enable = true;
      libreoffice.enable = true;
    };
  };
}
