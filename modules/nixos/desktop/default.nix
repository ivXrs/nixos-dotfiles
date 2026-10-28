{
  config,
  lib,
  ...
}: {
  options.irene.desktop.enable = lib.mkEnableOption "desktop environment with greetd and noctalia-greeter";

  config = lib.mkIf config.irene.desktop.enable {
    hardware.graphics.enable = true;

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings.keyboard.layout = "es";
    };
  };
}
