# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  channelPath = "/etc/nix/channels/nixpkgs";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  nix.nixPath = [
    "nixpkgs=${channelPath}"
  ];

  systemd.tmpfiles.rules = [
    "L+ ${channelPath} - - - - ${pkgs.path}"
  ];

  programs.command-not-found.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "theworldmachine";

  time.timeZone = "Europe/Berlin";

  virtualisation.docker.enable = true;

  age.identityPaths = ["/nix/agenix-key"];

  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBS7egIeC7rCo9RumuBUmKa/2gJ9aHjuOZ9OSWL+1ISt"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;

  services.tailscale.enable = true;
  programs.mosh.enable = true;
  
  system.stateVersion = "24.05";
}
