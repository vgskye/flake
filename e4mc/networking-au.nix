{lib, ...}: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = "170.64.160.1";
    defaultGateway6 = {
      address = "2400:6180:10:200::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "170.64.160.178";
            prefixLength = 20;
          }
          {
            address = "10.49.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2400:6180:10:200::26:1000";
            prefixLength = 64;
          }
          {
            address = "fe80::a869:efff:fea9:fbb8";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "170.64.160.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "2400:6180:10:200::1";
            prefixLength = 128;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="aa:69:ef:a9:fb:b8", NAME="eth0"
    ATTR{address}=="22:1c:77:d4:67:f9", NAME="eth1"
  '';
}
