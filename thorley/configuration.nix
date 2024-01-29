# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "thorley";

  time.timeZone = "Asia/Seoul";

  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    password = "hunter2"; # CHANGEME
  };

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "23.05";
}
