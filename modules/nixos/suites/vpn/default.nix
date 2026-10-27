{
  config,
  lib,
  ...
}: {
  options.irene.suites.vpn.enable = lib.mkEnableOption "vpn suite";

  config = lib.mkIf config.irene.suites.vpn.enable {
    irene.programs.tailscale.enable = true;
  };
}
