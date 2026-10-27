{
  config,
  lib,
  ...
}: {
  options.irene.programs.htop.enable = lib.mkEnableOption "htop";

  config = lib.mkIf config.irene.programs.htop.enable {
    programs.htop.enable = true;
  };
}
