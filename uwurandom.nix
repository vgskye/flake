{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
}:
stdenv.mkDerivation rec {
  name = "uwurandom-${version}-${kernel.version}";
  version = "1c7e8e7f23ce5b3f8e01b60140c810c60db81062";

  src = fetchFromGitHub {
    owner = "valadaptive";
    repo = "uwurandom";
    rev = "${version}";
    sha256 = "sha256-9y5ungZAIvMT5CR8RbizWnKMoSZUo9G2+ZXsRcQDbFQ=";
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
