{ substituteAll
, runtimeShell
, coreutils
, gnused
, gnugrep
, jq
, util-linux
, nix
, lib
, nixosTests
, installShellFiles
, nix-output-monitor
, pkgs
}:
let
  fallback = import "${pkgs.path}/nixos/modules/installer/tools/nix-fallback-paths.nix";
in
substituteAll {
  name = "nomos-rebuild";
  src = ./nomos-rebuild.sh;
  dir = "bin";
  isExecutable = true;
  inherit runtimeShell nix;
  nix_x86_64_linux = fallback.x86_64-linux;
  nix_i686_linux = fallback.i686-linux;
  nix_aarch64_linux = fallback.aarch64-linux;
  path = lib.makeBinPath [ coreutils gnused gnugrep jq util-linux nix-output-monitor ];
  nativeBuildInputs = [
    installShellFiles
  ];

  # run some a simple installer tests to make sure nixos-rebuild still works for them
  passthru.tests = {
    install-bootloader = nixosTests.nixos-rebuild-install-bootloader;
    simple-installer = nixosTests.installer.simple;
    specialisations = nixosTests.nixos-rebuild-specialisations;
  };

  meta = {
    description = "like nixos-rebuild, but wraps itself in nix-output-monitor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vgskye ];
    mainProgram = "nomos-rebuild";
  };
}