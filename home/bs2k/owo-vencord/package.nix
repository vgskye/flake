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
  gitHash = "a3dcff732594b8d02160ea8b7718e9b29c68ed5f";
in
  stdenv.mkDerivation rec {
    pname = "owo-vencord";
    version = builtins.substring 0 8 gitHash;

    src = fetchgit {
      url = "https://git.skye.vg/me/owo-vencord.git";
      rev = gitHash;
      sha256 = "sha256-U+pGXfCAucHgPbA4BLKL2+m+b8Xj2zO4qqqilcbFVD8=";
    };

    pnpmDeps =
      assert lib.versionAtLeast nodePackages.pnpm.version "8.10.0";
      stdenvNoCC.mkDerivation {
      pname = "${pname}-pnpm-deps";
      inherit src version;

      nativeBuildInputs = [
        jq
        moreutils
        nodePackages.pnpm
        cacert
      ];

      installPhase = ''
        runHook preInstall
        export HOME=$(mktemp -d)
        pnpm config set store-dir $out
        # pnpm is going to warn us about using --force
        # --force allows us to fetch all dependencies including ones that aren't meant for our host platform
        pnpm install --no-frozen-lockfile --ignore-script --force
        runHook postInstall
      '';

      fixupPhase = ''
        runHook preFixup
        rm -rf $out/v3/tmp
        for f in $(find $out -name "*.json"); do
          sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
          jq --sort-keys . $f | sponge $f
        done
        runHook postFixup
      '';

      dontConfigure = true;
      dontBuild = true;
      outputHashMode = "recursive";
      outputHash = lib.fakeHash;
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
      pnpm install --offline --no-frozen-lockfile --ignore-script
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
