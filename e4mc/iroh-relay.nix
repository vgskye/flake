{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iroh-relay";
  version = "0.95.1";

  src = fetchFromGitHub {
    owner = "n0-computer";
    repo = "iroh";
    rev = "v${version}";
    hash = "sha256-YxifH/mH6x6b8J5xyG+/f18o9ngmiLVKvRaDgIv3ok8=";
  };

  cargoHash = "sha256-MdJpGCLf90fTjbJKHCrLLZbLyb4gmQn4SsF5iCqNVVI=";

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
