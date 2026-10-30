{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.nautilus.enable = lib.mkEnableOption "nautilus";

  config = lib.mkIf config.irene.programs.nautilus.enable {
    environment.systemPackages = [pkgs.nautilus];

    # trash and mounts in nautilus
    services.gvfs.enable = true;

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = config.irene.desktop.terminal;
    };
  };
}
