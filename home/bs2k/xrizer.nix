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
  version = "0.1.0-df1478173fdf4866f717270be7c27ed5925eb078";

  src = fetchFromGitHub {
    owner = "RinLovesYou";
    repo = "xrizer";
    rev = "df1478173fdf4866f717270be7c27ed5925eb078";
    hash = "sha256-HumHOHidGICi9x7WAoE3TtifoWxXrjZCRp25A1VryfM=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-DWOevdHKT2AtPhfrDJPMkF2/a1D8LwS6mphNdtGqpus=";



  doCheck = false;

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