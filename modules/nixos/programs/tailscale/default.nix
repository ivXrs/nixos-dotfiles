{
  config,
  lib,
  ...
}: {
  options.irene.programs.tailscale = {
    enable = lib.mkEnableOption "tailscale";

    operator = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "user allowed to control tailscale without sudo.";
    };
  };

  config = lib.mkIf config.irene.programs.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraSetFlags = lib.optional (config.irene.programs.tailscale.operator != null) "--operator=${config.irene.programs.tailscale.operator}";
    };

    networking.firewall = {
      trustedInterfaces = [config.services.tailscale.interfaceName];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
}
