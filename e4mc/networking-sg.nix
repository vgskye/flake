{lib, ...}: {
  networking.interfaces.enp1s0.ipv6.addresses = [
    {
      address = "2a01:4ff:2f0:2bc9::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp1s0";
  };
}