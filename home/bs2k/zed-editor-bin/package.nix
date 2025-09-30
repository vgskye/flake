{
  lib,
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  makeBinaryWrapper,
  zlib,
  alsa-lib,
  xorg,
  libxkbcommon,
  libgcc,
  vulkan-loader,
  wayland,
  nodejs,
}:
stdenvNoCC.mkDerivation rec {
  pname = "zed-editor-bin";
  version = "0.205.8";

  src = fetchzip {
    url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
    hash = "sha256-S0xekB1JUxURLa/Vbs+bZ3pyL7VOUbomyk9+t91siYU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  buildInputs = [
    zlib
    alsa-lib
    xorg.libxcb
    xorg.libX11
    libxkbcommon
    libgcc
    libgcc.lib
  ];

  buildPhase = ''
    runHook preBuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 libexec/zed-editor $out/libexec/zed-editor
    install -Dm755 bin/zed $out/bin/zeditor

    install -Dm644 share/icons/hicolor/1024x1024/apps/zed.png $out/share/icons/hicolor/1024x1024/apps/zed.png
    install -Dm644 share/icons/hicolor/512x512/apps/zed.png $out/share/icons/hicolor/512x512/apps/zed.png
    install -Dm644 share/applications/zed.desktop $out/share/applications/zed.desktop
    sed -i "s/Exec=zed/Exec=zeditor/g" $out/share/applications/zed.desktop

    runHook postInstall
  '';

  runtimeDependencies = [
    vulkan-loader
    wayland
  ];

  postFixup = ''
    wrapProgram $out/libexec/zed-editor --suffix PATH : ${lib.makeBinPath [ nodejs ]} --set ZED_UPDATE_EXPLANATION "Zed has been installed using Nix. Auto-updates have thus been disabled."
  '';

  meta = with lib; {
    description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter (binary release)";
    homepage = "https://zed.dev";
    changelog = "https://github.com/zed-industries/zed/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "zeditor";
    platforms = ["x86_64-linux"];
    maintainers = [maintainers.vgskye];
  };
}