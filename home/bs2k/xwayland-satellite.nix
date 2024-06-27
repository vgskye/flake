{
  lib,
  libclang,
  stdenv,
  llvmPackages,
  rustPlatform,
  xcb-util-cursor,
  xorg,
  fetchFromGitHub,
  pkg-config,
}:
let
  owner = "Supreeeme";
in
rustPlatform.buildRustPackage rec {
  pname = "xwayland-satellite";
  version = "0.4";

  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-dwF9nI54a6Fo9XU5s4qmvMXSgCid3YQVGxch00qEMvI=";
  };

  cargoHash = "sha256-nKPSkHbh73xKWNpN/OpDmLnVmA3uygs3a+ejOhwU3yA=";

  nativeBuildInputs = [
    pkg-config
  ];
  
  buildInputs = [
    xorg.libxcb
    xcb-util-cursor
  ];

  # Ensure that the -sys packages can find libclang.
  LIBCLANG_PATH = "${libclang.lib}/lib";

  # Ensure that bindgen can find our headers.
  BINDGEN_EXTRA_CLANG_ARGS = builtins.concatStringsSep " " [
    "-I${stdenv.cc.libc_dev}/include"
    "-I${libclang.lib}/lib/clang/17/include/"
  ];

  doCheck = false;

  meta = with lib; {
    description = "XWayland without Wayland";
    mainProgram = pname;
    homepage = "https://github.com/${owner}/${pname}";
    license = with licenses; [ mpl20 ];
    maintainers = with maintainers; [ vgskye ];
  };
}