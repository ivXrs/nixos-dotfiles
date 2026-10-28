{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.irene.home-manager.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        ignoreAllDups = true;
        share = true;
      };
    };
  };
}
