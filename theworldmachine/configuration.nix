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
  };

  age.secrets.mailer-cf-key = {
    file = ../secrets/mailer-cf-key.age;
    mode = "400";
    owner = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@skye.vg";
    certs = {
      mail = {
        domain = "mail.is-quite.gay";
        extraDomainNames = ["autodiscover.is-quite.gay" "autoconfig.is-quite.gay"];
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.mailer-cf-key.path;
        postRun = ''
          cp /var/lib/acme/mail/fullchain.pem /opt/mailcow-dockerized/data/assets/ssl/cert.pem
          cp /var/lib/acme/mail/key.pem /opt/mailcow-dockerized/data/assets/ssl/key.pem
          export PATH=$PATH:${pkgs.docker}/bin
          postfix_c=$(docker ps -qaf name=postfix-mailcow)
          dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
          nginx_c=$(docker ps -qaf name=nginx-mailcow)
          docker restart $postfix_c $dovecot_c $nginx_c
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [25 465 587 993];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";
  programs.mosh.enable = true;
  
  system.stateVersion = "24.05";
}