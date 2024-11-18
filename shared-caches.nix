{ pkgs, ... }:
{
  nix = {
    settings = {
      substituters = [
        "https://new-attic.is-quite.gay/skye"
      ];
      trusted-public-keys = [
        "skye:WsJ38m3yiiguyBpk3wbRzltofdj2mClCZrzNA5PbxH8="
      ];
      netrc-file = pkgs.stdenv.mkDerivation {
        name = "netrc";
        outputHashMode = "flat";
        outputHashAlgo = "sha256";
        outputHash = "9e5f3cccb6a353565a15949cdfa90253b08262c6329394fdc66f1005dfb64a34";

        unpackPhase = ''
          echo :3c
          exit 1
        '';
      };
    };
  };
}