{lib, ...}: {
  networking.interfaces.enp1s0.ipv6.addresses = [
    {
      address = "2a01:4ff:1f0:eb69::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp1s0";
  };
}