{
  pkgs,
  ...
}: {
  networking.bridges = {
    vmhost0 = {
      interfaces = [
        "vm0"
      ];
    };
  };

  networking.interfaces  = {
    vm0 = {
      virtual = true;
      virtualType = "tap";
      virtualOwner = "vm0";
    };
    vmhost0 = {
      ipv4.addresses = [
        {
          address = "10.86.77.1";
          prefixLength = 24;
        }
      ];
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp5s0";
    internalIPs = [
      "10.86.77.0/24"
    ];
  };

  networking.nftables.enable = true;

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      port = 0;
      interface = "vmhost0";
      bind-interfaces = true;
      dhcp-range = "10.86.77.2,10.86.77.254,255.255.255.0,12h";
      dhcp-option = "option:dns-server,1.1.1.1,1.0.0.1";
      dhcp-authoritative = true;
      no-resolv = true;
    };
  };

  users.users.vm0 = {
    group = "vm0";
    isSystemUser = true;
    home = "/vm0";
    createHome = true;
    shell = pkgs.dash;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBS7egIeC7rCo9RumuBUmKa/2gJ9aHjuOZ9OSWL+1ISt"
    ];
  };

  users.groups.vm0 = {
  };

  systemd.services.vm0 = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "dnsmasq.service" ];
    serviceConfig = {
      Type = "simple";
      User = "vm0";
      Group = "vm0";
      Restart = "always";
      ExecStart = "${pkgs.screen}/bin/screen -DmS vm "
        + "${pkgs.cloud-hypervisor}/bin/cloud-hypervisor "
        + "--kernel ${pkgs.OVMF-cloud-hypervisor.fd}/FV/CLOUDHV.fd "
        + "--disk path=/vm0.img,image_type=raw path=/nixos.iso,image_type=raw "
        + "--cpus boot=2 "
        + "--balloon size=0,free_page_reporting=on "
        + "--memory size=6G "
        + "--net tap=vm0";
    };
  };

  networking.dhcpcd.denyInterfaces = [
    "vmhost0"
    "vm0"
  ];

  services.openssh = 
    let
      jail = pkgs.writeShellScript "vm-attach.sh" ''
        exec ${pkgs.screen}/bin/screen -r vm
      '';
    in
    {
    enable = true;
    ports = [22093];
    settings = {
      AllowUsers = ["vm0"];
      DisableForwarding = true;
      ForceCommand = "${jail}";
      PasswordAuthentication = false;
    };
  };
}