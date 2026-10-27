{
  config,
  lib,
  ...
}: {
  options.irene.programs.tailscale.enable = lib.mkEnableOption "tailscale";

  config = lib.mkIf config.irene.programs.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    networking.firewall = {
      trustedInterfaces = [config.services.tailscale.interfaceName];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
}
