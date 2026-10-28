{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.fzf.enable = lib.mkEnableOption "fzf";

  config = lib.mkIf config.irene.home-manager.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
