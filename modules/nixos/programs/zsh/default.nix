{
  config,
  lib,
  ...
}: {
  options.irene.programs.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.irene.programs.zsh.enable {
    programs.zsh.enable = true;
  };
}
