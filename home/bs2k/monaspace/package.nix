{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "monaspace";
  version = "1.000";

  src = fetchzip {
    url = "https://github.com/githubnext/monaspace/releases/download/v${version}/monaspace-v${version}.zip";
    stripRoot = false;
    hash = "sha256-H8NOS+pVkrY9DofuJhPR2OlzkF4fMdmP2zfDBfrk83A=";
  };

  buildPhase = ''
    runHook preBuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 monaspace-v${version}/fonts/variable/*.ttf -t $out/share/fonts/truetype
    install -Dm644 monaspace-v${version}/fonts/otf/*.otf -t $out/share/fonts/opentype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://monaspace.githubnext.com/";
    description = "An innovative superfamily of fonts for code, nerd font patched";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = [maintainers.vgskye];
  };
}
