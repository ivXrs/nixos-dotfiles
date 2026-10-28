{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.irene.home-manager.kitty.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      shellIntegration.enableZshIntegration = true;
      settings = {
        # cursor trail always on: a zero threshold animates even one-cell moves
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.4";
        cursor_trail_start_threshold = 0;

        # animated blink that never stops
        cursor_blink_interval = "0.5 ease-in-out";
        cursor_stop_blinking_after = 0;

        background_opacity = "0.95";
        window_padding_width = 8;
        confirm_os_window_close = 0;
        scrollback_lines = 10000;

        # tab bar is hidden while there is a single tab
        tab_bar_style = "powerline";
        tab_bar_min_tabs = 2;
      };
    };
  };
}
