# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot.initrd.luks.devices.luksroot = {
    device = "/dev/disk/by-uuid/8d1325f2-bf42-4b2e-a6bb-68850f2edb97";
    allowDiscards = true;
  };
  boot.initrd.luks.devices.lukshdd = {
    device = "/dev/disk/by-uuid/44f7145d-d50a-4d47-a1b0-a0609aa49f51";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4CF5-320F";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/luksroot";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime" "subvol=nix"];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/luksroot";
    fsType = "btrfs";
    options = ["compress=zstd" "subvol=home"];
  };

  fileSystems."/persist" = {
    device = "/dev/mapper/luksroot";
    fsType = "btrfs";
    options = ["compress=zstd" "subvol=persist"];
    neededForBoot = true;
  };

  fileSystems."/mnt" = {
    device = "/dev/mapper/lukshdd";
    fsType = "btrfs";
  };

  # fileSystems."/syzygy" = {
  #   device = "/dev/disk/by-uuid/14d93ac7-5501-4f1c-9869-26361c42fb4e";
  #   options = [ "noatime" ];
  #   fsType = "btrfs";
  # };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp39s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
