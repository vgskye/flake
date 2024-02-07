# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  channelPath = "/etc/nix/channels/nixpkgs";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./cachix.nix
  ];

  # nix = {
  #   # package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
  #   extraOptions = ''
  #     experimental-features = nix-command flakes ca-derivations
  #   '';
  # };
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://cache.garnix.io"];
    trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };

  nix.nixPath = [
    "nixpkgs=${channelPath}"
  ];

  nixpkgs.overlays = [
    (self: super: {
      # systemd = super.systemd.overrideAttrs (old: {
      #   patches = old.patches ++ [
      #     ./0019-tpm2_context_init-fix-driver-name-checking.patch
      #   ];
      # });
      steam = super.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            portaudio
            # ((pkgs.callPackage ../alvr.nix) { })
            # binutils-unwrapped
            # alsaLib
            # openssl
            # glib
            # (ffmpeg-full.override { nonfreeLicensing = true; samba = null; })
            # cairo
            # pango
            # atk
            # gdk-pixbuf
            # gtk3
            # clang
            # (pkgs.vulkan-tools-lunarg.overrideAttrs (oldAttrs: rec {
            #   patches = [
            #     (fetchurl {
            #       url =
            #         "https://gist.githubusercontent.com/ckiee/038809f55f658595107b2da41acff298/raw/6d8d0a91bfd335a25e88cc76eec5c22bf1ece611/vulkantools-log.patch";
            #       sha256 = "14gji272r53pykaadkh6rswlzwhh9iqsy1y4q0gdp8ai4ycqd129";
            #     })
            #   ];
            # }))
            # vulkan-headers
            # vulkan-loader
            # vulkan-validation-layers
            # xorg.libX11
            # xorg.libXrandr
            # libunwind
            # python3 # for the xcb crate
            # libxkbcommon
            # jack2
          ];
      };
    })
  ];

  services.flatpak.enable = true;

  services.beesd.filesystems = {
    home = {
      spec = "/home";
      verbosity = "warning";
      extraOptions = [ "--loadavg-target" "6.0" ];
      workDir = "persist/bees";
    };
  };

  programs.command-not-found.enable = false;

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.secureBoot = {
  #   enable = true;
  #   keyPath = "/nix/secure-boot/db.key";
  #   certPath = "/nix/secure-boot/db.crt";
  # };
  # boot.loader.systemd-boot.consoleMode = "0";
  # boot.loader.systemd-boot.editor = false;
  # boot.loader.systemd-boot.configurationLimit = 2;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/persist/secure-boot";
    settings = {
      console-mode = "0";
      editor = null;
    };
  };

  boot.initrd.systemd.enable = true;
  # boot.loader.grub = {
  #   enable = true;
  #   enableCryptodisk = true;
  #   efiSupport = true;
  #   copyKernels = false;
  #   useOSProber = true;
  #   device = "nodev";
  # };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModulePackages = [
    (pkgs.callPackage (import ../uwurandom.nix) {
      kernel = config.boot.kernelPackages.kernel;
    })
  ];
  boot.kernelModules = ["uwurandom"];
  # boot.kernelParams = [ "vfio-pci.ids=1002:73df,1002:ab28" ];
  # boot.initrd.kernelModules = [ "vfio-pci" ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "chell"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

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

  hardware.onlykey.enable = true;
  services.udev.packages = [pkgs.yubikey-personalization pkgs.openrgb];
  services.pcscd.enable = true;
  hardware.keyboard.zsa.enable = true;
  programs.adb.enable = true;
  services.udev.extraRules = ''
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0102", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0103", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0104", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0107", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0108", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1010", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1011", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1012", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1013", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1014", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1016", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1017", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1018", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1051", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1061", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{product}=="*CMSIS-DAP*", MODE="0666", GROUP="plugdev", TAG+="uaccess"

    ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2000", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27e2", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3006", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="057e", ATTRS{idProduct}=="201d", MODE="0666", GROUP="plugdev", TAG+="uaccess"
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # services.xserver.videoDrivers = ["amdgpu" "nvidia"];

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    "L+ ${channelPath} - - - - ${pkgs.path}"
  ];
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [pkgs.fcitx5-hangul];
    # uim.toolbar = "gtk-systray";
    # ibus.engines = with pkgs.ibus-engines; [ hangul ];
  };
  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.runUsingSystemd = true;

  # services.xserver.desktopManager.cinnamon.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.epson-201401w];

  # hardware.sane.enable = true;
  # hardware.sane.extraBackends = [ pkgs.utsushi ];
  # hardware.sane.netConf = "100.64.0.5";

  programs.noisetorch.enable = true;

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

  age.identityPaths = ["/persist/agenix-key"];

  age.secrets.password = {file = ../secrets/password.age;};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel" "adbusers" "docker" "dialout" "tss" "libvirtd"]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = config.age.secrets.password.path;
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 20;
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  programs.steam.enable = true;

  # this folder is where the files will be stored (don't put it in tmpfs)
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/waydroid"
      "/var/lib/tailscale"
      "/var/lib/flatpak"
      "/var/lib/libvirt"
    ];
    files = [];
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  virtualisation = {
    docker = {enable = true;};
    waydroid.enable = true;
    lxd.enable = true;
    libvirtd.enable = true;
  };

  programs.nix-ld.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xorg.libxcb
    # nordic
    catppuccin-cursors.macchiatoDark
    # ((pkgs.callPackage ../alvr.nix) { })
    ((pkgs.callPackage ../sddm-chili.nix) {})
    rocmPackages.clr
  ];

  programs.dconf.enable = true;

  services.xserver.displayManager.sddm.theme = "sddm-chili";
  services.xserver.displayManager.sddm.settings.Theme.CursorTheme = "Catppuccin-Macchiato-Dark-Cursors";

  # boot.plymouth = {
  #   enable = true;
  #   theme = "bgrt";
  # };

  # boot.loader.systemd-boot.extraEntries = {
  #   "arch.conf" = ''
  #     title Arch Netboot
  #     efi /ipxe-arch.16e24bec1a7c.efi
  #   '';
  # };

  security.pam.u2f.enable = true;
  security.pam.u2f.control = "required";

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
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.tailscale.enable = true;

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
  system.stateVersion = "22.05"; # Did you read the comment?
}
