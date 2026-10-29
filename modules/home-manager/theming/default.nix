{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.home-manager.theming.enable = lib.mkEnableOption "cursor, icons, fonts and gtk/qt engines; colors come from noctalia";

  config = lib.mkIf config.irene.home-manager.theming.enable {
    home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      # adw-gtk3 is the base that noctalia's gtk template recolors
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "Ubuntu Nerd Font";
        size = 11;
      };
      # noctalia renders noctalia.css next to gtk.css
      gtk3.extraCss = ''@import url("noctalia.css");'';
      gtk4.extraCss = ''@import url("noctalia.css");'';
    };

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      # noctalia renders the color schemes into qt5ct/colors and qt6ct/colors
      qt5ctSettings = {
        Appearance = {
          custom_palette = true;
          color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
          icon_theme = "Papirus-Dark";
          style = "Fusion";
        };
        Fonts = {
          general = ''"Ubuntu Nerd Font,11"'';
          fixed = ''"JetBrainsMono Nerd Font,11"'';
        };
      };
      qt6ctSettings = {
        Appearance = {
          custom_palette = true;
          color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
          icon_theme = "Papirus-Dark";
          style = "Fusion";
        };
        Fonts = {
          general = ''"Ubuntu Nerd Font,11"'';
          fixed = ''"JetBrainsMono Nerd Font,11"'';
        };
      };
    };

    wayland.windowManager.hyprland = {
      settings.env = map (args: {_args = args;}) [
        ["XCURSOR_THEME" config.home.pointerCursor.name]
        ["QT_QPA_PLATFORMTHEME" config.home.sessionVariables.QT_QPA_PLATFORMTHEME]
      ];
      # mkOptionDefault appends to the default list, so apps started from noctalia (a systemd service) get them too
      systemd.variables = lib.mkOptionDefault ["XCURSOR_THEME" "XCURSOR_SIZE" "QT_QPA_PLATFORMTHEME"];
    };
  };
}
