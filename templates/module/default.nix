{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  # imports = [ ];

  options.namespace.module = {
    enable = lib.mkEnableOption "module.";

    option = lib.mkOption {
      type = lib.types.null;
      default = null;
      description = "";
    };
  };

  config = lib.mkIf config.namespace.module.enable {
    # ---
  };
}
