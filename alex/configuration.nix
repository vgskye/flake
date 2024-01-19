# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "alex";

  time.timeZone = "Asia/Seoul";

  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  age.identityPaths = ["/nix/agenix-key"];

  age.secrets.e4mc-dns-key = {
    file = ../secrets/e4mc-dns-key.age;
    mode = "400";
    owner = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@skye.vg";
    certs = {
      e4mc = {
        domain = "na.e4mc.link";
        extraDomainNames = ["*.na.e4mc.link"];
        dnsResolver = "1.1.1.1";
        dnsProvider = "rfc2136";
        credentialsFile = config.age.secrets.e4mc-dns-key.path;
        postRun = ''
          ${pkgs.curl}/bin/curl -X POST http://127.0.0.1:25585/reload-certs
        '';
      };
    };
  };

  services.quiclime = {
    enable = true;
    baseDomain = "na.e4mc.link";
    cert = "/var/lib/acme/e4mc/fullchain.pem";
    key = "/var/lib/acme/e4mc/key.pem";
    group = "acme";
  };

  services.caddy = {
    enable = true;
    group = "acme";
    virtualHosts = {
      e4mc = {
        hostName = "na.e4mc.link";
        serverAliases = ["*.na.e4mc.link"];
        useACMEHost = "e4mc";
        extraConfig = ''
          header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
          header X-Clacks-Overhead "GNU Terry Pratchett"
          header X-Content-Type-Options "nosniff"
          route {
            respond /ping "OK"
            redir https://e4mc.link
          }
        '';
      };
    };
  };

  services.tailscale.enable = true;

  networking.firewall.allowedTCPPorts = [80 443 25565];
  networking.firewall.allowedUDPPorts = [443 25575];

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
