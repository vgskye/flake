{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  llvmPackages,
  binutils-unwrapped,
  alsaLib,
  openssl,
  glib,
  ffmpeg-full,
  cairo,
  pango,
  atk,
  gdk-pixbuf,
  gtk3,
  clang,
  vulkan-tools-lunarg,
  vulkan-headers,
  vulkan-loader,
  vulkan-validation-layers,
  xorg,
  libunwind,
  python3,
  libxkbcommon,
  jack2,
  chromium,
  pkg-config,
  clang-tools,
  clang_12,
  python3Full,
  makeWrapper,
}:
with rustPlatform;
  buildRustPackage rec {
    pname = "alvr";
    version = "19.0.0";

    src = fetchFromGitHub {
      owner = "alvr-org";
      repo = "ALVR";
      rev = "v${version}";
      sha256 = "sha256-XdVDZeoYhRv03mtT0L0s2jUZ6TZniqPJRMIBEd993Fw=";
    };

    patches = [];

    cargoSha256 = "sha256-jV0G8qrdfgxNWLR7KXRTPpM6C2FPUUAvD60mschYNmE=";

    buildInputs = [
      binutils-unwrapped
      alsaLib
      openssl
      glib
      (ffmpeg-full.override {
        nonfreeLicensing = true;
        samba = null;
      })
      cairo
      pango
      atk
      gdk-pixbuf
      gtk3
      clang
      (vulkan-tools-lunarg.overrideAttrs (oldAttrs: rec {
        patches = [
          (fetchurl {
            url = "https://gist.githubusercontent.com/ckiee/038809f55f658595107b2da41acff298/raw/6d8d0a91bfd335a25e88cc76eec5c22bf1ece611/vulkantools-log.patch";
            sha256 = "14gji272r53pykaadkh6rswlzwhh9iqsy1y4q0gdp8ai4ycqd129";
          })
        ];
      }))
      vulkan-headers
      vulkan-loader
      vulkan-validation-layers
      xorg.libX11
      xorg.libXrandr
      libunwind
      python3 # for the xcb crate
      libxkbcommon
      jack2
    ];

    nativeBuildInputs = [pkg-config clang-tools clang_12 python3Full makeWrapper];

    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

    doCheck = false;

    cargoPatches = [
      # a patch file to add/update Cargo.lock in the source code
      ./alvr.patch
    ];

    buildPhase = ''
      cargo xtask build-server --release
    '';

    postPatch = ''
      substituteInPlace alvr/vrcompositor_wrapper/src/main.rs --replace "../../share/vulkan/explicit_layer.d" "$out/share/vulkan/explicit_layer.d"
    '';

    installPhase = ''
      installPhaseTarget=target/release
      mkdir -p $out/bin
      mkdir -p $out/share/vulkan/explicit_layer.d
      mkdir -p $out/share/alvr/presets
      mkdir -p $out/lib/alvr
      mkdir -p $out/lib/steamvr/alvr/bin/linux64

      # Replace lib64 stuffs
      substituteInPlace alvr/vulkan_layer/layer/alvr_x86_64.json --replace "../../../lib64/" "$out/lib/"

      # ALVR stuffs
      cp $installPhaseTarget/alvr_launcher $out/bin
      cp $installPhaseTarget/alvr_vrcompositor_wrapper $out/lib/alvr/vrcompositor-wrapper

      # alvr driver
      cp $installPhaseTarget/libalvr_server.so $out/lib/steamvr/alvr/bin/linux64/driver_alvr_server.so
      cp alvr/xtask/resources/driver.vrdrivermanifest $out/lib/steamvr/alvr/

      # Vulkan Layer
      cp $installPhaseTarget/libalvr_vulkan_layer.so $out/lib/
      cp alvr/vulkan_layer/layer/alvr_x86_64.json $out/share/vulkan/explicit_layer.d/

      # Dashboard
      cp -r dashboard $out/share/alvr/
      mkdir -p $out/share/alvr/presets/

      # Include chromium
      wrapProgram $out/bin/alvr_launcher --set ALCRO_BROWSER_PATH=${chromium}/bin/chromium
    '';

    meta = with lib; {
      description = "Stream VR games from your PC to your headset over the network";
      homepage = "https://alvr-org.github.io";
      platforms = ["x86_64-linux"];
      license = licenses.mit;
      maintainers = [maintainers.ronthecookie];
    };
  }
