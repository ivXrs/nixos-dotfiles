{
  config,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.libreoffice = {
    enable = lib.mkEnableOption "libreoffice";

    dictionaries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["es_ES"];
      description = "hunspell dictionaries to install, using nixpkgs hunspellDicts attribute names.";
    };
  };

  config = lib.mkIf config.irene.programs.libreoffice.enable {
    environment.systemPackages =
      [
        pkgs.libreoffice
        pkgs.hunspell
      ]
      ++ map (name: pkgs.hunspellDicts.${name}) config.irene.programs.libreoffice.dictionaries;
  };
}
