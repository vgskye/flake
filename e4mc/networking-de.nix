{lib, ...}: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = "209.38.192.1";
    defaultGateway6 = {
      address = "2a03:b0c0:3:d0::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "209.38.210.83";
            prefixLength = 19;
          }
          {
            address = "10.19.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a03:b0c0:3:d0::4c5:2001";
            prefixLength = 64;
          }
          {
            address = "fe80::f446:1cff:fec4:e7ff";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "209.38.192.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "2a03:b0c0:3:d0::1";
            prefixLength = 128;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="f6:46:1c:c4:e7:ff", NAME="eth0"
    ATTR{address}=="a2:41:96:12:55:63", NAME="eth1"
  '';
  networking.firewall.allowedTCPPorts = [8488];
  networking.firewall.allowedUDPPorts = [8488];
}
