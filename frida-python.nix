# This is largely taken from the NUR package of genesis, see
# https://github.com/nix-community/nur-combined/blob/master/repos/genesis/pkgs/frida-tools/default.nix.
{
  lib,
  stdenv,
  fetchurl,
  python3,
  system,
}: let
  pname = "frida-python";
  version = "16.1.3";
  namePypi = "frida";
  pythonVersion = "38";
  base = "https://files.pythonhosted.org/packages/${python3.pythonVersion}/${builtins.substring 0 1 namePypi}/${namePypi}";
  egg =
    if system == "x86_64-linux"
    then
      fetchurl
      {
        url = "${base}/${namePypi}-${version}-py${python3.pythonVersion}-linux-x86_64.egg";
        hash = "";
      }
    else throw "unsupported system: ${stdenv.hostPlatform.system}";
in
  python3.pkgs.buildPythonPackage rec {
    inherit pname version;
    disabled = !python3.pkgs.isPy38;

    src = python3.pkgs.fetchPypi {
      pname = namePypi;
      inherit version;
      hash = "";
    };

    postPatch = ''
      # sed -i "s/'build_ext': FridaPrebuiltExt//" setup.py
      export HOME=.
      ln -s ${egg} ./${egg.name}
    '';

    meta = with lib; {
      description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers (Python bindings)";
      homepage = "https://www.frida.re";
      license = licenses.wxWindows;
      platforms = ["x86_64-linux"];
    };
  }
