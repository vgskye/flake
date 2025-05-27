{
  region,
  config,
  pkgs,
  ...
}: {
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.hostName = "e4mc-${region}";

  age.identityPaths = ["/nix/agenix-key"];

  age.secrets.e4mc-cf-key = {
    file = ../secrets/e4mc-cf-key.age;
    mode = "400";
    owner = "acme";
  };

  age.secrets.clickhouse-pwd = {
    file = ../secrets/clickhouse-pwd.age;
    mode = "040";
    owner = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@skye.vg";
    certs = {
      e4mc = {
        domain = "${region}.e4mc.link";
        extraDomainNames = ["*.${region}.e4mc.link"];
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.e4mc-cf-key.path;
        postRun = ''
          ${pkgs.curl}/bin/curl -X POST http://127.0.0.1:25585/reload-certs
        '';
      };
    };
  };

  services.quiclime = {
    enable = true;
    baseDomain = "${region}.e4mc.link";
    cert = "/var/lib/acme/e4mc/fullchain.pem";
    key = "/var/lib/acme/e4mc/key.pem";
    group = "acme";
    clickhouseUrl = "http://theworldmachine.cat-snares.ts.net:8123";
    clickhouseUser = "quiclime";
    clickhousePasswordPath = config.age.secrets.clickhouse-pwd.path;
    clickhouseDatabase = "default";
    clickhouseTable = "mc_connections_v3";
    blocklistUrl = "https://theworldmachine.cat-snares.ts.net:10443/blacklist.json";
    # sentryDsn = "https://b3d233e4894648ce3e1b451bad2431e7@o4505708658884608.ingest.us.sentry.io/4505742084997120";
  };

  services.caddy = {
    enable = true;
    group = "acme";
    virtualHosts = {
      e4mc = {
        hostName = "${region}.e4mc.link";
        serverAliases = ["*.${region}.e4mc.link"];
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

  networking.firewall.allowedTCPPorts = [80 443 25565];
  networking.firewall.allowedUDPPorts = [443 25575];

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "23.05";
}
