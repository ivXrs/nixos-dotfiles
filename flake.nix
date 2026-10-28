{
  description = "nixos dotfiles";

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations = {
      roxas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/roxas];
        specialArgs = {inherit inputs;};
      };

      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/vm];
        specialArgs = {inherit inputs;};
      };
    };
  };
}
