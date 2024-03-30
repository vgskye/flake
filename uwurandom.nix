{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
}:
stdenv.mkDerivation rec {
  name = "uwurandom-${version}-${kernel.version}";
  version = "fb9d5ff0e650b7240ab6b6033738d6309d417822";

  src = fetchFromGitHub {
    owner = "valadaptive";
    repo = "uwurandom";
    rev = "${version}";
    sha256 = "sha256-1WGK1vEp/ZXB/o2QsMDi923rnR/9D7wK+CVlogjRZMk=";
  };

  sourceRoot = "source";
  hardeningDisable = ["pic" "format"]; # 1
  nativeBuildInputs = kernel.moduleBuildDependencies; # 2

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}" # 3
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" # 4
    "INSTALL_MOD_PATH=$(out)" # 5
  ];

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}
    cp uwurandom.ko $out/lib/modules/${kernel.modDirVersion}
  '';

  meta = with lib; {
    description = "Like /dev/urandom, but objectively better";
    homepage = "https://github.com/valadaptive/uwurandom";
    license = [licenses.gpl2 licenses.mit];
    # maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
  };
}
