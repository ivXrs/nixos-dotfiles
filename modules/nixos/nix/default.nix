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
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    };
  };
}
