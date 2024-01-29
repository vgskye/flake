{ linux_latest, ... }:
linux_latest.override {
  argsOverride = {
    defconfig = "sc7180_cros_defconfig";
    kernelPatches = [
    {
      name = "defconfig";
      patch = ./defconfig.patch;
    }
    ];
  };
}