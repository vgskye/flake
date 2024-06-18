# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  lib,
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
    substituters = ["https://vgskye.cachix.org"];
    trusted-public-keys = ["vgskye.cachix.org-1:DjgwQYRfjI1/w7exE54FCtfe4ZKCYEhWgJXmcHoo944="];
  };

  systemd.tmpfiles.rules = [
    "L+ ${channelPath} - - - - ${pkgs.path}"
  ];

  programs.command-not-found.enable = false;

  programs.dconf.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr --output DSI-1 --rotate left";
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.enable = false;
  networking.wireless.userControlled.enable = false;

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

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [pkgs.fcitx5-hangul];
    # uim.toolbar = "gtk-systray";
    # ibus.engines = with pkgs.ibus-engines; [ hangul ];
  };

  boot.binfmt.registrations.x86_64-linux = {
    interpreter = "${pkgs.box64}/bin/box64";
    recognitionType = "magic";
    wrapInterpreterInShell = false;
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  };

  nix.settings = {
    extra-platforms = "armv7l-linux";
    extra-sandbox-paths = [ "/run/binfmt" "${pkgs.box64}" ];
  };

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
    extraGroups = ["wheel" "networkmanager" "tss"];
    password = "hunter2"; # CHANGEME
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  environment.systemPackages = with pkgs; [
    git
  ];

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  system.stateVersion = "23.05";
}
