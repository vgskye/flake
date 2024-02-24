{
  lib,
  stdenv,
  stdenvNoCC,
  fetchgit,
  jq,
  moreutils,
  nodePackages,
  nodejs,
  cacert,
}: let
  gitHash = "20cf1eb6a20268cf2c71aea8adfc83cc9aab52ca";
in
  stdenv.mkDerivation rec {
    pname = "owo-vencord";
    version = builtins.substring 0 8 gitHash;

    src = fetchgit {
      url = "https://git.skye.vg/me/owo-vencord.git";
      rev = gitHash;
      sha256 = "sha256-NrzsRs2py68zWv7vn6FHDBY9g2X5EGC1WIjFCcAmp4g=";
    };

    pnpmPatch = builtins.toJSON {
      pnpm.supportedArchitectures = {
        os = [ "linux" ];
        cpu = [ "x64" "arm64" ];
      };
    };

    postPatch = ''
      mv package.json package.json.orig
      jq --raw-output ". * $pnpmPatch" package.json.orig > package.json
    '';

    pnpmDeps =
      assert lib.versionAtLeast nodePackages.pnpm.version "8.10.0";
      stdenvNoCC.mkDerivation {
      pname = "${pname}-pnpm-deps";
      inherit src version pnpmPatch postPatch;

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

      dontBuild = true;
      dontFixup = true;
      outputHashMode = "recursive";
      outputHash =
        if stdenv.hostPlatform.system == "x86_64-linux" then
        "sha256-mw8YhSHYAIVJQA4/zMyeXnhNus56k/dDv9MwqzClVNs=" else
        lib.fakeHash;
    };

    VENCORD_HASH = gitHash;
    VENCORD_REMOTE = "vgskye/owo-vencord";

    nativeBuildInputs = [
      jq
      nodePackages.pnpm
      nodejs
    ];

    preBuild = ''
      export HOME=$(mktemp -d)
      export STORE_PATH=$(mktemp -d)

      cp -Tr "$pnpmDeps" "$STORE_PATH"
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

    passthru = {
      inherit pnpmDeps;
    };

    meta = with lib; {
      description = "Vencord but patch";
      homepage = "https://git.skye.vg/me/owo-vencord";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [vgskye];
    };
  }
