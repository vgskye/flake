# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: let
  channelPath = "/etc/nix/channels/nixpkgs";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = lib.mkBefore ["https://niko.cat-snares.ts.net:9443/skye"];
  };

  nix.nixPath = [
    "nixpkgs=${channelPath}"
  ];

  services.flatpak.enable = true;

  programs.command-not-found.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    settings = {
      console-mode = "0";
      editor = null;
      timeout = "menu-hidden";
    };
  };

  boot.plymouth = {
    enable = true;
    theme = "breeze";
    extraConfig = ''
      DeviceScale=1
    '';
  };

  boot = {
    # consoleLogLevel = 3;
    # initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      # "boot.shell_on_fail"
      # "udev.log_priority=3"
      # "rd.systemd.show_status=auto"
      "rtw89_pci.disable_aspm_l1=y"
      "rtw89_pci.disable_aspm_l1ss=y"
    ];
  };

  boot.tmp.useTmpfs = true;

  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModulePackages = [
    (pkgs.callPackage (import ../uwurandom.nix) {
      kernel = config.boot.kernelPackages.kernel;
    })
  ];
  boot.kernelModules = ["uwurandom"];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "florence"; # Florence Ambrose, Engineer
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

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
  services.xserver.enable = true;
  hardware.graphics.enable = true;
  # hardware.opengl.driSupport = true;
  # hardware.opengl.driSupport32Bit = true;

  # hardware.nvidia.open = true;
  # services.xserver.videoDrivers = ["amdgpu" "nvidia"];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [pkgs.fcitx5-hangul];
    # uim.toolbar = "gtk-systray";
    # ibus.engines = with pkgs.ibus-engines; [ hangul ];
  };
  # Enable the Plasma 5 Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  hardware.pulseaudio.enable = false;

  hardware.bluetooth.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  age.identityPaths = ["/nix/agenix-key"];

  age.secrets.password = {file = ../secrets/password.age;};

  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "tss" "input"];
    hashedPasswordFile = config.age.secrets.password.path;
  };

  programs.steam.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  # services.tlp.enable = true;
  # services.tlp.settings = {
  #   CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #   PLATFORM_PROFILE_ON_BAT = "low-power";
  #   CPU_BOOST_ON_BAT = 0;
  #   AMDGPU_ABM_LEVEL_ON_BAT = 3;
  # };
  services.tuned.enable = true;
  services.power-profiles-daemon.enable = false;

  services.keyd = {
    enable = true;
    keyboards = {
      hammer = {
        ids = [ "k:0001:0001:70533846" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
            leftshift = "overload(shift, S-9)";
            rightshift = "overload(shift, S-0)";
            f23 = "f13";
          };
          global = {
            overload_tap_timeout = 200;
          };
        };
      };
    };
  };

  virtualisation = {
    docker.enable = true;
    waydroid.enable = true;
    libvirtd.enable = true;
  };

  programs.nix-ld.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xorg.libxcb
    catppuccin-cursors.macchiatoDark
  ];

  systemd.tmpfiles.rules = [
    "L+ ${channelPath} - - - - ${pkgs.path}"
  ];

  programs.dconf.enable = true;

  services.displayManager.sddm = {
    enable = true;
    theme = "breeze";
    settings.Theme.CursorTheme = "Catppuccin-Macchiato-Dark-Cursors";
    wayland.enable = true;
  };

  # boot.plymouth = {
  #   enable = true;
  #   theme = "bgrt";
  # };

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

  programs.kdeconnect.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 25565 ];
  # networking.firewall.allowedUDPPorts = [ 25565 ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "aarch64-linux"
  ];

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
