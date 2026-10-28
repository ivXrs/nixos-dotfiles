{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    "${inputs.self}/modules/nixos/audio"
    "${inputs.self}/modules/nixos/boot"
    "${inputs.self}/modules/nixos/network"
    "${inputs.self}/modules/nixos/desktop"
    "${inputs.self}/modules/nixos/home-manager"
    "${inputs.self}/modules/nixos/locale"
    "${inputs.self}/modules/nixos/nix"
    "${inputs.self}/modules/nixos/nvidia"
    "${inputs.self}/modules/nixos/programs"
    "${inputs.self}/modules/nixos/suites"
    "${inputs.self}/modules/nixos/users"
  ];

  irene = {
    audio.enable = true;

    boot.enable = true;

    network = {
      enable = true;
      hostName = "roxas";
    };

    desktop.enable = true;

    locale = {
      enable = true;
      defaultLocale = "es_ES.UTF-8";
      keyboardLayout = "es";
    };

    nix.enable = true;

    nvidia = {
      enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    home-manager.enable = true;

    suites = {
      coding.enable = true;
      cli.enable = true;
      desktop.enable = true;
      virtualisation.enable = true;
      vpn.enable = true;
    };

    users = {
      enable = true;

      profiles.aitor = {
        description = "aitor ivars";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        initialPassword = "1234";
        shell = pkgs.zsh;
      };
    };
  };

  home-manager.users.aitor = "${inputs.self}/homes/aitor";

  system.stateVersion = "26.11";
}
