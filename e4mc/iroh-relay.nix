{
  lib,
  fetchFromGitHub,
  rustPlatform,
  lld,
}:
rustPlatform.buildRustPackage rec {
  pname = "iroh-relay";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "n0-computer";
    repo = "iroh";
    rev = "v${version}";
    hash = "sha256-9DuN44SKqVePErWDJ3ELwgwvDbVkKG6wZTFNsipCaVA=";
  };

  nativeBuildInputs = [
    lld
  ];

  cargoHash = "sha256-j6+ewPmutDpxm1ESjvMu2l61ijmbla2W/n/tqJcGQJU=";

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
