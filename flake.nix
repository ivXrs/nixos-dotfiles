{
  description = "nixos dotfiles";

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
