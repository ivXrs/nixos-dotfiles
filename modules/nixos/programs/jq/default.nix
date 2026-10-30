{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.jq.enable = lib.mkEnableOption "jq";

  config = lib.mkIf config.irene.programs.jq.enable {
    environment.systemPackages = [pkgs.jq];
  };
}
