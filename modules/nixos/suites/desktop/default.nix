{
  config,
  lib,
  ...
}: {
  options.irene.suites.desktop.enable = lib.mkEnableOption "desktop programs suite";

  config = lib.mkIf config.irene.suites.desktop.enable {
    irene.programs = {
      brave.enable = true;
      hyprland.enable = true;
      kitty.enable = true;
      libreoffice.enable = true;
      loupe.enable = true;
      nautilus.enable = true;
      noctalia.enable = true;
      papers.enable = true;
      vesktop.enable = true;
      vlc.enable = true;
    };
  };
}
