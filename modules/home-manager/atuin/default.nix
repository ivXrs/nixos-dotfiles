{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.atuin.enable = lib.mkEnableOption "atuin";

  config = lib.mkIf config.irene.home-manager.atuin.enable {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;

      # ctrl+r is left to fzf
      flags = ["--disable-ctrl-r"];

      settings = {
        style = "compact";
        inline_height = 20;
      };
    };
  };
}
