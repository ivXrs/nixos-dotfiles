{
  config,
  lib,
  ...
}: {
  options.irene.suites.coding.enable = lib.mkEnableOption "coding programs suite";

  config = lib.mkIf config.irene.suites.coding.enable {
    irene.programs = {
      alejandra.enable = true;
      claude.enable = true;
      git.enable = true;
      neovim.enable = true;
    };
  };
}
