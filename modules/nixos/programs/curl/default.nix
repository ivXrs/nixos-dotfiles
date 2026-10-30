{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.curl.enable = lib.mkEnableOption "curl";

  config = lib.mkIf config.irene.programs.curl.enable {
    environment.systemPackages = [pkgs.curl];
  };
}
