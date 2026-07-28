{
  lib,
  fetchFromGitHub,
  rustPlatform,
  lld,
}:
rustPlatform.buildRustPackage rec {
  pname = "iroh-relay";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "n0-computer";
    repo = "iroh";
    rev = "v${version}";
    hash = "sha256-qZft++kZytCC49WK3uqpsdI4Ko3YdBFEws31kZ7SM2Q=";
  };

  nativeBuildInputs = [
    lld
  ];

  cargoHash = "sha256-8u3vkP0wCNzLaT6Bb1wnBzl7c1req8NsAhj2zbT6EtE=";

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
