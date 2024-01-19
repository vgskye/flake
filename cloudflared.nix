{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.cloudflared;
in {
  options = {
    services.cloudflared = {
      enable =
        mkEnableOption "CloudFlare Tunnel daemon (and DNS-over-HTTPS client)";

      token = mkOption {
        default = "";
        type = types.str;
        description = lib.mdDoc "The managed tunnel token for cloudflared.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cloudflared = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      description = "CloudFlare Tunnel daemon (and DNS-over-HTTPS client)";
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run --token ${cfg.token}";
        Restart = "always";
        RestartSec = 12;
        DynamicUser = true;
        CacheDirectory = "cloudflared";
      };
    };
  };
}
