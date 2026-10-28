{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.desktop.enable = lib.mkEnableOption "desktop environment with greetd and tuigreet";

  config = lib.mkIf config.irene.desktop.enable {
    hardware.graphics.enable = true;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
        user = "greeter";
      };
    };
  };
}
