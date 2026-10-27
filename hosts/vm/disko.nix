{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 10;
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          lvm = {
            priority = 20;
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs.root = {
        priority = 10;
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = ["-f"];
          subvolumes = {
            "@" = {
              mountpoint = "/";
              mountOptions = ["compress=zstd" "noatime"];
            };
            "@home" = {
              mountpoint = "/home";
              mountOptions = ["compress=zstd" "noatime"];
            };
            "@nix" = {
              mountpoint = "/nix";
              mountOptions = ["compress=zstd" "noatime"];
            };
            #"@snapshots" = {
            #  mountpoint = "/.snapshots";
            #  mountOptions = ["compress=zstd" "noatime"];
            #};
          };
        };
      };
    };
  };
}
