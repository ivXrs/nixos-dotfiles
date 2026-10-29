{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.brave.enable = lib.mkEnableOption "brave";

  config = lib.mkIf config.irene.home-manager.brave.enable {
    programs.brave = {
      enable = true;
      package = null;
    };
  };
}
