{
  config,
  lib,
  ...
}: {
  options.irene.programs.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.irene.programs.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
