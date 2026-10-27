{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.irene.programs.claude.enable = lib.mkEnableOption "claude code and claude desktop";

  config = lib.mkIf config.irene.programs.claude.enable {
    environment.systemPackages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    ];
  };
}
