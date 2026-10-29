{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.home-manager.noctalia.enable = lib.mkEnableOption "noctalia";

  config = lib.mkIf config.irene.home-manager.noctalia.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      # defaults written to ~/.config/noctalia/config.toml; changes made from the settings menu still win
      settings = {
        bar.default = {
          capsule = true;
          start = ["control-center" "workspaces" "privacy"];
          center = ["media" "clock" "notifications"];
          end = ["bar" "tray" "clipboard" "network" "bluetooth" "brightness" "volume" "battery" "session"];
          margin_ends = 0;
          radius_top_left = 0;
          radius_top_right = 0;
          radius_bottom_left = 8;
          radius_bottom_right = 8;
        };

        osd.kinds.lock_keys = false;

        # the plugin itself is downloaded by noctalia at runtime
        plugins.enabled = ["rylos/tailnet"];

        shell = {
          font_family = "Ubuntu Nerd Font";
          polkit_agent = true;
          launcher = {
            category_icons_only = true;
            layout = "simple";
          };
        };

        theme = {
          source = "wallpaper";
          templates = {
            enable_builtin_templates = true;
            builtin_ids = ["gtk3" "gtk4" "hyprland" "kitty" "qt"];
            # downloaded by noctalia at runtime, like the plugins
            enable_community_templates = true;
            community_ids = ["brave" "claude-code"];
          };
        };

        wallpaper = {
          directory = "~/wallpapers";
          default.path = "${config.home.homeDirectory}/wallpapers/fondo-escritorio.png";
        };

        widget = {
          # bar widget of the tailnet plugin
          bar = {
            hide_not_installed = true;
            show_count = false;
            type = "rylos/tailnet:bar";
          };
          battery = {
            display_mode = "graphic";
            hide_when_full = true;
          };
          brightness.show_label = false;
          clock.anchor = true;
          control-center.glyph = "circle-filled";
          media.hide_when_no_media = true;
          network.show_label = false;
          notifications.hide_when_no_unread = true;
          privacy.hide_inactive = true;
          sysmon.visualization = "none";
        };
      };
    };

    # the template hooks cannot edit read-only configs, so their includes are declared here and the hooks skip
    programs.kitty.extraConfig = "include themes/noctalia.conf";
    # the brave template renders an unpacked theme extension; loading it on every start replaces adding it by hand
    programs.brave.commandLineArgs = ["--load-extension=${config.xdg.dataHome}/noctalia/brave-theme"];
    # rendered last so it overrides the border colors; pcall covers the time before the first render
    wayland.windowManager.hyprland.extraConfig = ''
      pcall(function() require("noctalia").apply_theme() end)
    '';

    # claude rewrites settings.json itself, so the theme is set in place instead of linking a read-only file;
    # the themes dir exists before claude starts, so it picks up the first render without a restart
    home = {
      activation.claudeNoctaliaTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
        settings="$HOME/.claude/settings.json"
        run mkdir -p "$HOME/.claude/themes"
        if [ ! -f "$settings" ]; then
          run sh -c "echo '{}' > \"$settings\""
        fi
        # an invalid settings.json only warns, so it never blocks the activation
        run sh -c "${lib.getExe pkgs.jq} '.theme = \"custom:noctalia\"' \"$settings\" > \"$settings.tmp\" && mv \"$settings.tmp\" \"$settings\"" \
          || warnEcho "could not set the claude theme in $settings"
      '';

      # the brave template hook paints the theme images with python and pillow
      packages = lib.optional config.programs.brave.enable (pkgs.python3.withPackages (ps: [ps.pillow]));
    };
  };
}
