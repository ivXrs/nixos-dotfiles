{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.git = {
    enable = lib.mkEnableOption "git";

    userName = lib.mkOption {
      type = lib.types.str;
      description = "name used in commits.";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "email used in commits.";
    };

    sshKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "private key used by git over ssh. null uses the ssh defaults.";
    };
  };

  config = lib.mkIf config.irene.home-manager.git.enable {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = config.irene.home-manager.git.userName;
          email = config.irene.home-manager.git.userEmail;
        };

        init.defaultBranch = "main";

        core = {
          editor = "nvim";
          sshCommand = lib.mkIf (config.irene.home-manager.git.sshKey != null) "ssh -i ${config.irene.home-manager.git.sshKey} -o IdentitiesOnly=yes";
        };
      };
    };
  };
}
