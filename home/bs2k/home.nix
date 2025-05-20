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
    if config.catppuccin.flavor == "latte"
    then "light"
    else "dark";
in {
  catppuccin.flavor = "macchiato";
  catppuccin.accent = "teal";

  # programs.btop = {
  #   enable = true;
  #   catppuccin.enable = true;
  # };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.overlays = [
    fenix.overlays.default
    rust-overlay.overlays.default
    nix-alien.overlays.default
    agenix.overlays.default
    (self: super: {
      # monaspace = pkgs.callPackage (import ./monaspace/package.nix) {};

      kicad = override-exec super.kicad "" "GTK_THEME=Breeze ";

      # chessx = override-exec pkgsUnstable.chessx "" "QT_QPA_PLATFORM=xcb ";
      vesktop = super.vesktop.override {
        withSystemVencord = false;
        # vencord = pkgs.callPackage (import ./owo-vencord/package.nix) {};
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

      # catppuccin-gtk = super.catppuccin-gtk.overrideAttrs (old: {
      #   patches = [
      #     (self.fetchpatch {
      #       url = "https://github.com/catppuccin/gtk/commit/c577226e9c2df2aadb4aadf7d59bda2f194c0181.patch";
      #       hash = "sha256-Mz5VAFEUB0qe1BOpxqXaEmJ3WDVEV9RqlixQbZChcuA=";
      #     })
      #     (self.fetchpatch {
      #       url = "https://patch-diff.githubusercontent.com/raw/catppuccin/gtk/pull/159.patch";
      #       hash = "sha256-4vgZbNeGMtsQEitIWDCVb5o4fAjhVu3iIUttUYqtHPc=";
      #     })
      #   ];
      # });

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

      # freecad = super.freecad.overrideAttrs (old: rec {
      #   version = "3b4598c";
      #   src = self.fetchFromGitHub {
      #     owner = "FreeCAD";
      #     repo = "FreeCAD";
      #     rev = version;
      #     hash = "sha256-16kLW5Cx2TtvmioXUjVxf4vv/pR48GAvnor82eT9sRI=";
      #   };
      #   patches = [./freecad.patch];
      #   buildInputs = old.buildInputs ++ [self.yaml-cpp];
      # });

      aseprite-unfree = self.callPackage (import ./aseprite/default.nix) {};

      rizin = super.rizin.overrideAttrs (old: rec {
        version = "0.6.0";
        src = self.fetchurl {
          url = "https://github.com/rizinorg/rizin/releases/download/v${version}/rizin-src-v${version}.tar.xz";
          hash = "sha256-apJJBu/fVHrFBGJ2f1rdU5AkNuekhi0sDiTKkbd2FQg=";
        };
      });
      godot_4 = pkgsUnstable.godot_4;

      libreoffice-qt = override-icon super.libreoffice-qt "" "libreoffice-";

      # prismlauncher-alt = prismlauncher.packages.x86_64-linux.prismlauncher-qt5;
      # override-icon prismlauncher.packages.x86_64-linux.prismlauncher-qt5
      # "org.prismlauncher.PrismLauncher" "minecraft";

      # nheko = override-icon super.nheko "nheko" "google-chat";

      # galaxy-buds-client =
      #   super.callPackage (import ./galaxy-buds-client.nix) {};

      optar = super.optar.overrideAttrs (old: {patches = [./optar.patch];});

      # cutechess = with self;
      #   stdenv.mkDerivation rec {
      #     pname = "cutechess";
      #     version = "1.3.1";

      #     src = fetchFromGitHub {
      #       owner = "cutechess";
      #       repo = "cutechess";
      #       rev = "v${version}";
      #       hash = "sha256-P44Twbw2MGz+oTzPwMFCe73zPxAex6uYjSTtaUypfHw=";
      #     };

      #     buildInputs = [libsForQt5.qt5.qtbase];
      #     nativeBuildInputs = [cmake libsForQt5.qt5.wrapQtAppsHook];
      #   };

      # stockfish =
      #   if self.system == "x86_64-linux"
      #   then self.callPackage (import ./stockfish.nix) {}
      #   else super.stockfish;
      

      # prusa-slicer = super.prusa-slicer.overrideAttrs (old: rec {
      #   version = "2.8.0";
      #   src = old.src.override {
      #     hash = "sha256-A/uxNIEXCchLw3t5erWdhqFAeh6nudcMfASi+RoJkFg=";
      #   };
      #   patches = [
      #     (self.fetchpatch {
      #       url = "https://github.com/gentoo/gentoo/raw/master/media-gfx/prusaslicer/files/prusaslicer-2.8.0-fixed-linking.patch";
      #       hash = "sha256-G1JNdVH+goBelag9aX0NctHFVqtoYFnqjwK/43FVgvM=";
      #     })
      #     (self.fetchpatch {
      #       url = "https://github.com/gentoo/gentoo/raw/master/media-gfx/prusaslicer/files/prusaslicer-2.8.0-missing-includes.patch";
      #       hash = "sha256-/R9jv9zSP1lDW6IltZ8V06xyLdxfaYrk3zD6JRFUxHg=";
      #     })
      #   ];

      #   cmakeFlags = old.cmakeFlags ++ [
      #     "-DSLIC3R_BUILD_TESTS=OFF"
      #   ];

      #   doCheck = false;
      # });
      # prusa-slicer = pkgsUnstable.prusa-slicer;

      # ghostty = pkgs.callPackage ./ghostty/package.nix {};
      slimevr-server = pkgsUnstable.slimevr-server; # pkgs.callPackage ./slimevr-server/package.nix {};
      slimevr = pkgsUnstable.slimevr; # pkgs.callPackage ./slimevr/package.nix {};
    })
    (self: super: let
      scale-electron = pkg: bin:
        if self.system == "aarch64-linux"
        then
          pkg //
          self.symlinkJoin {
            name = pkg.name;
            paths = [pkg];
            buildInputs = [self.makeWrapper];
            postBuild = ''
              wrapProgram $out/bin/${bin} \
                --add-flags "--force-device-scale-factor=1.5"
            '';
          }
        else pkg;
    in {
      vesktop = scale-electron super.vesktop "vesktop";
      vscode = scale-electron super.vscode "code";
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
      # withKeyring = true;
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
        cache_path = "/home/bs2k/.cache/spotifyd";
      };
    };
  };

  home.sessionVariables = {
    # GTK_THEME = config.gtk.theme.name;
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    NIXOS_OZONE_WL = "1";
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
    __RA_LSP_SERVER_DEBUG = "/home/bs2k/.nix-profile/bin/rust-analyzer";
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

  home.packages =
  let
    fenixStructured = structured: pkgs.fenix.combine (
      [
        pkgs.fenix.stable.defaultToolchain
      ] ++ (map (x: pkgs.fenix.stable.${x}) structured.extensions)
        ++ (map (x: pkgs.fenix.targets.${x}.stable.rust-std) structured.targets)
    );
  in
    [
      # pkgs.nerdfonts
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
      pkgs.kdePackages.ark
      # pkgs.eagle
      # pkgs.gcc
      # pkgs.openocd
      pkgs.godot_4
      # pkgs.godot-export-templates
      # pkgs.tiled
      # pkgs.thefuck
      # pkgs.deploy-rs.deploy-rs
      pkgs.spotify-qt
      # pkgs.spotify-tui
      # pkgs.rnix-lsp
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
      # pkgs.nheko

      # pkgs.kdePackages.neochat

      pkgs.vlc
      pkgs.ffmpeg
      pkgs.kolourpaint
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
      pkgs.kdePackages.kdenlive
      pkgs.wget

      (pkgsUnstable.catppuccin-kde.override {
        flavour = [config.catppuccin.flavor];
        accents = [config.catppuccin.accent];
        winDecStyles = ["classic"];
      })

      (pkgs.catppuccin-kvantum.override {
        variant = config.catppuccin.flavor;
        accent = config.catppuccin.accent;
      })

      # pkgs.qtstyleplugin-kvantum-qt4
      pkgs.libsForQt5.qtstyleplugin-kvantum
      pkgs.qt6Packages.qtstyleplugin-kvantum

      # pkgs.nix-alien
      pkgs.nix-index-update
      pkgs.nix-index
      comma.packages.${pkgs.system}.comma
      # pkgs.openai-whisper
      (pkgs.python3.withPackages (pythonPackages:
        with pythonPackages;
        let
          torchRocm = torchWithRocm.overrideAttrs (old: {
            version = "2.3.1";
            src = pkgs.fetchFromGitHub {
              owner = "pytorch";
              repo = "pytorch";
              rev = "refs/tags/v2.3.1";
              fetchSubmodules = true;
              hash = "sha256-vpgtOqzIDKgRuqdT8lB/g6j+oMIH1RPxdbjtlzZFjV8=";
            };
            patches = old.patches ++ [
              (pkgs.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/pytorch/pytorch/pull/120551.patch";
                hash = "sha256-pcDMC0+l7Ja8Kx4oFTmM9CUjmyzE7p3mikYgyioFwTI=";
              })
              # (pkgs.substituteAll {
              #   aotriton = pkgs.fetchFromGitHub {
              #     owner = "ROCm";
              #     repo = "aotriton";
              #     rev = "24a3fe9cb57e5cda3c923df29743f9767194cc27";
              #     hash = pkgs.lib.fakeHash;
              #     fetchSubmodules = true;
              #     leaveDotGit = true;
              #   };
              #   src = ./aotriton.patch;
              # })
              ./passthrough-python-lib-rel-path.patch
              ./0001-cmake.py-propagate-cmakeFlags-from-environment.patch
            ];

            # nativeBuildInputs = old.nativeBuildInputs ++ [
            #   pkgs.git
            # ];

            # preConfigure = old.preConfigure + ''
            # mkdir homeful-shelter
            # export HOME=`pwd`/homeful-shelter
            # git config --global --add safe.directory '*'
            # '';

            meta = {
              changelog = "https://github.com/pytorch/pytorch/releases/tag/v${version}";
              # keep PyTorch in the description so the package can be found under that name on search.nixos.org
              description = "PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration";
              homepage = "https://pytorch.org/";
              license = lib.licenses.bsd3;
              maintainers = with lib.maintainers; [
                teh
                thoughtpolice
                tscholak
              ]; # tscholak esp. for darwin-related builds
              platforms =
                lib.platforms.linux
                ++ lib.optionals (!cudaSupport && !rocmSupport) lib.platforms.darwin;
            };
          });
          # torchRocmBin = torch-bin.overrideAttrs (old: {
          #   src = {
          #     name = "torch-2.5.1-cp312-cp312-linux_x86_64.whl";
          #     url = "https://download.pytorch.org/whl/rocm6.2.4/torch-2.6.0%2Brocm6.2.4-cp312-cp312-manylinux_2_28_x86_64.whl";
          #     hash = pkgs.lib.fakeHash;
          #   };
          #   buildInputs = with pkgs.rocmPackages; [
          #     rocm-core
          #     clr
          #     rccl
          #     miopen
          #     miopengemm
          #     rocrand
          #     rocblas
          #     rocsparse
          #     hipsparse
          #     rocthrust
          #     rocprim
          #     hipcub
          #     roctracer
          #     rocfft
          #     rocsolver
          #     hipfft
          #     hipsolver
          #     hipblas
          #     rocminfo
          #     rocm-thunk
          #     rocm-comgr
          #     rocm-device-libs
          #     rocm-runtime
          #     clr.icd
          #     hipify
          #   ];
          # });
        in
        [
          # sounddevice
          numpy
          scipy
          sentence-transformers
          # pyaudio
          # pkgs.yubikey-manager
          # yubico-client
          # pyscard
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

          # python-lsp-server
          # openai
          requests
          # python-s[ocketio
          # grequests
          # tiktoken]

          # onnxruntime
          pillow
          # opencv4
          # cairosvg
          yt-dlp
          ytmusicapi
          matplotlib
        ] ++ (if pkgs.system == "x86_64-linux" then [
          manim
          pyusb
          python-escpos
          pycups
          # (openai-whisper.override {
          #   torch = (torch-bin.override {
          #     openai-triton = openai-triton;
          #   }).overrideAttrs (old: {
          #     src = pkgs.fetchurl {
          #       name = "torch-2.4.1+rocm6.0-cp311-cp311-linux_x86_64.whl";
          #       url = "https://download.pytorch.org/whl/rocm6.0/torch-2.4.1%2Brocm6.0-cp311-cp311-linux_x86_64.whl";
          #       hash = "sha256-68jZM2IfkREysxRtT/wORWyJ2TwPcLogtJeQ0stloIw=";
          #     };
          #     patches = [];
          #     # buildInputs = with pkgs; old.buildInputs ++ [
          #     #   rocm-runtime
          #     #   rocm-device-libs
          #     # ];
          #     patchPhase = "";
          #     buildInputs = [
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
          #         pkgs.zstd
          #       ];

          #     autoPatchelfIgnoreMissingDeps = [
          #       "libhipblaslt.so.0"
          #     ];
          #   });
          #   openai-triton = openai-triton;
          # })
          # torchRocm
          tiktoken
          # (fairscale.override {
          #   torch = torchRocm;
          # })
          fire
          blobfile
          hid
          # torchWithCuda

          chromadb
        ] else [])))

      (fenixStructured {
        extensions = ["rust-src" "rust-analyzer" "llvm-tools-preview"];
        targets = [
          "wasm32-unknown-unknown"
          "wasm32-wasip1"
          "wasm32-wasip2"
          "thumbv7em-none-eabihf"
          # "wasm32-unknown-emscripten"
          # "x86_64-unknown-linux-musl"
          "riscv32i-unknown-none-elf"

          "thumbv7em-none-eabi"
          "thumbv7m-none-eabi"
          "thumbv6m-none-eabi"
          "thumbv8m.main-none-eabihf"
          "riscv32imac-unknown-none-elf"
          "wasm32-unknown-unknown"
        ] ++ (if pkgs.system == "x86_64-linux" then ["x86_64-unknown-linux-musl"] else []);
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

      pkgs.openrgb

      # pkgs.cider
      # pkgs.nordic
      # pkgs.nordzy-icon-theme
      # pkgs.nordzy-cursor-theme

      pkgs.libreoffice-qt
      pkgs.optar

      # pkgs.latte-dock

      pkgs.transmission_4-qt6
      pkgs.kdePackages.ktorrent
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

      pkgs.cutechess
      pkgs.stockfish
      pkgs.chessx
      # pkgs.xboard

      pkgs.vesktop

      pkgs.mold
      # pkgs.cutter
      # pkgs.rizin

      pkgs.just

      pkgs.aseprite

      pkgs.craftos-pc
      (packwiz.packages.${pkgs.system}.default.override {
        buildGoModule = args:
          pkgs.buildGoModule (args
            // rec {
              vendorHash = "sha256-krdrLQHM///dtdlfEhvSUDV2QljvxFc2ouMVQVhN7A0=";
            });
      })

      pkgs.agenix

      pkgs.monaspace
      pkgs.twitter-color-emoji

      pkgs.freecad-wayland

      pkgs.minisign
      pkgs.rage

      (pkgs.callPackage ./nerd-font-symbols/package.nix {})

      (pkgs.callPackage ../../nome-manager/package.nix { path = config.programs.home-manager.path; })
      (pkgs.callPackage ../../nomos-rebuild/package.nix {})
      pkgs.nix-output-monitor 

      pkgs.ripgrep
      pkgs.solaar
      pkgs.kicad

      pkgs.file
      (pkgs.prismlauncher.override {
        gamemodeSupport = true;

        # glfw3-minecraft = pkgsUnstable.glfw3-minecraft;

        # glfw = pkgs.callPackage (import ./glfw/package.nix) {};

        additionalLibs = [pkgs.libva pkgs.libuuid];
        jdks = with pkgs; [
          jdk8
          jdk17
          jdk21
        ];
      })
      pkgs.prusa-slicer
      pkgs.klipper-estimator
      pkgs.libnotify
      pkgs.wl-clipboard-rs
      pkgs.signal-desktop
      pkgs.ghostty
      pkgs.ghc
      pkgs.haskell-language-server
      pkgs.cabal-install
      pkgs.stack
      pkgs.cmake

      pkgs.libqalculate
    ]
    ++ (
      if pkgs.system == "x86_64-linux"
      then [
        pkgs.slimevr
        pkgs.slimevr-server # .mitmCache.updateScript
        pkgs.galaxy-buds-client
        pkgs.lutris
        pkgs.blender-hip
        pkgs.arduino
        pkgs.love
        pkgs.jetbrains.idea-community # edu license means I can't use Ultimate for contracts
        pkgs.jetbrains.rider
        pkgs.ollama-rocm

        (pkgs.wlx-overlay-s.override {
          rustPlatform = pkgsUnstable.rustPlatform;
        })
      ]
      else [
        pkgs.fuzzel
        pkgs.rnote
        pkgs.maliit-keyboard
        pkgs.maliit-framework
        pkgs.xournalpp
        # (pkgs.steam.override {
        #   # steamn't
        #   steam-unwrapped = null;
        #   # steam-runtime-wrapped = pkgs.steamPackages.steam-runtime-wrapped.override {
        #   #   steamArch = "amd64";
        #   # };
        #   # steam-runtime-wrapped-i686 = null;
        #   # glxinfo-i686 = null;
        #   # extraPkgs = _: with pkgsAmd64; [
        #   #   mbedtls_2
        #   #   libgcc.lib
        #   #   libunwind
        #   #   libpng12
        #   # ];
        # })
        # .run
        pkgs.krita
        # pkgsUnstable.jetbrains.idea-ultimate
        (pkgs.callPackage ./spot.nix {})
        (pkgs.callPackage ./space-station-14-launcher/space-station-14-launcher.nix {})
      ]
    );
  xdg.configFile."openvr/openvrpaths.vrpath".text = ''{"version":1,"runtime":["${pkgsUnstable.callPackage ./xrizer.nix {}}/lib/xrizer"]}'';
  # xdg.configFile."openvr/openvrpaths.vrpath".text = ''{"version":1,"runtime":["${pkgs.opencomposite}/lib/opencomposite"]}'';
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
        ${overlays}
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
    catppuccin = {
      enable = true;
    };
    font = {
      name = "Inter Variable Medium";
      size = 10;
    };
    iconTheme.name = "Papirus-Dark";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  programs.mangohud.enable = true;

  # qt = {
  #   enable = true;
  #   # platformTheme = "kde";
  #   # style.name = "kvantum-dark";
  # };

  home.pointerCursor = {
    package = pkgs.catppuccin-cursors."${config.catppuccin.flavor}${mkUpper catppuccinDarkness}";
    name = "catppuccin-${config.catppuccin.flavor}-${catppuccinDarkness}-cursors";
    # size = 24;
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
        # thefuck --alias | source
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
  #     theme = "catppuccin_${config.catppuccin.flavor}";
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
    mutableExtensionsDir = true;
    userSettings = {
      "update.mode" = "none";
      "rust-analyzer.check.command" = "clippy";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "editor.fontFamily" = "\"Monaspace Neon\", \"Symbols Nerd Font\", \"Twitter Color Emoji\"";
      "editor.fontLigatures" = "'calt', 'ss03', 'liga'";
      "yaml.schemaStore.enable" = true;
      "redhat.telemetry.enabled" = false;
      "svelte.enable-ts-plugin" = true;
      "workbench.colorTheme" = "Catppuccin ${mkUpper config.catppuccin.flavor}";
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
        # # catppuccin-vsc's output is architecture-agnostic
        # # so just build this once
        # (catppuccin-vsc.packages.${pkgs.system}.default.override {
        #   accent = config.catppuccin.accent;
        # })
        catppuccin.catppuccin-vsc

        mkhl.direnv
        jnoortheen.nix-ide
        skellock.just

        (rust-lang.rust-analyzer.override { setDefaultServerPath = false; })
        tamasfe.even-better-toml

        sumneko.lua

        redhat.vscode-yaml
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        github.vscode-github-actions

        golang.go

        vue.volar

        antyos.openscad

        ms-python.python
        ms-python.vscode-pylance

        haskell.haskell
        justusadam.language-haskell

        unifiedjs.vscode-mdx
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscode-deno";
          publisher = "denoland";
          version = "3.42.0";
          sha256 = "sha256-bfhpIxqHeUph51VBMlKBvdBJIeSO9E1ZitrfVl/MqgQ=";
        }
        {
          name = "figura";
          publisher = "manuel-underscore";
          version = "1.8.0";
          sha256 = "sha256-qA1GDS+GyIqa17OrIk4A0u7z5AyknhwNOy0/tF8kaBU=";
        }
        {
          name = "hex-casting";
          publisher = "object-Object";
          version = "0.1.35";
          sha256 = "sha256-Q+PeU8AGqVu99xQ2EirBjCAnoZIUi/+uefN5aC32uxQ=";
        }
        {
          name = "godot-tools";
          publisher = "geequlim";
          version = "1.3.1";
          sha256 = "sha256-wJICDW8bEBjilhjhoaSddN63vVn6l6aepPtx8VKTdZA=";
        }
        {
          name = "devicetree";
          publisher = "plorefice";
          version = "0.1.1";
          sha256 = "sha256-udyeY8OuI9+c26WMR63NqElyJLxdMqgOXkkmWF8233k=";
        }
        {
          name = "shader";
          publisher = "slevesque";
          version = "1.1.5";
          sha256 = "sha256-Pf37FeQMNlv74f7LMz9+CKscF6UjTZ7ZpcaZFKtX2ZM=";
        }
        {
          name = "slint";
          publisher = "Slint";
          version = "1.6.0";
          sha256 = "sha256-Vion8XEjAbnTYg2ETqZTuTa83cZM7+/j8ng4uUPxz+Q=";
        }
        {
          name = "kdl";
          publisher = "kdl-org";
          version = "1.3.1";
          sha256 = "sha256-0Wbyh6yaGyj/fyTUERB5KQd668i0fx/XLc/i2YkXYKg=";
        }
        {
          name = "codespaces";
          publisher = "github";
          version = "1.17.1";
          sha256 = "sha256-U1pjQFwip1UWSFOZgqUGceGQ9XMizcSOwtFTEgRLQrU=";
        }
      ]
      ++ (
        if pkgs.system == "x86_64-linux"
        then
          [
            vadimcn.vscode-lldb

            ms-vscode.cpptools
            ms-vscode.cmake-tools
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "pico-w-go";
              publisher = "paulober";
              version = "3.5.0";
              arch = "linux-x64";
              sha256 = "sha256-6cGcJaYTFWvmR1PKBymoHC8GnQ0AGOSsdoYKlbNE1U0=";
            }
          ]
        else []
      );
  };

  programs.go.enable = true;
  programs.go.package = pkgsUnstable.go;
  programs.firefox.enable = true;
  # programs.firefox.package = firefox.packages.${pkgs.system}.firefox-nightly-bin;

  programs.chromium = {
    enable = pkgs.system == "aarch64-linux";
    commandLineArgs = ["--force-device-scale-factor=1.5"];
    dictionaries = with pkgs.hunspellDictsChromium; [
      en_US
      en_GB
    ];
    extensions = [
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "clngdbkpkpeebahjckkjfobafhncgmne"; } # stylus
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBO
      {
        id = "lkbebcjgcmobigpeffafkodonchffocl";
        updateUrl = "https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/raw/master/updates.xml";
      }
      { id = "icallnadddjmdinamnolclfjanhfoafe"; } # fastforward
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
      { id = "nblkbiljcjfemkfjnhoobnojjgjdmknf"; } # pronoundb
      { id = "ijcpiojgefnkmcadacmacogglhjdjphj"; } # shinigami
      { id = "jinjaccalgkegednnccohejagnlnfdag"; } # violentmonkey
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # darkreader
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.enable = true;
}
