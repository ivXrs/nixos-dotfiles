{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.python.enable = lib.mkEnableOption "python with pip";

  config = lib.mkIf config.irene.programs.python.enable {
    environment.systemPackages = [(pkgs.python3.withPackages (ps: [ps.pip]))];
  };
}
