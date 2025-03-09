{
  fetchFromGitHub,
  lib,
  libxkbcommon,
  nix-update-script,
  openxr-loader,
  pkg-config,
  rustPlatform,
  shaderc,
  vulkan-loader,
}:
rustPlatform.buildRustPackage rec {
  pname = "xrizer";
  version = "0.1.0-63434338b36f91234dd5d0e69f30793368e94d00";

  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xrizer";
    rev = "63434338b36f91234dd5d0e69f30793368e94d00";
    hash = "sha256-FNsL9SnfYPg3tjYlk9d172iyAVlqC6U7ZgHVOoSSEFo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Wxubm4uypS+EZQ+UcDDjQBNbJBkYVhDvsY62WTTSGuk=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    shaderc
  ];

  buildInputs = [
    libxkbcommon
    vulkan-loader
    openxr-loader
  ];

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'features = ["static"]' 'features = ["linked"]'
  '';

  postInstall = ''
    mkdir -p $out/lib/xrizer/bin/linux64
    ln -s "$out/lib/libxrizer.so" "$out/lib/xrizer/bin/linux64/vrclient.so"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "XR-ize your favorite OpenVR games";
    homepage = "https://github.com/Supreeeme/xrizer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Scrumplex ];
    # TODO: support more systems
    # To do so, we need to map systems to the format openvr expects.
    # i.e. x86_64-linux -> linux64, aarch64-linux -> linuxarm64
    platforms = [ "x86_64-linux" ];
  };
}