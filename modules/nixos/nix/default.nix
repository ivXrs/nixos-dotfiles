{
  config,
  lib,
  ...
}: {
  options.irene.nix.enable = lib.mkEnableOption "nix configuration";

  config = lib.mkIf config.irene.nix.enable {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      accept-flake-config = true;
    };
  };
}
