{
  lib,
  stdenv,
  fetchurl, 
  dpkg,
  autoPatchelfHook,
  cups
}:
let
  version = "1.1";
in
  stdenv.mkDerivation {

    pname = "sewoo_linux_driver";
    inherit version;

    src = fetchurl {
      # NOTE: Don't forget to update the webarchive link too!
      urls = [
        "https://www.miniprinter.com/bbs/filedownloads.php?bf_no=9&wr_id=8&bo_table=product_system"
      ];
      sha256 = "14fc729c951fdac180496add04ded565f7d428a36c1beb0b0cff8ef28f64e29c";
    };

    unpackCmd = "dpkg -x $curSrc source";

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
    ];

    buildInputs = [ cups ];

    installPhase = ''
      runHook preInstall

      install -Dm755 opt/sewoo/printer-driver-sewoo/bin/rastertosnailtspl-x64 $out/lib/cups/filter/rastertosnailtspl-sewoo
      install -Dm755 opt/sewoo/printer-driver-sewoo/bin/rastertosnailep-x64 $out/lib/cups/filter/rastertosnailep-sewoo
      install -Dm755 opt/sewoo/printer-driver-sewoo/bin/rastertosnailxpl-x64 $out/lib/cups/filter/rastertosnailxpl-sewoo
      install -Dm755 opt/sewoo/printer-driver-sewoo/bin/rastertosnailppli-x64 $out/lib/cups/filter/rastertosnailppli-sewoo
      install -Dm755 opt/sewoo/printer-driver-sewoo/bin/rastertosnailep2-x64 $out/lib/cups/filter/rastertosnailep2-sewoo
      cp -ar ./usr/share $out

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://www.miniprinter.com/page/?pid=product_view&pr_id=8";
      description = "Sewoo printer driver (SLK-TS100)";
      license = with licenses; [ unfree ];
      maintainers = [ maintainers.vgskye ];
      platforms = [ "x86_64-linux" ];
    };

  }