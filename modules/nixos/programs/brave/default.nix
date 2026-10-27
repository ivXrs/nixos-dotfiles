{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.brave.enable = lib.mkEnableOption "brave";

  config = lib.mkIf config.irene.programs.brave.enable {
    environment.systemPackages = [pkgs.brave];
  };
}
