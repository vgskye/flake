{
  autoPatchelfHook,
  copyDesktopItems,
  curl,
  dbus,
  fetchurl,
  fontconfig,
  freetype,
  lib,
  libdrm,
  libGLU,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  unzip,
  wayland,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  sqlite,
  libuuid,
}:
let
  version = "6.0.10601";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "binaryninja-personal";
  inherit version;

  src = stdenv.mkDerivation {
    name = "binaryninja_linux_stable_personal.zip";
    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = "38eb98e4fc3a23988bdc2ac30c43c38f6532b230f6665003030ecbf9219544c7";

    unpackPhase = ''
      echo :3c
      exit 1
    '';
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/Vector35/binaryninja-api/448f40be71dffa86a6581c3696627ccc1bdf74f2/docs/img/logo.png";
    hash = "sha256-TzGAAefTknnOBj70IHe64D6VwRKqIDpL4+o9kTw0Mn4=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "com.vector35.binaryninja";
      desktopName = "Binary Ninja Personal";
      comment = "A Reverse Engineering Platform";
      exec = "binaryninja";
      icon = "binaryninja";
      mimeTypes = [
        "application/x-binaryninja"
        "x-scheme-handler/binaryninja"
      ];
      categories = [ "Utility" ];
    })
  ];

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    curl
    dbus
    fontconfig
    freetype
    libdrm
    libGLU
    libxkbcommon
    stdenv.cc.cc.lib
    wayland
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    sqlite
    libuuid
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6QuickVectorImageGenerator.so.6"
    "libQt6Quick.so.6"
    "libQt6ShaderTools.so.6"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/
    cp -R . $out/

    mkdir $out/bin
    makeWrapper $out/binaryninja $out/bin/binaryninja \
      --prefix LD_LIBRARY_PATH : $out

    install -Dm644 ${finalAttrs.icon} $out/share/icons/hicolor/256x256/apps/binaryninja.png

    runHook postInstall
  '';

  meta = {
    changelog = "https://binary.ninja/changelog/#${
      lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }";
    description = "Interactive decompiler, disassembler, debugger";
    homepage = "https://binary.ninja/";
    license = {
      fullName = "Binary Ninja Free Software License";
      url = "https://docs.binary.ninja/about/license.html#free-license";
      free = false;
    };
    mainProgram = "binaryninja";
    maintainers = with lib.maintainers; [
      scoder12
      timschumi
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})