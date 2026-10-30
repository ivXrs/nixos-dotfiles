{
  config,
  lib,
  ...
}: {
  options.irene.home-manager.mime-apps.enable = lib.mkEnableOption "default applications";

  config = lib.mkIf config.irene.home-manager.mime-apps.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        lib.genAttrs [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ] (_: "brave-browser.desktop")
        // lib.genAttrs ["application/pdf"] (_: "org.gnome.Papers.desktop")
        // lib.genAttrs [
          "image/png"
          "image/jpeg"
          "image/gif"
          "image/webp"
          "image/bmp"
          "image/tiff"
          "image/svg+xml"
          "image/avif"
          "image/heif"
        ] (_: "org.gnome.Loupe.desktop")
        // lib.genAttrs [
          "video/mp4"
          "video/x-matroska"
          "video/webm"
          "video/quicktime"
          "video/x-msvideo"
          "audio/mpeg"
          "audio/flac"
          "audio/ogg"
          "audio/wav"
          "audio/mp4"
        ] (_: "vlc.desktop")
        // lib.genAttrs ["inode/directory"] (_: "org.gnome.Nautilus.desktop")
        // lib.genAttrs [
          "text/plain"
          "text/markdown"
          "application/x-shellscript"
          "application/json"
        ] (_: "nvim.desktop");
    };
  };
}
