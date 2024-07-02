{ lib, pkgs, config, modulesPath, inputs, ... }: let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in {
  imports = [ "${modulesPath}/image/repart.nix" ];

  image.repart = {
    name = "nixos-lima-${inputs.nixpkgs.shortRev or "unstable"}";
    compression = {
      enable = true;
      algorithm = "zstd";
    };
    partitions = {
      "esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
            "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          SizeMinBytes = "200M";
        };
      };
      "root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "nixos";
          Minimize = "guess";
        };
      };
    };
  };
}
