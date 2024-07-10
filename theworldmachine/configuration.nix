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

  time.timeZone = "Europe/Helsinki";

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

  users.users.gaybox = {
    group = "gaybox";
    isSystemUser = true;
  };

  users.groups.gaybox = {
  };

  systemd.services.gaybox = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = "gaybox";
      Group = "gaybox";
      ExecStart = "/gaybox/startserver.sh";
    };
    path = [
      pkgs.jdk
      pkgs.wget
    ];
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

  systemd.timers.backups = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      Unit = "backups.service";
    };
  };

  age.secrets.restic-secrets = {
    file = ../secrets/restic-secrets-twm.age;
    mode = "400";
    owner = "root";
  };

  systemd.services.backups = {
    script = builtins.readFile ./backup.sh;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = config.age.secrets.restic-secrets.path;
    };
    path = [
      pkgs.curl
      pkgs.sqlite
      pkgs.docker
      pkgs.restic
      pkgs.openssh
      pkgs.bash
      pkgs.which
    ];
  };

  networking.firewall.allowedTCPPorts = [80 443 25 465 587 993 25565 8100];
  networking.firewall.allowedUDPPorts = [80 443 24454];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";
  programs.mosh.enable = true;
  
  system.stateVersion = "24.05";
}