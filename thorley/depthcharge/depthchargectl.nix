{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "depthchargectl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vgskye";
    repo = pname;
    rev = "94975edf7d451c6506ecc6e4f5516479796b945a";
    hash = "sha256-SFJWJRtqkh0SCi7KC0olcSVcMfT3dFyWnnLneMrM0bQ=";
  };

  cargoHash = "sha256-c4T5kL8JEEwG1nOoeQxfAe+KUv5ryRsuu02IjRQJaoE=";

  meta = with lib; {
    description = "like cgpt but worse";
    homepage = "https://github.com/vgskye/depthchargectl";
    license = licenses.mit;
    maintainers = with lib.maintainers; [
      vgskye
    ];
  };
}