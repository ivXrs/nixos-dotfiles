{
  config,
  lib,
  ...
}: {
  options.irene.programs.noctalia.enable = lib.mkEnableOption "noctalia";

  config = lib.mkIf config.irene.programs.noctalia.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      # networkmanager, bluetooth, upower and power-profiles-daemon
      recommendedServices.enable = true;
    };
  };
}
