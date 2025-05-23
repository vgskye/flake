{ writeShellApplication, python3, vboot_reference, ubootTools, dtc, depthchargectl }:
writeShellApplication {
  name = "mkdepthcharge";

  runtimeInputs = [ python3 vboot_reference ubootTools dtc depthchargectl ];

  text = ''
    python3 ${./mkdepthcharge.py} "$@"
  '';
}