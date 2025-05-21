# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  niri,
  ...
}: let
  channelPath = "/etc/nix/channels/nixpkgs";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  nix.nixPath = [
    "nixpkgs=${channelPath}"
  ];

  powerManagement.cpuFreqGovernor = "schedutil";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = lib.mkBefore ["https://niko.cat-snares.ts.net:9443/skye"];
  };

  systemd.tmpfiles.rules = [
    "L+ ${channelPath} - - - - ${pkgs.path}"
  ];

  programs.command-not-found.enable = false;

  programs.dconf.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output DSI-1 --rotate left
    ${pkgs.xorg.xinput}/bin/xinput set-prop "hid-over-i2c 0603:604A" --type=float "Coordinate Transformation Matrix"  0 -1 1 1 0 0 0 0 1
  '';
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.enable = true;

  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "chili";
    settings.Theme.CursorTheme = "Catppuccin-Macchiato-Dark-Cursors";
    # wayland.enable = true;
  };

  # networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.enable = false;
  # networking.wireless.userControlled.enable = false;
  networking.wireless.iwd.enable = true;

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

  virtualisation.waydroid.enable = true;

  services.flatpak.enable = true;
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  # nixpkgs.overlays = [
  #   niri.overlays.niri
  # ];

  programs.niri = {
    enable = true;
    package = pkgs.callPackage ./niri/package.nix {};
  };

  services.xserver.desktopManager.phosh.enable = false;
  services.xserver.desktopManager.phosh.user = "bs2k";
  services.xserver.desktopManager.phosh.group = "users";

  services.gvfs.enable = true;

  programs.kdeconnect.enable = true;

  services.blueman.enable = true;

  niri-flake.cache.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [pkgs.fcitx5-hangul];
    };

    # uim.toolbar = "gtk-systray";
    # ibus.engines = with pkgs.ibus-engines; [ hangul ];
  };

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];

  zramSwap.enable = true;

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        desiredgov = "performance";
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  boot.binfmt.registrations.x86_64-linux = {
    interpreter = "${pkgs.box64}/bin/box64";
    recognitionType = "magic";
    wrapInterpreterInShell = false;
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  };

  boot.binfmt.registrations.i686-linux = {
    interpreter = "${pkgsUnstable.box86}/bin/box86";
    recognitionType = "magic";
    wrapInterpreterInShell = false;
    magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  };

  nix.settings = {
    extra-platforms = [ "armv7l-linux" "i686-linux" "x86_64-linux" ];
    extra-sandbox-paths = [ "/run/binfmt" "${pkgs.box64}" "${pkgsUnstable.box86}" ];
  };

  boot.extraModulePackages = [
    (pkgs.callPackage (import ../uwurandom.nix) {
      kernel = config.boot.kernelPackages.kernel;
    })
  ];
  boot.kernelModules = ["uwurandom"];

  services.keyd = {
    enable = true;
    keyboards = {
      hammer = {
        ids = [ "k:18d1:5057" ];
        settings = {
          main = {
            leftshift = "overload(shift, S-9)";
            rightshift = "overload(shift, S-0)";
          };
          meta = {
            back = "f1";
            refresh = "f2";
            zoom = "f3";
            scale = "f4";
            brightnessdown = "f5";
            brightnessup = "f6";
            micmute = "f7";
            mute = "f8";
            volumedown = "f9";
            volumeup = "f10";
            sleep = "f11";
            backspace = "f12";
          };
          global = {
            overload_tap_timeout = 200;
          };
        };
      };
    };
  };

  virtualisation.docker.enable = true;

  networking.hostName = "thorley";

  time.timeZone = "Asia/Seoul";

  users.users.bs2k = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "tss" "input"];
    # password = "hunter2"; # CHANGEME
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  environment.systemPackages = with pkgs; [
    git
    sddm-chili-theme
  ];

  services.udev.extraHwdb = ''
    evdev:name:hid-over-i2c 0603:604A Stylus:
      LIBINPUT_CALIBRATION_MATRIX=0 -1 1 1 0 0
  '';

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # services.acpid = {
  #   enable = true;
  #   logEvents = true;
  #   lidEventCommands = ''
  #   	if echo "$3" | grep -iq "close"; then
  #       systemctl suspend
  #     fi
  #   '';
  # };

  security.pam.services.swaylock = {};

  system.stateVersion = "23.05";
}
