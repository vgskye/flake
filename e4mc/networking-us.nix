{lib, ...}: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = "157.230.80.1";
    defaultGateway6 = {
      address = "2604:a880:400:d0::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "157.230.94.73";
            prefixLength = 20;
          }
          {
            address = "10.10.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2604:a880:400:d0::22c2:d001";
            prefixLength = 64;
          }
          {
            address = "fe80::b084:a1ff:fe66:84ba";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "157.230.80.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "2604:a880:400:d0::1";
            prefixLength = 128;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="b2:84:a1:66:84:ba", NAME="eth0"
    ATTR{address}=="5a:1f:81:8a:6e:1a", NAME="eth1"
  '';
}
