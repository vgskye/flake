{modulesPath, region, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./networking-${region}.nix
  ];
  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
}
