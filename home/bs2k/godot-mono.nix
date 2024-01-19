self: super: {
  godot-mono = with super; let
    arch = "64";
    version = "3.4.4";
    pkg = stdenv.mkDerivation {
      name = "godot-mono-unwrapped";
      buildInputs = [unzip];
      unpackPhase = "unzip $src";
      version = version;
      src = fetchurl {
        url = "https://downloads.tuxfamily.org/godotengine/${version}/mono/Godot_v${version}-stable_mono_x11_${arch}.zip";
        sha256 = "sha256-7GIoWbWrcPzx+XgcNOMNVaXXvcN5JvEzTCzQo+TUp3Y=";
      };
      installPhase = ''
        cp -r . $out
      '';
    };
  in
    buildFHSUserEnv {
      name = "godot-mono";
      targetPkgs = pkgs: (with pkgs; [
        libpulseaudio
        xorg.libX11
        xorg.libXcursor
        xorg.libXinerama
        xorg.libXrandr
        xorg.libXrender
        xorg.libXi
        xorg.libXext
        alsaLib
        libGL
        msbuild
      ]);
      runScript = "${pkg.outPath}/Godot_v${version}-stable_mono_x11_${arch}/Godot_v${version}-stable_mono_x11.${arch}";
    };
}
