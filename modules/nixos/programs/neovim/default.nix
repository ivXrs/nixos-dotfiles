{
  config,
  lib,
  ...
}: {
  options.irene.programs.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf config.irene.programs.neovim.enable {
    programs.neovim.enable = true;
  };
}
