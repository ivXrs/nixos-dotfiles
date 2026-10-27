{
  config,
  lib,
  ...
}: {
  options.irene.network = {
    enable = lib.mkEnableOption "network configuration";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "hostname of the machine.";
    };
  };

  config = lib.mkIf config.irene.network.enable {
    networking = {
      inherit (config.irene.network) hostName;
      networkmanager.enable = true;
      firewall.enable = true;
    };

    services.openssh.enable = true;
  };
}
