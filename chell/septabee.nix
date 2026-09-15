{
  autoPatchelfHook,
  copyDesktopItems,
  fetchurl,
  jack2,
  lib,
  libgcc,
  libx11,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  p7zip,
  pipewire,
  stdenv,
  vulkan-loader,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "septabee";
  version = "B-T11";

  src = fetchurl {
    url = "https://septabee.nekoweb.org/important_stuff/SEPTABEE_DOWNLOADS/version_B/septabee_linux_B_T11_offline.7z";
    hash = "sha256-NYbHt7KjgXaosV1CLd1nI76gYpWTTE0NY2stCOTLHdM=";
  };

  icon = fetchurl {
    url = "https://septabee.nekoweb.org/important_stuff/icon.png";
    sha256 = "sha256-snq/nOYU2gPzC4VR558VjeQ8oXmQE82IolNDDixvtTU=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "septabee";
      desktopName = "Septabee";
      genericName = "Septabee Digital Audio Workstation";
      exec = "septabee";
      icon = "septabee";
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
        "Midi"
      ];
    })
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    p7zip
  ];

  buildInputs = [
    libgcc.lib
    libx11
  ];

  installPhase = let
    libPath = lib.makeLibraryPath [
      jack2
      libxkbcommon
      pipewire
      vulkan-loader
      wayland
    ];
  in ''
    runHook preInstall
    mkdir -p $out/
    cp -R . $out/

    makeWrapper $out/septabee $out/bin/septabee \
      --prefix LD_LIBRARY_PATH : ${libPath}

    install -Dm644 ${finalAttrs.icon} $out/share/icons/hicolor/256x256/apps/septabee.png

    runHook postInstall
  '';

  meta = {
    description = "thingy";
    homepage = "https://septabee.nekoweb.org/";
    maintainers = with lib.maintainers; [
      vgskye
    ];
    platforms = [
      "x86_64-linux"
    ];
  };
})
