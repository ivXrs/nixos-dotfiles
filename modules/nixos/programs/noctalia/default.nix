{
  config,
  lib,
  ...
}: {
  options.irene.programs.noctalia.enable = lib.mkEnableOption "system services used by noctalia; the shell itself comes from home-manager";

  config = lib.mkIf config.irene.programs.noctalia.enable {
    # same as programs.noctalia.recommendedServices, which home-manager does not have
    networking.networkmanager.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;
    services = {
      upower.enable = lib.mkDefault true;
      power-profiles-daemon.enable = lib.mkDefault true;
    };

    # freedesktop sound theme, a runtime dependency of noctalia
    xdg.sounds.enable = true;
  };
}
