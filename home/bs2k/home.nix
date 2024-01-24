{
  config,
  pkgs,
  pkgsUnstable,
  rust-overlay,
  nix-alien,
  comma,
  prismlauncher,
  agenix,
  packwiz,
  catppuccin-vsc,
  ...
}: let
  override-icon = pkg: oldPrefix: newPrefix:
    pkgs.runCommand "${pkg.name}-wrapped" {} ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/share
      mkdir $out/share
      ln -s ${pkg}/share/* $out/share
      rm $out/share/applications
      mkdir $out/share/applications
      cp ${pkg}/share/applications/* $out/share/applications
      sed -i 's/Icon=${oldPrefix}/Icon=${newPrefix}/g' $out/share/applications/*
    '';
  override-exec = pkg: oldPrefix: newPrefix:
    pkgs.runCommand "${pkg.name}-wrapped" {} ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/share
      mkdir $out/share
      ln -s ${pkg}/share/* $out/share
      rm $out/share/applications
      mkdir $out/share/applications
      cp ${pkg}/share/applications/* $out/share/applications
      sed -i 's/Exec=${oldPrefix}/Exec=${newPrefix}/g' $out/share/applications/*
    '';
  mkUpper = str:
    (pkgs.lib.toUpper (pkgs.lib.substring 0 1 str)) + (pkgs.lib.substring 1 (pkgs.lib.stringLength str) str);
  catppuccinDarkness =
    if config.catppuccin.flavour == "latte"
    then "light"
    else "dark";
in {
  catppuccin.flavour = "macchiato";
  catppuccin.accent = "teal";

  # programs.btop = {
  #   enable = true;
  #   catppuccin.enable = true;
  # };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    rust-overlay.overlays.default
    nix-alien.overlays.default
    agenix.overlays.default
    catppuccin-vsc.overlays.default
    (self: super: {
      monaspace = pkgs.callPackage (import ./monaspace/package.nix) {};

      # chessx = override-exec pkgsUnstable.chessx "" "QT_QPA_PLATFORM=xcb ";
      vesktop = super.vesktop.override {
        vencord = pkgs.callPackage (import ./owo-vencord/package.nix) {};
        # gcc13Stdenv = pkgsUnstable.gcc13Stdenv;
        # electron = self.electron_27;
      };

      # openai-whisper = pkgsUnstable.python310Packages.openai-whisper.override {
      #   torch = pkgsUnstable.python310Packages.torch-bin;
      # };
      discord-canary = super.discord-canary.override {nss = pkgs.nss_latest;};
      discord = super.discord.override {
        nss = pkgs.nss_latest;
        withOpenASAR = true;
      };

      cutter = super.cutter.overrideAttrs (old: rec {
        version = "2.3.0";
        src = self.fetchFromGitHub {
          owner = "rizinorg";
          repo = "cutter";
          rev = "v${version}";
          hash = "sha256-oQ3sLIGKMEw3k27aSFcrJqo0TgGkkBNdzl6GSoOIYak=";
          fetchSubmodules = true;
        };
      });

      aseprite-unfree = self.callPackage (import ./aseprite/default.nix) {};

      rizin = super.rizin.overrideAttrs (old: rec {
        version = "0.6.0";
        src = self.fetchurl {
          url = "https://github.com/rizinorg/rizin/releases/download/v${version}/rizin-src-v${version}.tar.xz";
          hash = "sha256-apJJBu/fVHrFBGJ2f1rdU5AkNuekhi0sDiTKkbd2FQg=";
        };
      });
      godot_4 = super.godot_4.overrideAttrs rec {
        version = "4.2.1-stable";
        commitHash = "b09f793f564a6c95dc76acc654b390e68441bd01";

        src = pkgs.fetchFromGitHub {
          owner = "godotengine";
          repo = "godot";
          rev = commitHash;
          hash = "sha256-Q6Og1H4H2ygOryMPyjm6kzUB6Su6T9mJIp0alNAxvjQ=";
        };

        preConfigure = ''
          mkdir -p .git
          echo ${commitHash} > .git/HEAD
        '';
      };

      libreoffice-qt = override-icon super.libreoffice-qt "" "libreoffice-";

      # prismlauncher-alt = prismlauncher.packages.x86_64-linux.prismlauncher-qt5;
      # override-icon prismlauncher.packages.x86_64-linux.prismlauncher-qt5
      # "org.prismlauncher.PrismLauncher" "minecraft";

      # nheko = override-icon super.nheko "nheko" "google-chat";

      # galaxy-buds-client =
      #   super.callPackage (import ./galaxy-buds-client.nix) {};

      optar = super.optar.overrideAttrs (old: {patches = [./optar.patch];});

      cutechess = with self;
        stdenv.mkDerivation rec {
          pname = "cutechess";
          version = "1.3.1";

          src = fetchFromGitHub {
            owner = "cutechess";
            repo = "cutechess";
            rev = "v${version}";
            hash = "sha256-P44Twbw2MGz+oTzPwMFCe73zPxAex6uYjSTtaUypfHw=";
          };

          buildInputs = [libsForQt5.qt5.qtbase];
          nativeBuildInputs = [cmake libsForQt5.qt5.wrapQtAppsHook];
        };

      stockfish = self.callPackage (import ./stockfish.nix) {};
    })
  ];

  # home.files = {
  #   catppuccin-kde = {
  #     source =
  #   };
  # };

  services.spotifyd = {
    enable = true;
    package = pkgs.spotifyd.override {
      withMpris = true;
      withKeyring = true;
    };
    settings = {
      global = {
        username = "31dohyohht5s5rb7xq4vfw6ihomq";
        use_keyring = true;
        use_mpris = true;
        bitrate = 320;
        volume_normalisation = true;
        device_name = "dæmon";
        device_type = "computer";
      };
    };
  };

  home.sessionVariables = {
    # GTK_THEME = config.gtk.theme.name;
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    NIXOS_OZONE_WL = "1";
    # CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "bs2k";
  home.homeDirectory = "/home/bs2k";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # services.flameshot.enable = true;

  home.packages = [
    pkgs.nerdfonts
    pkgs.nanum
    pkgs.noto-fonts
    pkgs.noto-fonts-extra
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    pkgs.noto-fonts-emoji
    pkgs.cm_unicode
    pkgs.lmmath

    pkgs.taplo

    pkgs.mosh

    pkgs.kate
    pkgs.git
    pkgs.onlykey-cli
    pkgs.yubikey-manager-qt
    pkgs.yubioath-flutter

    # pkgsUnstable.android-studio
    # pkgs.keepassxc
    # pkgs.yakuake
    # pkgs.polymc
    pkgs.thunderbird
    pkgs.ckan
    pkgs.libsForQt5.ark
    pkgs.kicad
    # pkgs.eagle
    # pkgs.gcc
    # pkgs.openocd
    pkgs.blender
    pkgs.godot_4
    # pkgs.godot-export-templates
    # pkgs.tiled
    pkgs.thefuck
    # pkgs.deploy-rs.deploy-rs
    pkgs.spotify-qt
    # pkgs.spotify-tui
    pkgs.rnix-lsp
    pkgs.fusee-launcher
    # pkgs.nur.repos.jakobrs.libtasMulti
    pkgs.love
    pkgs.easyeffects
    # pkgs.wireguard-tools
    # pkgsUnstable.wgcf
    # pkgs.sr
    pkgs.xclip
    pkgs.cloudflared
    pkgs.yarn
    pkgs.nodejs
    pkgs.inkscape
    # pkgsUnstable.nodePackages_latest.wrangler
    # pkgsUnstable.cargo
    # pkgsUnstable.rust-analyzer
    # pkgsUnstable.rustc
    # pkgsUnstable.cargo-edit
    # pkgsUnstable.cargo-audit
    # pkgsUnstable.clippy
    pkgs.unzip
    pkgs.gnupg
    pkgs.pinentry-qt
    pkgs.curl
    # pkgs.onlykey
    pkgs.nheko

    pkgs.libsForQt5.neochat

    pkgs.vlc
    pkgs.yt-dlp
    pkgs.ffmpeg
    pkgs.kolourpaint
    pkgs.lutris
    # (pkgsUnstable.lapce.overrideAttrs (old: rec {
    #   version = "v0.2.5";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "lapce";
    #     repo = "lapce";
    #     rev = "v0.2.5";
    #     sha256 = "sha256-WFFn1l7d70x5v6jo5m+Thq1WoZjY7f8Lvr3U473xx48=";
    #   };
    #   cargoDeps = old.cargoDeps.overrideAttrs (_: {
    #     inherit src;
    #     outputHash = "sha256-iRo+56y3q/+WRVRFYjWIOMckZi64PJABuKAofErRXwA=";
    #   });
    # }))
    # pkgs.element-desktop
    pkgs.inter
    # pkgs.davinci-resolve
    pkgs.libsForQt5.kdenlive
    pkgs.wget
    pkgs.arduino

    (pkgsUnstable.catppuccin-kde.override {
      flavour = [config.catppuccin.flavour];
      accents = [config.catppuccin.accent];
      winDecStyles = ["classic"];
    })

    (pkgs.catppuccin-kvantum.override {
      variant = mkUpper config.catppuccin.flavour;
      accent = mkUpper config.catppuccin.accent;
    })

    # pkgs.qtstyleplugin-kvantum-qt4
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.qt6Packages.qtstyleplugin-kvantum

    pkgs.nix-alien
    pkgs.nix-index-update
    pkgs.nix-index
    comma.packages.x86_64-linux.comma
    # pkgs.openai-whisper
    (pkgs.python310.withPackages (pythonPackages:
      with pythonPackages; [
        # (openai-whisper.override {
        #   torch = torch-bin.overrideAttrs (old: {
        #     src = pkgs.fetchurl {
        #       name = "torch-1.13.1-cp310-cp310-linux_x86_64.whl";
        #       url = "https://download.pytorch.org/whl/rocm5.2/torch-1.13.1%2Brocm5.2-cp310-cp310-linux_x86_64.whl";
        #       hash = "sha256-82hdCKwNjJUcw2f5vUsskkxdRRdmnEdoB3SKvNlmE28=";
        #     };
        #     patches = [];
        #     # buildInputs = with pkgs; old.buildInputs ++ [
        #     #   rocm-runtime
        #     #   rocm-device-libs
        #     # ];
        #     patchPhase = "";
        #     postFixup = let
        #       rpath = lib.makeLibraryPath [
        #         stdenv.cc.cc.lib
        #         pkgs.rocmPackages.rocm-runtime
        #         pkgs.rocmPackages.rocm-device-libs
        #         pkgs.rocmPackages.clr
        #         # pkgs.rocfft
        #         pkgs.rocmPackages.rccl
        #         # pkgs.rocsparse
        #         # pkgs.rocprim
        #         # pkgs.rocthrust
        #         pkgs.rocmPackages.rocblas
        #         # pkgs.hipsparse
        #       ];
        #     in ''
        #       find $out/${python.sitePackages}/torch/lib -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
        #         echo "setting rpath for $lib..."
        #         patchelf --set-rpath "${rpath}:$out/${python.sitePackages}/torch/lib" "$lib"
        #         addOpenGLRunpath "$lib"
        #       done
        #     '';
        #   });
        # })
        sounddevice
        numpy
        scipy
        pyaudio
        pkgs.yubikey-manager
        yubico-client
        pyscard
        # (torchvision-bin.override { torch = torch-bin.overrideAttrs(old: {
        #   src = pkgs.fetchurl {
        #     name = "torch-1.13.1-cp310-cp310-linux_x86_64.whl";
        #     url = "https://download.pytorch.org/whl/rocm5.2/torch-1.13.1%2Brocm5.2-cp310-cp310-linux_x86_64.whl";
        #     hash = "sha256-82hdCKwNjJUcw2f5vUsskkxdRRdmnEdoB3SKvNlmE28=";
        #   };
        #   patches = [];
        #   # buildInputs = with pkgs; old.buildInputs ++ [
        #   #   rocm-runtime
        #   #   rocm-device-libs
        #   # ];
        #   patchPhase = "";
        #   postFixup = let
        #     rpath = lib.makeLibraryPath [
        #       stdenv.cc.cc.lib
        #       pkgs.rocm-runtime
        #       pkgs.rocm-device-libs
        #       pkgs.hip
        #       # pkgs.rocfft
        #       pkgs.rccl
        #       # pkgs.rocsparse
        #       # pkgs.rocprim
        #       # pkgs.rocthrust
        #       pkgs.rocblas
        #       # pkgs.hipsparse
        #     ];
        #   in ''
        #     find $out/${python.sitePackages}/torch/lib -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
        #       echo "setting rpath for $lib..."
        #       patchelf --set-rpath "${rpath}:$out/${python.sitePackages}/torch/lib" "$lib"
        #       addOpenGLRunpath "$lib"
        #     done
        #   '';
        # }); })

        python-lsp-server
        openai
        requests
        python-socketio
        grequests
        tiktoken

        onnxruntime
        pillow
        (opencv4.override {enableGtk3 = true;})
      ]))

    (pkgs.rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
      targets = [
        "wasm32-unknown-unknown"
        "wasm32-wasi"
        # "wasm32-unknown-emscripten"
        # "x86_64-unknown-linux-musl"
      ];
    })

    pkgs.fastly

    pkgs.emscripten

    pkgs.llvmPackages_latest.llvm
    pkgs.llvmPackages_latest.lld
    pkgs.llvmPackages_latest.clang
    pkgs.bintools
    pkgs.clang-tools

    pkgs.any-nix-shell
    # pkgs.prismlauncher-alt
    (prismlauncher.packages.${pkgs.system}.prismlauncher-qt5.override {
      gamemodeSupport = true;

      glfw = pkgs.callPackage (import ./glfw/package.nix) {};

      additionalLibs = [pkgs.libva];
    })

    pkgs.openrgb

    # pkgs.cider
    # pkgs.nordic
    # pkgs.nordzy-icon-theme
    # pkgs.nordzy-cursor-theme

    pkgs.galaxy-buds-client
    pkgs.libreoffice-qt
    pkgs.optar

    # pkgs.latte-dock

    pkgs.transmission-qt
    pkgs.libsForQt5.ktorrent
    pkgs.jetbrains.idea-ultimate
    # pkgs.jetbrains.clion
    pkgs.gnumake

    pkgs.papirus-icon-theme

    # pkgs.fractal-next

    # (override-exec (pkgs.callPackage ./godot.nix { }) "" "steam-run ")

    # pkgs.libsForQt5.kmail
    # pkgs.libsForQt5.kmailtransport
    # pkgs.libsForQt5.kmail-account-wizard

    # (powercord-overlay.lib.makeDiscordPlugged {
    #   inherit pkgs;
    #   withOpenAsar = true;
    #   plugins = {
    #     power-bottom = pkgs.fetchFromGitHub {
    #       owner = "bottom-software-foundation";
    #       repo = "power-bottom";
    #       rev = "need_top";
    #       sha256 = "sha256-42+bcIr5rMjMVqSsOc5hlm2SOUdYGrNybBLypFes6qs=";
    #     };
    #     emoji-utility = pkgs.fetchFromGitHub {
    #       owner = "replugged-org";
    #       repo = "emoji-utility";
    #       rev = "master";
    #       sha256 = "sha256-16V5Do7TehWR/rYmUuGzEk4EisYYBWSHI/u5iPsuqR0=";
    #     };
    #     better-codeblocks = pkgs.fetchFromGitHub {
    #       owner = "replugged-org";
    #       repo = "better-codeblocks";
    #       rev = "master";
    #       sha256 = "sha256-8coW01cbjL/RArw9fTO4Z+2Hf+sT48m8wCXUCqMj9LQ=";
    #     };
    #   };
    # })
    # (pkgs.discord.override {
    #   withVencord = true;
    #   withOpenASAR = true;
    #   vencord = pkgs.callPackage  (import ./owo-vencord/default.nix) { };
    # })
    # pkgsUnstable.armcord
    # powercord-overlay.packages.x86_64-linux.discord-plugged
    pkgs.obs-studio
    pkgs.appimage-run
    pkgs.virt-manager
    # pkgs.flutter
    pkgs.jdk

    # pkgs.cutechess
    pkgs.stockfish
    pkgs.chessx
    # pkgs.xboard

    pkgs.vesktop

    pkgs.mold
    # pkgs.cutter
    # pkgs.rizin

    pkgs.just

    pkgs.aseprite-unfree

    pkgs.craftos-pc
    (packwiz.packages.${pkgs.system}.default.override {
      buildGoModule = args:
        pkgs.buildGoModule (args
          // rec {
            vendorSha256 = "sha256-yL5pWbVqf6mEpgYsItLnv8nwSmoMP+SE0rX/s7u2vCg=";
            patches = [
              (pkgs.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/packwiz/packwiz/pull/258.diff";
                hash = "sha256-EzKymkZWihxbzZ9XiFQq6Aa0k2AKX7gh9YTIOmOUJ1o=";
              })
            ];
          });
    })

    pkgs.ragenix

    pkgs.monaspace
    pkgs.twitter-color-emoji

    pkgs.freecad

    pkgs.minisign
    pkgs.rage
  ];

  fonts.fontconfig.enable = true;
  xdg.configFile."fontconfig/conf.d/10-nerd-font-symbols.conf" = let
    genOverlay = font: ''
      <alias>
        <family>Monaspace ${font}</family>
        <prefer>
          <family>Monaspace ${font}</family>
          <family>Symbols Nerd Font</family>
        </prefer>
      </alias>
    '';
    genOverlaysForFlavor = variant:
      builtins.concatStringsSep "\n" (map (wideness: genOverlay "${variant}${wideness}") [
        ""
        " SemiWide"
        " Wide"
        " Var"
      ]);
    overlays = builtins.concatStringsSep "\n" (map (variant: genOverlaysForFlavor variant) [
      "Argon"
      "Krypton"
      "Neon"
      "Radon"
      "Xenon"
    ]);
  in {
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <!--${overlays}-->
      </fontconfig>
    '';
    onChange = "${pkgs.fontconfig}/bin/fc-cache -f";
  };
  xdg.configFile."fontconfig/conf.d/10-noto-color-emoji.conf" = let
    genOverlay = font: ''
      <alias>
        <family>${font}</family>
        <prefer>
          <family>${font}</family>
          <family>Twitter Color Emoji</family>
        </prefer>
      </alias>
    '';
    overlays = builtins.concatStringsSep "\n" (map genOverlay [
      "Inter"
    ]);
  in {
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        ${overlays}
      </fontconfig>
    '';
    onChange = "${pkgs.fontconfig}/bin/fc-cache -f";
  };

  gtk = {
    enable = true;
    catppuccin.enable = true;
    font.name = "Inter";
  };

  programs.mangohud.enable = true;

  qt = {
    enable = true;
    platformTheme = "kde";
    style.name = "kvantum";
  };

  home.pointerCursor = {
    package = pkgs.catppuccin-cursors."${config.catppuccin.flavour}${mkUpper catppuccinDarkness}";
    name = "Catppuccin-${mkUpper config.catppuccin.flavour}-${mkUpper catppuccinDarkness}-Cursors";
    gtk.enable = true;
  };

  services.syncthing = {enable = true;};

  # programs.zsh = {
  #   enable = true;
  #   autocd = true;
  #   zplug = {
  #     enable = true;
  #     plugins = [
  #       {name = "zsh-users/zsh-autosuggestions";}
  #       {name = "zsh-users/zsh-completions";}
  #       {name = "chisui/zsh-nix-shell";}
  #       {
  #         name = "zsh-users/zsh-syntax-highlighting";
  #         tags = ["defer:2"];
  #       }
  #     ];
  #   };
  # };

  programs.fish = {
    enable = true;
    interactiveShellInit =
      ''
        any-nix-shell fish | source
        thefuck --alias | source
        sqlx completions fish | source
        # export LG_WEBOS_TV_SDK_HOME=/home/bs2k/webOS_TV_SDK/
        # export WEBOS_CLI_TV="$LG_WEBOS_TV_SDK_HOME/CLI/bin"
        fish_add_path ~/.yarn/bin ~/.cargo/bin ~/.fly/bin/ # $WEBOS_CLI_TV
      ''
      + builtins.readFile ./theme.fish;
    functions = {
      fish_greeting = ''
        echo Hello, World!
      '';
    };
    plugins = [
      {
        name = "bang-bang";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-bang-bang";
          rev = "816c66df34e1cb94a476fa6418d46206ef84e8d3";
          sha256 = "sha256-35xXBWCciXl4jJrFUUN5NhnHdzk6+gAxetPxXCv4pDc=";
        };
      }
    ];
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # programs.kitty = {
  #   enable = true;
  #   font.name = "FiraCode NF";
  #   theme = "Nord";
  # };

  # programs.alacritty = {
  #   enable = true;
  #   settings = {
  #     window.dimensions = {
  #       columns = 80;
  #       lines = 24;
  #     };
  #     font.normal.family = "FiraCode NF";
  #     colors = {
  #       primary = {
  #         background = "#2e3440";
  #         foreground = "#d8dee9";
  #         dim_foreground = "#a5abb6";
  #       };
  #       cursor = {
  #         text = "#2e3440";
  #         cursor = "#d8dee9";
  #       };
  #       vi_mode_cursor = {
  #         text = "#2e3440";
  #         cursor = "#d8dee9";
  #       };
  #       selection = {
  #         text = "CellForeground";
  #         background = "#4c566a";
  #       };
  #       search = {
  #         matches = {
  #           foreground = "CellBackground";
  #           background = "#88c0d0";
  #         };
  #         footer_bar = {
  #           background = "#434c5e";
  #           foreground = "#d8dee9";
  #         };
  #       };
  #       normal = {
  #         black = "#3b4252";
  #         red = "#bf616a";
  #         green = "#a3be8c";
  #         yellow = "#ebcb8b";
  #         blue = "#81a1c1";
  #         magenta = "#b48ead";
  #         cyan = "#88c0d0";
  #         white = "#e5e9f0";
  #       };
  #       bright = {
  #         black = "#4c566a";
  #         red = "#bf616a";
  #         green = "#a3be8c";
  #         yellow = "#ebcb8b";
  #         blue = "#81a1c1";
  #         magenta = "#b48ead";
  #         cyan = "#8fbcbb";
  #         white = "#eceff4";
  #       };
  #       dim = {
  #         black = "#373e4d";
  #         red = "#94545d";
  #         green = "#809575";
  #         yellow = "#b29e75";
  #         blue = "#68809a";
  #         magenta = "#8c738c";
  #         cyan = "#6d96a5";
  #         white = "#aeb3bb";
  #       };
  #     };
  #   };
  # };

  # programs.helix = {
  #   enable = true;
  #   package = helix.packages.x86_64-linux.default;
  #   settings = {
  #     theme = "catppuccin_${config.catppuccin.flavour}";
  #   };
  # };

  programs.starship = let
    fromPath = path:
      fromTOML (builtins.readFile path);
    get-preset = preset:
      fromPath "${config.programs.starship.package}/share/starship/presets/${preset}.toml";
    concatAttrs = attrs:
      builtins.foldl' pkgs.lib.attrsets.recursiveUpdate {} attrs;
    composed = conf:
      concatAttrs (
        (map get-preset conf.presets)
        ++ (map fromPath conf.files)
      );
  in {
    enable = true;
    enableFishIntegration = true;
    settings = composed {
      files = [./starship.toml];
      presets = [
        "no-runtime-versions"
        "nerd-font-symbols"
      ];
    };
    catppuccin.enable = true;
  };

  programs.vscode = {
    enable = true;
    # package = pkgs.vscodium;
    mutableExtensionsDir = false;
    userSettings = {
      "update.mode" = "none";
      "rust-analyzer.check.command" = "clippy";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "editor.fontFamily" = "\"Monaspace Neon\", \"Symbols Nerd Font\", \"Twitter Color Emoji\"";
      "editor.fontLigatures" = "'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss08'";
      "yaml.schemaStore.enable" = true;
      "redhat.telemetry.enabled" = false;
      "svelte.enable-ts-plugin" = true;
      "workbench.colorTheme" = "Catppuccin ${mkUpper config.catppuccin.flavour}";
      "catppuccin.accentColor" = config.catppuccin.accent;
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.minimumContrastRatio" = 1;
      "editor.semanticHighlighting.enabled" = true;
      "godot_tools.editor_path" = "${pkgs.godot_4}/bin/godot4";
    };
    extensions = with pkgs.vscode-extensions;
      [
        astro-build.astro-vscode
        svelte.svelte-vscode
        bradlc.vscode-tailwindcss
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint

        eamodio.gitlens
        (pkgs.catppuccin-vsc.override {
          accent = config.catppuccin.accent;
        })

        mkhl.direnv
        jnoortheen.nix-ide
        skellock.just

        matklad.rust-analyzer
        tamasfe.even-better-toml

        ms-python.python
        ms-python.vscode-pylance

        sumneko.lua

        redhat.vscode-yaml
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "hex-casting";
          publisher = "object-Object";
          version = "0.1.27";
          sha256 = "sha256-CV2OloqE1P6/tVkIA7Ptb11alSSAK/5FyErQ5R5MhrI=";
        }
        {
          name = "pico-w-go";
          publisher = "paulober";
          version = "3.5.0";
          arch = "linux-x64";
          sha256 = "sha256-6cGcJaYTFWvmR1PKBymoHC8GnQ0AGOSsdoYKlbNE1U0=";
        }
        {
          name = "godot-tools";
          publisher = "geequlim";
          version = "1.3.1";
          sha256 = "sha256-wJICDW8bEBjilhjhoaSddN63vVn6l6aepPtx8VKTdZA=";
        }
      ];
  };

  # programs.go.enable = true;
  # programs.go.package = pkgsUnstable.go;
  programs.firefox.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
