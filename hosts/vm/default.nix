{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ./disko.nix
    ./hardware.nix
    ./configuration.nix
  ];
}
