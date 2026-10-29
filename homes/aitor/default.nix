{...}: {
  home.stateVersion = "26.11";

  irene.home-manager = {
    atuin.enable = true;

    brave.enable = true;

    fzf.enable = true;

    git = {
      enable = true;
      userName = "ivXrs";
      userEmail = "283170461+ivXrs@users.noreply.github.com";
      sshKey = "~/.ssh/id-github";
    };

    hyprland.enable = true;

    kitty.enable = true;

    noctalia.enable = true;

    starship.enable = true;

    theming.enable = true;

    vesktop.enable = true;

    zsh.enable = true;
  };
}
