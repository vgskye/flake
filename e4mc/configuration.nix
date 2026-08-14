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
    defaults.email = "skye@is-quite.gay";
    certs = {
      e4mc = {
        domain = "${region}.e4mc.link";
        extraDomainNames = ["*.${region}.e4mc.link" "broker.e4mc.link"];
        dnsProvider = "bunny";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.age.secrets.e4mc-cf-key.path;
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
            reverse_proxy /.well-known/dialtone_ticket/* http://127.0.0.1:25585
            respond /ping "OK"
            redir https://e4mc.link
          }
        '';
      };
      e4mc-broker = {
        hostName = "broker.e4mc.link";
        serverAliases = ["nbroker.e4mc.link"];
        useACMEHost = "e4mc";
        extraConfig = ''
          header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
          header X-Clacks-Overhead "GNU Terry Pratchett"
          header X-Content-Type-Options "nosniff"
          header Content-Type application/json
          respond `{"id":"${region}","host":"${region}.e4mc.link","port":25575}`
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443 25565 8080 8443];
  networking.firewall.allowedUDPPorts = [443 25575 7842];

  services.telegraf.extraConfig = {
    inputs.prometheus = {
      urls = [
        # "http://127.0.0.1:25585/metrics"
        "http://127.0.0.1:9090/metrics"
      ];
    };
  };

  systemd.services.iroh-relay =
  let
    pkg = pkgs.callPackage ./iroh-relay.nix {};
  in
  {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    description = "iroh relay server";
    serviceConfig = {
      Type = "simple";
      User = "iroh-relay";
      Group = "acme";
      ExecStart = "${pkg}/bin/iroh-relay -c ${./relay-config.toml}";
      Restart = "on-failure";
      LimitNOFILE = "infinity";
    };
  };

  users.users.iroh-relay = {
    description = "iroh relay server";
    useDefaultShell = true;
    group = "acme";
    isSystemUser = true;
  };

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "23.05";
}
