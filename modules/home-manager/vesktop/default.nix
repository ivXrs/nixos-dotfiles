{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.vesktop.enable = lib.mkEnableOption "vesktop";

  config = lib.mkIf config.irene.home-manager.vesktop.enable {
    programs.vesktop = {
      enable = true;
      package = null;
      mutableSettings = true;
      settings = {
        arRPC = true;
        minimizeToTray = true;
      };
      vencord = {
        mutableSettings = true;
        settings.plugins = lib.genAttrs [
          "NoTrack"
          "ClearURLs"
          "CrashHandler"
          "BetterSettings"
          "ReadAllNotificationsButton"
          "NoReplyMention"
          "CallTimer"
          "MemberCount"
          "WhoReacted"
          "TypingIndicator"
          "PlatformIndicators"
          "PermissionsViewer"
          "ShikiCodeblocks"
          "Translate"
          "SilentTyping"
          "CopyFileContents"
          "ImageZoom"
          "ViewIcons"
          "ReverseImageSearch"
          "VolumeBooster"
          "FixYoutubeEmbeds"
          "FavoriteGifSearch"
          "SpotifyControls"
        ] (_: {enabled = true;});
      };
    };
  };
}
