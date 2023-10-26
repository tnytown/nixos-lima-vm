{ config, modulesPath, pkgs, lib, ... }:
{
    imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        ./lima-init.nix
    ];

    boot.initrd.availableKernelModules = [ "virtiofs" ];
    boot.loader.systemd-boot.enable = true;
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

    fileSystems."/boot" = {
        device = "/dev/vda1";  # /dev/disk/by-label/ESP
        fsType = "vfat";
    };
    fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        autoResize = true;
        fsType = "ext4";
        options = [ "noatime" "nodiratime" "discard" ];
    };

    # pkgs
    environment.systemPackages = with pkgs; [
        vim
        direnv
    ];
}
