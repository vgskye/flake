{
  nix = {
    settings = {
      substituters = [
        "https://vgskye.cachix.org"
        "https://new-attic.is-quite.gay/skye"
        "https://attic.is-quite.gay/skye"
      ];
      trusted-public-keys = [
        "vgskye.cachix.org-1:DjgwQYRfjI1/w7exE54FCtfe4ZKCYEhWgJXmcHoo944="
        "skye:r1L1YycTKOoOI/HDFGeNeZr29jf/rui0nCblvn9C/d4="
        "skye:WsJ38m3yiiguyBpk3wbRzltofdj2mClCZrzNA5PbxH8="
      ];
    };
  };
}