{
  config,
  lib,
  ...
}: {
  options.irene.audio.enable = lib.mkEnableOption "audio with pipewire";

  config = lib.mkIf config.irene.audio.enable {
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    security.rtkit.enable = true;

    users.users =
      lib.mapAttrs (_name: _profile: {
        extraGroups = ["audio"];
      })
      config.irene.users.profiles;
  };
}
