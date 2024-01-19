{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
}:
stdenv.mkDerivation rec {
  name = "uwurandom-${version}-${kernel.version}";
  version = "55546c295d08746da01c6c817717181cd9c59504";

  src = fetchFromGitHub {
    owner = "valadaptive";
    repo = "uwurandom";
    rev = "${version}";
    sha256 = "sha256-RKLlzpiwigS+xfVoW8E0/79B45ziiP76nZPQoXoLtcM=";
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
