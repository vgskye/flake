# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: let
  channelPath = "/etc/nix/channels/nixpkgs";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.nixPath = [
    "nixpkgs=${channelPath}"
  ];
  systemd.tmpfiles.rules = [
    "L+ ${channelPath} - - - - ${pkgs.path}"
  ];
  programs.command-not-found.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bridget"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  virtualisation.docker.enable = true;

  virtualisation.docker.package = pkgsUnstable.docker;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };

  age.identityPaths = ["/nix/agenix-key"];

  services.maddy = rec {
    enable = true;
    openFirewall = true;
    config = builtins.readFile ./maddy.conf;
    hostname = "mail.skyevg.systems";
    primaryDomain = "skye.vg";
    localDomains = ["$(primary_domain)" "skyevg.systems" "pridecraft.gay"];
    tls = {
      loader = "file";
      certificates = [
        {
          keyPath = "/var/lib/acme/${hostname}/key.pem";
          certPath = "/var/lib/acme/${hostname}/fullchain.pem";
        }
      ];
    };
  };

  age.secrets.cf-api-key = {
    file = ../secrets/cf-api-key.age;
    mode = "400";
    owner = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@skye.vg";
    certs = {
      "mail.skyevg.systems" = {
        dnsResolver = "1.1.1.1";
        dnsProvider = "rfc2136";
        credentialsFile = config.age.secrets.cf-api-key.path;
        group = "maddy";
      };
    };
  };

  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    #   packages = with pkgs; [
    #     firefox
    #     thunderbird
    #   ];
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBS7egIeC7rCo9RumuBUmKa/2gJ9aHjuOZ9OSWL+1ISt bs2k@bs2k-archlinux"
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvYcHrhpXEr/Rw0mscDAj3M88ACfwqO39GKEyzViY9E me@2201117tg"
    # ];
  };

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0" "docker0"];
  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "vm.max_map_count" = 262144;
  };

  systemd.timers.backups = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 00,12:00:00";
      Unit = "backups.service";
    };
  };

  age.secrets.restic-secrets = {
    file = ../secrets/restic-secrets.age;
    mode = "400";
    owner = "root";
  };

  systemd.services.backups = let
    script =
      builtins.replaceStrings [
        "%%SECRETS_FILE%%"
        "%%CURL_BIN%%"
        "%%SQLITE3_BIN%%"
        "%%DOCKER_BIN%%"
        "%%RESTIC_BIN%%"
      ] [
        config.age.secrets.restic-secrets.path
        "${pkgs.curl}/bin/curl"
        "${pkgs.sqlite}/bin/sqlite3"
        "${pkgs.docker}/bin/docker"
        "${pkgs.restic}/bin/restic"
      ] (builtins.readFile ./backup.sh);
  in {
    inherit script;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  networking.nameservers = [
    "2620:fe::fe"
    "2620:fe::9"
    "9.9.9.9"
    "149.112.112.112"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  programs.mosh.enable = true;

  networking.firewall.allowedTCPPorts = [80 443 465 993 995 25565];
  networking.firewall.allowedUDPPorts = [443];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
