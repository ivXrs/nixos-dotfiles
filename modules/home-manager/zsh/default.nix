{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.irene.home-manager.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;

      history = {
        size = 10000;
        ignoreAllDups = true;
        share = true;
      };

      shellAliases = {
        ls = "eza --icons=auto";
        ll = "eza -l --icons=auto --git";
        la = "eza -la --icons=auto --git";
        lt = "eza --tree --icons=auto";
        cat = "bat";
      };

      initContent = ''
        # case-insensitive completion with a selectable menu
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select

        # key bindings for xterm-like terminals (gnome console, kitty) and terminfo
        zmodload zsh/terminfo

        # home / end
        bindkey '^[[H' beginning-of-line
        bindkey '^[[1~' beginning-of-line
        bindkey '^[OH' beginning-of-line
        bindkey '^[[F' end-of-line
        bindkey '^[[4~' end-of-line
        bindkey '^[OF' end-of-line
        [[ -n $terminfo[khome] ]] && bindkey -- $terminfo[khome] beginning-of-line
        [[ -n $terminfo[kend] ]] && bindkey -- $terminfo[kend] end-of-line

        # ctrl + arrows
        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word

        # delete, ctrl + backspace, ctrl + delete
        bindkey '^[[3~' delete-char
        bindkey '^H' backward-kill-word
        bindkey '^[[3;5~' kill-word
        [[ -n $terminfo[kdch1] ]] && bindkey -- $terminfo[kdch1] delete-char

        # shift + tab
        bindkey '^[[Z' reverse-menu-complete
        [[ -n $terminfo[kcbt] ]] && bindkey -- $terminfo[kcbt] reverse-menu-complete
      '';
    };
  };
}
