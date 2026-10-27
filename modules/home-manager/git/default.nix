{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf config.irene.home-manager.git.enable {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "ivXrs";
          email = "283170461+ivXrs@users.noreply.github.com";
        };

        init.defaultBranch = "main";

        core = {
          editor = "nvim";
          sshCommand = "ssh -i ~/.ssh/id-github -o IdentitiesOnly=yes";
        };
      };
    };
  };
}
