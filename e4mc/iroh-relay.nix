{
  lib,
  fetchFromGitHub,
  rustPlatform,
  lld,
}:
rustPlatform.buildRustPackage rec {
  pname = "iroh-relay";
  version = "1.0.0-rc.1";

  src = fetchFromGitHub {
    owner = "n0-computer";
    repo = "iroh";
    rev = "v${version}";
    hash = "sha256-ajOqw++wLFDOawLkqY1NlQaDvZHDCq0BSk38yfaJa50=";
  };

  nativeBuildInputs = [
    lld
  ];

  cargoHash = "sha256-c9V45tGUtG1CDViqu2XvCgDuVH+9aLdcKMOyn38N6JE=";

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
