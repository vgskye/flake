default:
    echo "what are you gonna do"

home-manager:
    home-manager switch --flake ~/nix-confs#bs2k
hm: home-manager

nixos-rebuild:
    sudo nixos-rebuild switch --flake ~/nix-confs/
rebuild: nixos-rebuild

self: home-manager nixos-rebuild

deploy hostname:
    nix run .#apps.nixinate.{{hostname}}

e4mc hostname: (deploy "e4mc-"+hostname)

e4mc-all: (e4mc "us") (e4mc "na") (e4mc "eu") (e4mc "de") (e4mc "oc") (e4mc "jp") (e4mc "sg") (e4mc "ap")
deploy-all: e4mc-all (deploy "bridget") (deploy "jenny")

bump:
    nix flake update