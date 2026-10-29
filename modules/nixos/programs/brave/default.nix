{
  config,
  lib,
  ...
}: {
  options.irene.programs.brave.enable = lib.mkEnableOption "brave policies; the browser itself comes from home-manager";

  config = lib.mkIf config.irene.programs.brave.enable {
    # machine-wide policies that turn off the bundled extras and telemetry
    environment.etc."brave/policies/managed/debloat.json".text = builtins.toJSON {
      BraveAIChatEnabled = false;
      BraveLocalAIEnabled = false;
      BraveNewsDisabled = true;
      BraveP3AEnabled = false;
      BravePlaylistEnabled = false;
      BraveRewardsDisabled = true;
      BraveStatsPingEnabled = false;
      BraveTalkDisabled = true;
      BraveVPNDisabled = true;
      BraveWalletDisabled = true;
      BraveWaybackMachineEnabled = false;
      BraveWebDiscoveryEnabled = false;
      EmailAliasesEnabled = false;
      IPFSEnabled = false;
      TorDisabled = true;
    };
  };
}
