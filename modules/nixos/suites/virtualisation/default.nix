{
  config,
  lib,
  ...
}: {
  options.irene.suites.virtualisation.enable = lib.mkEnableOption "virtualisation suite";

  config = lib.mkIf config.irene.suites.virtualisation.enable {
    irene.programs.virtualbox.enable = true;
  };
}
