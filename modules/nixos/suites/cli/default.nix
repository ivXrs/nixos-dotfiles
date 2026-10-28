{
  config,
  lib,
  ...
}: {
  options.irene.suites.cli.enable = lib.mkEnableOption "cli programs suite";

  config = lib.mkIf config.irene.suites.cli.enable {
    irene.programs = {
      bat.enable = true;
      btop.enable = true;
      eza.enable = true;
      fzf.enable = true;
      htop.enable = true;
      nh.enable = true;
      tree.enable = true;
      zsh.enable = true;
    };
  };
}
