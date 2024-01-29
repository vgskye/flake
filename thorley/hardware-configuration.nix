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
  imports = [
    ../mobile-nixos/modules/quirks/qualcomm/sdm845-modem.nix
    ../mobile-nixos/modules/quirks/audio.nix
    ../mobile-nixos/modules/kernel-config.nix
    ../mobile-nixos/devices/families/mainline-chromeos-sc7180/sound.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages =
  let
    kernel = pkgs.callPackage ../mobile-nixos/devices/families/mainline-chromeos-sc7180/kernel {};
    # lie to make the assertion not die
    kernelLies = kernel.overrideAttrs (old: {
      features = [];
    });
    # kernel = pkgs.callPackage ./kernel.nix {};
  in pkgs.linuxPackagesFor kernelLies;

  networking.wireless.enable = lib.mkDefault true;
  networking.wireless.userControlled.enable = lib.mkDefault true;

  # All the required stuff's built-in thru the defconfig anyways
  boot.initrd.includeDefaultModules = false;

  # boot.kernelPatches = [
  #   {
  #     name = "qcm";
  #     patch = null;
  #     extraStructuredConfig = import ./qualcomm_cros.config pkgs;
  #   }
  # ];

  mobile.kernel.structuredConfig = [
    (helpers:
      with helpers; {
        MODULES = yes;
        I2C_SMBUS = module;
        BATTERY_SBS = module;
        CHARGER_SBS = module;
        MANAGER_SBS = module;
      })
  ];

  hardware.firmware = [
    pkgs.chromeos-sc7180-unredistributable-firmware
    (pkgs.callPackage ../mobile-nixos/devices/families/mainline-chromeos-sc7180/firmware {})
  ];

  system.build.fsImage = pkgs.callPackage (modulesPath + "/../lib/make-ext4-fs.nix") {
    storePaths = config.system.build.toplevel;
    populateImageCommands = "${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot";
    volumeLabel = "thorley";
  };

  hardware.deviceTree = {
    enable = true;
    filter = "*sc7180*.dtb";
    name = "qcom/sc7180-trogdor-wormdingler-rev1-boe.dtb";
  };

  boot.swraid.enable = false;

  boot.initrd.availableKernelModules = [
    "sbs-battery"
    "sbs-charger"
    "sbs-manager"
  ];

  # Ensure orientation match with keyboard.
  services.udev.extraHwdb = lib.mkBefore ''
    sensor:accel-display:modalias:platform:cros-ec-accel:*
      ACCEL_MOUNT_MATRIX=0, 1, 0; -1, 0, 0; 0, 0, -1
  '';

  boot.kernelParams = lib.mkBefore ["console=ttyMSM0,115200n8"];

  systemd.services."serial-getty@ttyMSM0" = {
    enable = true;
    wantedBy = ["multi-user.target"];
  };

  mobile.quirks.qualcomm.sc7180-modem.enable = true;
  nixpkgs.overlays = [
    (final: super: {
      chromeos-sc7180-unredistributable-firmware = final.callPackage ../mobile-nixos/devices/families/mainline-chromeos-sc7180/firmware/non-redistributable.nix {};
    })
    (import ../mobile-nixos/overlay/overlay.nix)
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/thorley";
    fsType = "ext4";
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = "aarch64-linux";
}