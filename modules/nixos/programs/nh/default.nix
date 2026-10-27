{
  config,
  inputs,
  lib,
  ...
}: {
  options.irene.programs.nh.enable = lib.mkEnableOption "nh";

  config = lib.mkIf config.irene.programs.nh.enable {
    programs.nh = {
      enable = true;
      flake = "${inputs.self}";

      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 14d";
      };
    };
  };
}
