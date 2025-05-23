{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "depthchargectl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vgskye";
    repo = pname;
    rev = "501690d1e7adc80b10417d5bf6f1e79d7f9fd0dd";
    hash = "sha256-oXPX3WfJDzy5LU5GW8Poas3DH+MxMhCsmrgVs5krmj0=";
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