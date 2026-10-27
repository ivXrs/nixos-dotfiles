{inputs, ...}: {
  imports = [
    "${inputs.self}/modules/nixos/boot"
    "${inputs.self}/modules/nixos/network"
    "${inputs.self}/modules/nixos/desktop"
    "${inputs.self}/modules/nixos/home-manager"
    "${inputs.self}/modules/nixos/locale"
    "${inputs.self}/modules/nixos/nix"
    "${inputs.self}/modules/nixos/programs"
    "${inputs.self}/modules/nixos/suites"
    "${inputs.self}/modules/nixos/users"
  ];

  irene = {
    boot.enable = true;

    network = {
      enable = true;
      hostName = "vm";
    };

    desktop.enable = true;

    locale = {
      enable = true;
      defaultLocale = "es_ES.UTF-8";
      keyboardLayout = "es";
    };

    nix.enable = true;

    home-manager.enable = true;

    suites = {
      coding.enable = true;
      cli.enable = true;
      desktop.enable = true;
    };

    users = {
      enable = true;

      profiles.aitor = {
        description = "aitor ivars";
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
          "input"
          "vboxsf"
        ];
        initialPassword = "1234";
      };
    };
  };

  home-manager.users.aitor = "${inputs.self}/homes/aitor";

  system.stateVersion = "26.11";
}
