{ config, modulesPath, pkgs, lib, ... }:
{
    imports = [
        ./lima-init.nix
    ];

    boot.initrd.availableKernelModules = [ "virtiofs" "virtio_pci" "virtio_blk" "virtio_console" "virtio_net" "simplefb" "xhci_pci" "usbhid" ];
    boot.kernelParams = [ "console=hvc0" ];
    boot.initrd.systemd.enable = true;
    boot.initrd.compressor = "cat";
    boot.loader.systemd-boot = {
        enable = true;
        extraFiles = with pkgs; {
            "shellaa64.efi" = edk2-uefi-shell.efi;
        };
        extraEntries = {
            "shellaa64.conf" = ''
              title EFI Shell
              efi /shellaa64.efi
            '';
        };
    };
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    virtualisation.rosetta.enable = true;

    # ssh
    services.openssh.enable = true;
    services.openssh.permitRootLogin = "yes";
    users.users.root.password = "nixos";

    security = {
        sudo.wheelNeedsPassword = false;
    };

    # system mounts
    # /boot is defined in nixos-generators/formats/raw-efi
    fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
        options = [ "noatime" "nodiratime" "discard" ];
    };

    # pkgs
    environment.systemPackages = with pkgs; [
        vim
        direnv
    ];

    nixpkgs.hostPlatform = "aarch64-linux";
}
