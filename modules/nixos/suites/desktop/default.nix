{
  config,
  lib,
  ...
}: {
  options.irene.suites.desktop.enable = lib.mkEnableOption "desktop programs suite";

  config = lib.mkIf config.irene.suites.desktop.enable {
    irene.programs = {
      brave.enable = true;
      libreoffice.enable = true;
    };
  };
}
