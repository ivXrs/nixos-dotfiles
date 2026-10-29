{
  config,
  lib,
  ...
}: {
  options.irene.suites.gaming.enable = lib.mkEnableOption "gaming programs suite";

  config = lib.mkIf config.irene.suites.gaming.enable {
    irene.programs.bottles.enable = true;
  };
}
