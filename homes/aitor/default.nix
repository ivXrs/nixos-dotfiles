{...}: {
  home.stateVersion = "26.11";

  irene.home-manager = {
    git = {
      enable = true;
      userName = "ivXrs";
      userEmail = "283170461+ivXrs@users.noreply.github.com";
      sshKey = "~/.ssh/id-github";
    };

    zsh.enable = true;
  };
}
