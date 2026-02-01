{
  lib,
  fetchFromGitHub,
  rustPlatform,
  lld,
}:
rustPlatform.buildRustPackage rec {
  pname = "iroh-relay";
  version = "0.96.0";

  src = fetchFromGitHub {
    owner = "n0-computer";
    repo = "iroh";
    rev = "v${version}";
    hash = "sha256-J7FiKIBFUnTUJJwzwzfyk7+CK0UKlAPNFjVDDGlHMqM=";
  };

  nativeBuildInputs = [
    lld
  ];

  cargoHash = "sha256-W8PVysQffGuxBIDpcZ77ujOQ5KBED6svwEXPeZpQmTc=";

  buildFeatures = [ "server" ];
  cargoBuildFlags = [
    "--bin"
    "iroh-relay"
  ];

  # Some tests require network access which is not available in nix build sandbox.
  doCheck = false;

  meta = {
    description = "Iroh's relay server";
    homepage = "https://iroh.computer";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ vgskye ];
    mainProgram = "iroh-relay";
  };
}
