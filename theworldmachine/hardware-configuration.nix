{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "nvme" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/69F0-AB49";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  networking.hostId = "e4c9bd10";
  
  networking.useDHCP = false;
  networking.interfaces.enp5s0.ipv6.addresses = [
    {
      address = "2a01:4f9:3071:1ba7::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp5s0";
  };
  networking.interfaces.enp5s0.ipv4.addresses = [
    {
      address = "65.21.11.27";
      prefixLength = 27;
    }
  ];
  networking.defaultGateway = {
    address = "65.21.11.1";
    interface = "enp5s0";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}