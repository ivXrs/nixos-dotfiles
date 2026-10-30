{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.vlc.enable = lib.mkEnableOption "vlc";

  config = lib.mkIf config.irene.programs.vlc.enable {
    environment.systemPackages = [pkgs.vlc];
  };
}
