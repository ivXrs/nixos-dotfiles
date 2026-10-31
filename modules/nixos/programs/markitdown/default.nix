{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.markitdown.enable = lib.mkEnableOption "markitdown";

  config = lib.mkIf config.irene.programs.markitdown.enable {
    environment.systemPackages = [pkgs.markitdown];
  };
}
