{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.irene.programs.hyprland.enable {
    # packages from the upstream flake, built and cached by hyprland.cachix.org
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };
}
