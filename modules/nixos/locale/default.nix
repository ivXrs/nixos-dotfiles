{
  config,
  lib,
  ...
}: {
  options.irene.locale = {
    enable = lib.mkEnableOption "locale configuration";

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "default locale for the system and extra locale categories.";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "keyboard layout for x11 and the console.";
    };
  };

  config = lib.mkIf config.irene.locale.enable {
    time.timeZone = "Europe/Madrid";

    i18n = {
      defaultLocale = config.irene.locale.defaultLocale;
      extraLocaleSettings = {
        LC_ADDRESS = config.irene.locale.defaultLocale;
        LC_IDENTIFICATION = config.irene.locale.defaultLocale;
        LC_MEASUREMENT = config.irene.locale.defaultLocale;
        LC_MONETARY = config.irene.locale.defaultLocale;
        LC_NAME = config.irene.locale.defaultLocale;
        LC_NUMERIC = config.irene.locale.defaultLocale;
        LC_PAPER = config.irene.locale.defaultLocale;
        LC_TELEPHONE = config.irene.locale.defaultLocale;
        LC_TIME = config.irene.locale.defaultLocale;
      };
    };

    services.xserver.xkb = {
      layout = config.irene.locale.keyboardLayout;
      variant = "";
    };

    console.keyMap = config.irene.locale.keyboardLayout;
  };
}
