{
  description = "my nix configs";
  inputs = {
    nixpkgs-unwrapped = {url = "github:NixOS/nixpkgs/nixos-23.11";};
    nixpkgs = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
    };
    nixpkgs-unstable-unwrapped = {url = "github:NixOS/nixpkgs/nixos-unstable";};
    nixpkgs-unstable = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs-unstable-unwrapped";
    };
    impermanence = {url = "github:nix-community/impermanence";};
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };
    comma = {
      url = "github:nix-community/comma/v1.2.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:Stonks3141/ctp-nix";
    };
    quiclime = {
      url = "git+https://git.skye.vg/me/quiclime.git";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
    };
    babysitter = {
      url = "github:vgskye/babysitter";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
    };
    packwiz = {
      url = "github:packwiz/packwiz";
      inputs.nixpkgs.follows = "nixpkgs-unwrapped";
    };
    catppuccin-vsc = {
      url = "github:catppuccin/vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = {
    self,
    nixpkgs-unwrapped,
    nixpkgs,
    nixpkgs-unstable-unwrapped,
    nixpkgs-unstable,
    impermanence,
    home-manager,
    rust-overlay,
    nix-alien,
    nur,
    comma,
    vscode-server,
    agenix,
    prismlauncher,
    catppuccin,
    quiclime,
    babysitter,
    lanzaboote,
    nixinate,
    packwiz,
    catppuccin-vsc,
    flake-utils,
  }: let
    tailscalepkgmodule = {pkgsUnstable, ...}: {
      services.tailscale.package = pkgsUnstable.tailscale;
    };
    nixinateModule = buildOn: {config, ...}: {
      _module.args.nixinate = {
        host = config.networking.hostName;
        sshUser = "root";
        buildOn = buildOn;
        substituteOnTarget = true;
        hermetic = false;
      };
    };
    telegrafModule = {config, ...}: {
      age.secrets.telegraf-key = {
        file = ./secrets/telegraf-key.age;
        mode = "400";
        owner = "telegraf";
      };
      services.telegraf = {
        enable = true;
        extraConfig = {
          inputs = {
            cpu = {
              percpu = true;
              totalcpu = true;
              collect_cpu_time = false;
              report_active = true;
              core_tags = true;
            };
            processes = {};
            net = {};
            netstat = {};
            mem = {};
          };
          outputs.influxdb_v2 = {
            urls = ["http://overseer:8086"];
            token = "$INFLUXDB_TOKEN";
            organization = "skyevg";
            bucket = "skyevg";
          };
        };
        environmentFiles = [
          config.age.secrets.telegraf-key.path
        ];
      };
    };
  in {
    apps = nixinate.nixinate.x86_64-linux self;
    nixosConfigurations = let
      e4mcFn = region: provider: arch:
        nixpkgs.lib.nixosSystem rec {
          system = "${arch}-linux";
          modules = [
            ./e4mc/configuration.nix
            ./e4mc/hardware-configuration-${provider}.nix
            tailscalepkgmodule
            telegrafModule
            agenix.nixosModules.default
            quiclime.nixosModules.default
            (nixinateModule "remote")
            {
              nixpkgs.hostPlatform = system;
            }
          ];
          specialArgs = {
            inherit region;

            pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
          };
        };
      noInstantiate = system: {
        nixpkgs.pkgs = nixpkgs.legacyPackages.${system};
      };
    in {
      e4mc-jp = e4mcFn "jp" "linode" "x86_64";
      e4mc-oc = e4mcFn "oc" "linode" "x86_64";
      e4mc-eu = e4mcFn "eu" "hetzner" "aarch64";
      e4mc-us = e4mcFn "us" "hetzner-mbr" "x86_64";
      chell = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./chell/configuration.nix
          impermanence.nixosModules.impermanence
          tailscalepkgmodule
          agenix.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          {
            nix.registry = {
              nixpkgs.flake = nixpkgs-unwrapped;
              nixpkgsUnstable.flake = nixpkgs-unstable-unwrapped;
            };
          }
        ];
        specialArgs = {
          pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        };
      };
      jenny = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./jenny/configuration.nix
          tailscalepkgmodule
          telegrafModule
          {
            services.telegraf.extraConfig.inputs.docker.endpoint = "unix:///var/run/docker.sock";
            users.users.telegraf.extraGroups = ["docker"];
          }
          agenix.nixosModules.default
          (nixinateModule "remote")
          vscode-server.nixosModules.default
          ({
            config,
            pkgs,
            ...
          }: {
            services.vscode-server.enable = true;
          })
        ];
        specialArgs = {
          pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        };
      };
      bridget = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          ./bridget/configuration.nix
          tailscalepkgmodule
          telegrafModule
          {
            services.telegraf.extraConfig.inputs.docker.endpoint = "unix:///var/run/docker.sock";
            users.users.telegraf.extraGroups = ["docker"];
          }
          agenix.nixosModules.default
          (nixinateModule "remote")
        ];
        specialArgs = {
          pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        };
      };
      alex = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./alex/configuration.nix
          agenix.nixosModules.default
          babysitter.nixosModules.default
          telegrafModule
          tailscalepkgmodule
          (nixinateModule "remote")
        ];
        specialArgs = {
          pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        };
      };
      thorley = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          ./thorley/configuration.nix
          agenix.nixosModules.default
          tailscalepkgmodule
          {
            nix.registry = {
              nixpkgs.flake = nixpkgs-unwrapped;
              nixpkgsUnstable.flake = nixpkgs-unstable-unwrapped;
            };
          }
        ];
        specialArgs = {
          pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        };
      };
    };
    homeConfigurations = let
      configFn = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home/bs2k/home.nix
            catppuccin.homeManagerModules.catppuccin
          ];

          extraSpecialArgs = {
            inherit
              rust-overlay
              nix-alien
              comma
              nur
              prismlauncher
              agenix
              packwiz
              catppuccin-vsc
              ;
            pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
            pkgsAmd64 = nixpkgs.legacyPackages.x86_64-linux;
          };

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    in {
      bs2k = configFn "x86_64-linux";
      bs2k-arm = configFn "aarch64-linux";
    };
  };
  nixConfig = {
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };
}
