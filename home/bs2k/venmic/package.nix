{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  electron,
  pipewire,
  libicns,
  jq,
  moreutils,
  nodePackages,
  nodejs,
  esbuild,
  buildGoModule,
}:
stdenv.mkDerivation rec {
  pname = "venmic";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Vencord";
    repo = "venmic";
    rev = "v${version}";
    sha256 = "";
  };

  pnpm-deps = stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit src version;

    nativeBuildInputs = [
      jq
      moreutils
      nodePackages.pnpm
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
    outputHash = "";
  };

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
    pnpm i --offline --frozen-lockfile --ignore-script
    patchShebangs node_modules/{*,.*}
  '';

  postBuild = ''
    pnpm install
  '';

  # this is consistent with other nixpkgs electron packages and upstream, as far as I am aware
  # yes, upstream really packages it as "vesktop" but uses "vencorddesktop" file names
  installPhase = ''
    runHook preInstall

    runHook postInstall
  '';

  meta = with lib; {
    description = "An alternate client for Discord with Vencord built-in";
    homepage = "https://github.com/Vencord/Vesktop";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [getchoo Scrumplex vgskye];
    platforms = platforms.linux;
  };
}
