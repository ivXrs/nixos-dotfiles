{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.desktop.enable = lib.mkEnableOption "desktop environment";

  config = lib.mkIf config.irene.desktop.enable {
    hardware.graphics.enable = true;

    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      cheese
      geary
      gnome-boxes
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-connections
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-music
      gnome-tour
      gnome-user-docs
      gnome-weather
      totem
    ];
  };
}
