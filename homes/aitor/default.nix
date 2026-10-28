{...}: {
  home.stateVersion = "26.11";

  irene.home-manager = {
    atuin.enable = true;

    fzf.enable = true;

    git = {
      enable = true;
      userName = "ivXrs";
      userEmail = "283170461+ivXrs@users.noreply.github.com";
      sshKey = "~/.ssh/id-github";
    };

    kitty.enable = true;

    starship.enable = true;

    zsh.enable = true;
  };
}
