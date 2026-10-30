{
  config,
  lib,
  ...
}: {
  options.irene.desktop = {
    enable = lib.mkEnableOption "desktop environment with greetd and noctalia-greeter";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "default terminal emulator: command name, also used as its desktop file id.";
    };
  };

  config = lib.mkIf config.irene.desktop.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = ["${config.irene.desktop.terminal}.desktop"];
    };

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings.keyboard.layout = "es";
    };
  };
}
