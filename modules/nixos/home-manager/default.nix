{
  config,
  inputs,
  lib,
  ...
}: {
  options.irene.home-manager.enable = lib.mkEnableOption "home-manager integration";

  config = lib.mkIf config.irene.home-manager.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {inherit inputs;};
      sharedModules = ["${inputs.self}/modules/home-manager"];
    };
  };
}
