{
  config,
  lib,
  ...
}: {
  options.irene.programs.virtualbox.enable = lib.mkEnableOption "virtualbox";

  config = lib.mkIf config.irene.programs.virtualbox.enable {
    virtualisation.virtualbox.host.enable = true;

    users.users =
      lib.mapAttrs (_name: _profile: {
        extraGroups = ["vboxusers"];
      })
      config.irene.users.profiles;
  };
}
