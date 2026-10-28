{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf config.irene.home-manager.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      presets = ["pure-preset"];
    };
  };
}
