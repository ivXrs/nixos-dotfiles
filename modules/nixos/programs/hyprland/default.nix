{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.hyprland = {
    enable = lib.mkEnableOption "hyprland";

    xwaylandScale = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "integer scale applied by gtk and qt apps running on xwayland.";
    };
  };

  config = lib.mkIf config.irene.programs.hyprland.enable {
    # packages from the upstream flake, built and cached by hyprland.cachix.org
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    environment.sessionVariables = {
      # electron and chromium apps run on wayland instead of a blurry xwayland
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # qt apps prefer wayland and fall back to xwayland
      QT_QPA_PLATFORM = "wayland;xcb";

      # gtk apps on xwayland scale themselves, since hyprland does not (force_zero_scaling)
      GDK_SCALE = toString config.irene.programs.hyprland.xwaylandScale;
    };
  };
}
