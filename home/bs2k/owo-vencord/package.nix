{
  lib,
  stdenv,
  stdenvNoCC,
  gcc13Stdenv,
  fetchFromGitHub,
  fetchgit,
  substituteAll,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  vencord,
  electron,
  pipewire,
  libpulseaudio,
  libicns,
  jq,
  moreutils,
  nodePackages,
  nodejs,
  cacert,
}: let
  version = "owo-2023-12-14";
  gitHash = "beaf164aa88d139ca4d998cbc447936f47b8e171";
in
  stdenv.mkDerivation rec {
    pname = "owo-vencord";
    inherit version;

    src = fetchgit {
      url = "https://git.skye.vg/me/owo-vencord.git";
      rev = gitHash;
      sha256 = "sha256-smXQt+bRz0b+Dh+H1uy04SLUBddXJ4NTrqZ8K++Xn+s=";
    };

    pnpm-deps = stdenvNoCC.mkDerivation {
      pname = "${pname}-pnpm-deps";
      inherit src version;

      nativeBuildInputs = [
        jq
        moreutils
        nodePackages.pnpm
        cacert
      ];

      # https://github.com/NixOS/nixpkgs/blob/763e59ffedb5c25774387bf99bc725df5df82d10/pkgs/applications/misc/pot/default.nix#L56
      installPhase = ''
        export HOME=$(mktemp -d)

        pnpm config set store-dir $out
        pnpm install --frozen-lockfile --ignore-script

        rm -rf $out/v3/tmp
        for f in $(find $out -name "*.json"); do
          sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
          jq --sort-keys . $f | sponge $f
        done
      '';

      dontFixup = true;
      outputHashMode = "recursive";
      outputHash = "sha256-QKk/r9l8iXUBka4PraqdnWPPSrENx/pvpkTKueg/dv4=";
    };

    VENCORD_HASH = gitHash;
    VENCORD_REMOTE = "vgskye/owo-vencord";

    nativeBuildInputs = [
      nodePackages.pnpm
      nodejs
    ];

    preBuild = ''
      export HOME=$(mktemp -d)
      export STORE_PATH=$(mktemp -d)

      cp -r ${pnpm-deps}/* "$STORE_PATH"
      chmod -R +w "$STORE_PATH"

      pnpm config set store-dir "$STORE_PATH"
      pnpm install --offline --frozen-lockfile --ignore-script
    '';

    postBuild = ''
      pnpm build
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist/ $out

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "vencorddesktop";
        desktopName = "Vesktop";
        exec = "vencorddesktop %U";
        icon = "vencorddesktop";
        startupWMClass = "VencordDesktop";
        genericName = "Internet Messenger";
        keywords = ["discord" "vencord" "electron" "chat"];
      })
    ];

    meta = with lib; {
      description = "Vencord but patch";
      homepage = "https://git.skye.vg/me/owo-vencord";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [vgskye];
    };
  }
