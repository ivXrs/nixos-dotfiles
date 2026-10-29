{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  options.irene.home-manager.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.irene.home-manager.hyprland.enable {
    wayland.windowManager.hyprland = with lib.generators; {
      enable = true;
      configType = "lua";

      # package and portal come from the nixos module
      package = null;
      portalPackage = null;

      settings = {
        # programs, rendered as lua locals
        terminal._var = "kitty";
        browser._var = "brave";
        fileManager._var = "nautilus";

        monitor = {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        };

        env = map (args: {_args = args;}) [
          ["XCURSOR_SIZE" "24"]
          ["HYPRCURSOR_SIZE" "24"]
        ];

        config = {
          general = {
            gaps_in = 5;
            gaps_out = 20;
            # border colors come from noctalia
            border_size = 1;

            resize_on_border = false;
            allow_tearing = false;
            layout = "master";
          };

          decoration = {
            rounding = 0;
            rounding_power = 2;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = mkLuaInline "0xee1a1a1a";
            };

            blur = {
              enabled = true;
              size = 3;
              passes = 2;
              vibrancy = 0.2;
            };
          };

          animations.enabled = true;

          # xwayland windows render at native resolution instead of being upscaled and blurry
          xwayland.force_zero_scaling = true;

          # new windows go to the stack instead of becoming the master
          master.new_status = "slave";

          misc = {
            force_default_wallpaper = -1;
            disable_hyprland_logo = false;
          };

          input = {
            kb_layout = "es";
            follow_mouse = 1;
            sensitivity = 0;
            touchpad.natural_scroll = false;
          };
        };

        curve = map (args: {_args = args;}) [
          [
            "easeOutQuint"
            {
              type = "bezier";
              points = [[0.23 1] [0.32 1]];
            }
          ]
          [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [[0.65 0.05] [0.36 1]];
            }
          ]
          [
            "linear"
            {
              type = "bezier";
              points = [[0 0] [1 1]];
            }
          ]
          [
            "almostLinear"
            {
              type = "bezier";
              points = [[0.5 0.5] [0.75 1]];
            }
          ]
          [
            "quick"
            {
              type = "bezier";
              points = [[0.15 0] [0.1 1]];
            }
          ]
          [
            "easy"
            {
              type = "spring";
              mass = 1;
              stiffness = 238.1191;
              dampening = 24.21279333;
            }
          ]
        ];

        animation = [
          {
            leaf = "global";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 5.39;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windows";
            enabled = true;
            speed = 4.79;
            spring = "easy";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 4.1;
            spring = "easy";
            style = "popin 87%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 1.49;
            bezier = "linear";
            style = "popin 87%";
          }
          {
            leaf = "fadeIn";
            enabled = true;
            speed = 1.73;
            bezier = "almostLinear";
          }
          {
            leaf = "fadeOut";
            enabled = true;
            speed = 1.46;
            bezier = "almostLinear";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 3.03;
            bezier = "quick";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 3.81;
            bezier = "easeOutQuint";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 4;
            bezier = "easeOutQuint";
            style = "fade";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 1.5;
            bezier = "linear";
            style = "fade";
          }
          {
            leaf = "fadeLayersIn";
            enabled = true;
            speed = 1.79;
            bezier = "almostLinear";
          }
          {
            leaf = "fadeLayersOut";
            enabled = true;
            speed = 1.39;
            bezier = "almostLinear";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 1.94;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "workspacesIn";
            enabled = true;
            speed = 1.21;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "workspacesOut";
            enabled = true;
            speed = 1.94;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "zoomFactor";
            enabled = true;
            speed = 7;
            bezier = "quick";
          }
        ];

        gesture = {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        };

        # kitty asks to be maximized, which made new windows cover the existing ones
        window_rule = {
          name = "suppress-maximize-events";
          match.class = ".*";
          suppress_event = "maximize";
        };

        bind = map (args: {_args = args;}) (
          [
            ["SUPER + T" (mkLuaInline "hl.dsp.exec_cmd(terminal)")]
            ["SUPER + F" (mkLuaInline "hl.dsp.exec_cmd(browser)")]
            ["SUPER + E" (mkLuaInline "hl.dsp.exec_cmd(fileManager)")]
            ["SUPER + C" (mkLuaInline ''hl.dsp.exec_cmd("claude-desktop")'')]
            ["SUPER + Q" (mkLuaInline "hl.dsp.window.close()")]
            ["SUPER + M" (mkLuaInline "hl.dsp.exit()")]
            ["SUPER + V" (mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')]

            ["SUPER + Space" (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg panel-toggle launcher")'')]
            ["SUPER + S" (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg panel-toggle control-center")'')]
            ["ALT + Tab" (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg window-switcher hold")'')]
            ["SUPER + L" (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg session lock")'')]
            ["SUPER + SHIFT + S" (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg screenshot-region")'')]

            ["SUPER + left" (mkLuaInline ''hl.dsp.focus({ direction = "left" })'')]
            ["SUPER + right" (mkLuaInline ''hl.dsp.focus({ direction = "right" })'')]
            ["SUPER + up" (mkLuaInline ''hl.dsp.focus({ direction = "up" })'')]
            ["SUPER + down" (mkLuaInline ''hl.dsp.focus({ direction = "down" })'')]

            ["SUPER + mouse:272" (mkLuaInline "hl.dsp.window.drag()") {mouse = true;}]
            ["SUPER + mouse:273" (mkLuaInline "hl.dsp.window.resize()") {mouse = true;}]

            [
              "XF86AudioRaiseVolume"
              (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg volume-up")'')
              {
                locked = true;
                repeating = true;
              }
            ]
            [
              "XF86AudioLowerVolume"
              (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg volume-down")'')
              {
                locked = true;
                repeating = true;
              }
            ]
            [
              "XF86AudioMute"
              (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg volume-mute")'')
              {
                locked = true;
                repeating = true;
              }
            ]
            [
              "XF86MonBrightnessUp"
              (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg brightness-up")'')
              {
                locked = true;
                repeating = true;
              }
            ]
            [
              "XF86MonBrightnessDown"
              (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg brightness-down")'')
              {
                locked = true;
                repeating = true;
              }
            ]
          ]
          # workspaces 1 to 10, where key 0 is workspace 10
          ++ builtins.genList (i: ["SUPER + ${toString (lib.mod (i + 1) 10)}" (mkLuaInline "hl.dsp.focus({ workspace = ${toString (i + 1)} })")]) 10
          ++ builtins.genList (i: ["SUPER + SHIFT + ${toString (lib.mod (i + 1) 10)}" (mkLuaInline "hl.dsp.window.move({ workspace = ${toString (i + 1)} })")]) 10
        );
      };
    };

    # qt apps on xwayland (e.g. virtualbox) take their scale from Xft.dpi
    systemd.user.services.xwayland-dpi = {
      Unit = {
        Description = "set Xft.dpi for xwayland apps";
        PartOf = ["hyprland-session.target"];
        After = ["hyprland-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString (pkgs.writeShellScript "xwayland-dpi" ''
          echo "Xft.dpi: ${toString (96 * osConfig.irene.programs.hyprland.xwaylandScale)}" | ${pkgs.xrdb}/bin/xrdb -merge
        '');
      };
      Install.WantedBy = ["hyprland-session.target"];
    };
  };
}
