{
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  autoPatchelfHook,
  fontconfig,
  xorg,
  libglvnd,
  makeDesktopItem,
  copyDesktopItems,
  graphicsmagick,
  dotnet-sdk_7,
  dotnet-runtime_7,
}:
buildDotnetModule rec {
  pname = "galaxy-buds-client";
  version = "4.5.3-commit.8664c9889fae0ac8c5746b55d119272f5d1c727b";

  src = fetchFromGitHub {
    owner = "ThePBone";
    repo = "GalaxyBudsClient";
    rev = "8664c9889fae0ac8c5746b55d119272f5d1c727b";
    hash = "sha256-9dH0y9whJsOLV2WuTMajPqPRfmiaBRm/SSKgQrfY3W0=";
  };

  patches = [./i18n.patch];

  projectFile = ["GalaxyBudsClient/GalaxyBudsClient.csproj"];
  nugetDeps = ./galaxy-buds-client-deps.nix;
  dotnetFlags = ["-p:Runtimeidentifier=linux-x64"];

  nativeBuildInputs = [autoPatchelfHook copyDesktopItems graphicsmagick];

  buildInputs = [stdenv.cc.cc.lib fontconfig];

  runtimeDeps = [libglvnd xorg.libSM xorg.libICE xorg.libX11];

  postFixup = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps/
    gm convert $src/GalaxyBudsClient/Resources/icon_white.ico $out/share/icons/hicolor/256x256/apps/${meta.mainProgram}.png
  '';

  desktopItems = makeDesktopItem {
    name = meta.mainProgram;
    exec = meta.mainProgram;
    icon = meta.mainProgram;
    desktopName = meta.mainProgram;
    genericName = "Galaxy Buds Client";
    comment = meta.description;
    type = "Application";
    categories = ["Settings"];
    startupNotify = true;
  };

  meta = with lib; {
    mainProgram = "GalaxyBudsClient";
    description = "Unofficial Galaxy Buds Manager for Windows and Linux";
    homepage = "https://github.com/ThePBone/GalaxyBudsClient";
    license = licenses.gpl3;
    maintainers = [maintainers.icy-thought];
    platforms = platforms.linux;
  };
}
