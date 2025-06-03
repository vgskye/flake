{
  config,
  pkgs,
  pkgsUnstable,
  pkgsAmd64,
  rust-overlay,
  nix-alien,
  comma,
  prismlauncher,
  agenix,
  packwiz,
  catppuccin-vsc,
  fenix,
  firefox,
  ...
}: {
  services.mako = {
    enable = true;
    catppuccin.enable = true;
  };
  programs.waybar = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      mainBar = {
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        layer = "top";
        position = "top";
        spacing = 12;
        height = 36;
        output = [
          "DSI-1"
        ];
        modules-left = [
          "clock"
          "custom/osk"
          "custom/drun"
        ];
        modules-center = [
          "wlr/taskbar"
        ];
        modules-right = [
          "tray"
          "wireplumber"
          "bluetooth"
          "network"
          "battery"
        ];
        "wlr/taskbar" = {
          icon-size = 24;
          on-click = "activate";
        };
        "custom/osk" = {
          format = "󰌌";
          on-click = "busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b true";
          on-click-right = "busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b false";
        };
        "custom/drun" = {
          format = "󰌧";
          on-click = "nwg-drawer -ovl";
        };
        tray = {
          icon-size = 16;
          spacing = 8;
        };
        bluetooth = {
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };

        wireplumber = {
            format = "{icon} {volume}%";
            format-muted = "";
            format-icons = ["" "" ""];
        };

        clock = {
          format = "{:%Y-%m-%d %I:%M %p}";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-icons = ["" "" "" "" ""];
        };

        network = {
           format-wifi = " {essid}";
           tooltip-format-wifi = "{ipaddr}/{cidr} via {gwaddr}";
        };
      };
    };
    style = builtins.readFile ./waybar.css;
    systemd.enable = true;
  };

  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
    package = pkgs.rofi-wayland.override {
      plugins = [
        (pkgs.rofi-calc.override {
          rofi-unwrapped = pkgs.rofi-wayland-unwrapped;
        })
      ];
    };
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = "kvantum-dark";
  };

  # systemd.user.services.mako = {
  #   Unit = {
  #     After = "graphical-session-pre.target";
  #     Description = "Mako, lightweight notification daemon for Wayland";
  #     PartOf = "graphical-session.target";
  #   };

  #   Install = {
  #     WantedBy = 
  #     ["graphical-session.target"];
  #   };

  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${config.services.mako.package}/bin/mako";
  #     Restart = "on-failure";
  #   };
  # };

  # systemd.user.services.swayidle.Unit.After = "niri.service";

  systemd.user.services.squeekboard = {
    Unit = {
      After = "niri.service";
      Description = "Squeekboard";
      PartOf = "graphical-session.target";
    };

    Install = {
      WantedBy = 
      ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.squeekboard}/bin/squeekboard";
      Restart = "on-failure";
    };
  };

  systemd.user.services.xwayland-satellite = {
    Unit = {
      After = "niri.service";
      Description = "Xwayland outside your Wayland";
      PartOf = "graphical-session.target";
    };

    Install = {
      WantedBy = 
      ["graphical-session.target"];
    };

    Service =
    let
      xwayland-satellite = pkgs.xwayland-satellite;
    in
    {
      Type = "simple";
      ExecStart = "${xwayland-satellite}/bin/xwayland-satellite :1";
      Restart = "on-failure";
      Environment="PATH=${pkgs.xwayland}/bin/";
    };
  };

  # systemd.user.services.switchblade.Service.environment = "XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}";

  systemd.user.sessionVariables  = {
    DISPLAY = ":1";
  };

  home.packages = [
    pkgs.brightnessctl
    pkgs.nautilus
    pkgs.loupe
    pkgs.evince
    pkgs.iwgtk
    pkgs.glib
    pkgs.nwg-drawer
    pkgs.blueberry
    # (pkgs.freecad.overrideAttrs (old: {
    #   version = "0.22.0-3b304e5";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "FreeCAD";
    #     repo = "FreeCAD";
    #     rev = "3b304e5b1a62f3119d7311aeb736dcb53cb4faad";
    #     hash = "sha256-lLnwCi77ToPmiRnZ70VJ4MGTLaM7DNwIbGC5UkixO5c=";
    #     fetchSubmodules = true;
    #   };
    # }))
    pkgs.gnome-text-editor
  ];

  programs.swaylock = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      indicator-idle-visible = true;
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "unlock"; command = "${pkgs.procps}/bin/pkill -USR1 swaylock"; }
    ];
  };

  services.switchblade = {
    enable = true;
    config = {
      lid = {
        # on = "systemctl suspend";
      };
      tablet_mode = {
        on = "XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version} gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true";
        off = "XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version} gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false";
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      colors = {
        background = "24273add";
        text = "cad3f5ff";
        match = "ed8796ff";
        selection = "5b6078ff";
        selection-match = "ed8796ff";
        selection-text = "cad3f5ff";
        border = "b7bdf8ff";
      };
    };
  };

  services.swayosd.enable = true;

  programs.firefox.package = 
    let
      wrapFirefox = pkgs.wrapFirefox.override {
        ffmpeg = pkgs.ffmpeg.overrideAttrs (oldAttrs: {
          patches = oldAttrs.patches ++ [
            (pkgs.fetchpatch {
              url = "https://raw.githubusercontent.com/LibreELEC/LibreELEC.tv/9c99ad0f0bdad077176be4250e64e9deda70c062/packages/multimedia/ffmpeg/patches/rpi/ffmpeg-001-rpi.patch";
              hash = "sha256-IZsRZ25UUTvuSeXGGNJ8TODU51EO8rmAfjdsRPA9O5M=";
            })
          ];
          doCheck = false;
        });
      };
    in
    wrapFirefox (firefox.overlays.default pkgs pkgs).firefox-nightly-bin.unwrapped
      { pname = "firefox-nightly-bin"; };
}
