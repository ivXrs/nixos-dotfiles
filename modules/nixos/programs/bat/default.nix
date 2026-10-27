{
  config,
  lib,
  ...
}: {
  options.irene.programs.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf config.irene.programs.bat.enable {
    programs.bat.enable = true;
  };
}
