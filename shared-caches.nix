{ pkgs, ... }:
{
  nix = {
    settings = {
      substituters = [
        "https://skyettic.fly.dev/fly-skye"
        "https://new-attic.is-quite.gay/skye"
      ];
      trusted-public-keys = [
        "skye:WsJ38m3yiiguyBpk3wbRzltofdj2mClCZrzNA5PbxH8="
        "fly-skye:aNOTise2yMX8juDWf2HgSK0g6KEAv8aFIdJnD/Nun2E="
      ];
      netrc-file = pkgs.stdenv.mkDerivation {
        name = "netrc";
        outputHashMode = "flat";
        outputHashAlgo = "sha256";
        outputHash = "dd610199ead191c54f0dc1ed8de9871e3d01a3f8323076b40651492061f9da4e";

        unpackPhase = ''
          echo :3c
          exit 1
        '';
      };
    };
  };
}