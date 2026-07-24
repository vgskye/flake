{ pkgs, ... }:
{
  nix = {
    settings = {
      substituters = [
        # "https://skyettic.fly.dev/fly-skye"
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
        outputHash = "0cb68202b9b24fc46dbfeba7c8a287f2f37f3b5c079a7a6654d067899bb62039";

        unpackPhase = ''
          echo :3c
          exit 1
        '';
      };
    };
  };
}