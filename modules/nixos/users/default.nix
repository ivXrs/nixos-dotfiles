{
  config,
  lib,
  ...
}: {
  options.irene.users = {
    enable = lib.mkEnableOption "user management";

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          description = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "real name of the user.";
          };

          home = lib.mkOption {
            type = lib.types.str;
            default = "/home/${name}";
            description = "home directory path. defaults to /home/<username>.";
          };

          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "supplementary groups the user belongs to.";
          };

          initialPassword = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "plain-text password set on first activation.";
          };
        };
      }));
      default = {};
      description = "attribute set of normal users to create, keyed by username.";
    };
  };

  config = lib.mkIf config.irene.users.enable {
    users.users =
      lib.mapAttrs (_name: profile: {
        isNormalUser = true;
        inherit (profile) description home extraGroups initialPassword;
      })
      config.irene.users.profiles;
  };
}
