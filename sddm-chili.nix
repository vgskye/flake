{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sddm-chili";
  version = "0.1.5";

  src = fetchFromGitHub {
    repo = "sddm-chili";
    owner = "MarianArlt";
    rev = "${version}";
    sha256 = "sha256-wxWsdRGC59YzDcSopDRzxg8TfjjmA3LHrdWjepTuzgw=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sddm/themes/sddm-chili
    cp -r * $out/share/sddm/themes/sddm-chili

    runHook postInstall
  '';

  meta = with lib; {
    description = " The hottest theme around for SDDM, the Simple Desktop Display Manager. ";
    homepage = "https://github.com/MarianArlt/sddm-chili";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
