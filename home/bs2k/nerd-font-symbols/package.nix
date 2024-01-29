{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "nerd-font-symbols";
  version = "3.1.1";

  src = fetchzip {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/NerdFontsSymbolsOnly.zip";
    stripRoot = false;
    hash = "sha256-KPN2rJagUvddv1gBqZCDkd9JAGlJRYUff9iuCNp21Bs=";
  };

  buildPhase = ''
    runHook preBuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.nerdfonts.com/";
    description = "Nerd Fonts, Symbols only.";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [maintainers.vgskye];
  };
}
