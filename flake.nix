{
  description = "John's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, sops-nix, nix-homebrew, homebrew-core, homebrew-cask, stylix, ... }:
    let
      # Supported systems
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper to generate a NixOS configuration
      mkNixos = host: nixpkgs.lib.nixosSystem {
        system = host.system;
        specialArgs = mkSpecialArgs host;
        modules = [
          sops-nix.nixosModules.sops
          self.nixosModules.common.system
          self.nixosModules.common.user
          ./hosts/${host.name}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.mcp-servers self.overlays.zen-browser ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = mkSpecialArgs host;
              users.jrudnik = import ./home/jrudnik/home.nix;
            };
          }
        ];
      };

      # Helper to generate a nix-darwin configuration
      mkDarwin = host: nix-darwin.lib.darwinSystem {
        system = host.system;
        specialArgs = mkSpecialArgs host;
        modules = [
          sops-nix.darwinModules.sops
          self.darwinModules.common.system
          self.darwinModules.common.user
          ./hosts/${host.name}/configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.mcp-servers self.overlays.zen-browser ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = mkSpecialArgs host;
              users.jrudnik = import ./home/jrudnik/home.nix;
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "jrudnik";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
              mutableTaps = false;
            };
          }
          stylix.darwinModules.stylix
          ({ config, ... }: {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
          })
        ];
      };

      # Helper to create specialArgs
      mkSpecialArgs = host: {
        inherit inputs;
        outputs = self.outputs;
        host = host;
      };

    in {
      overlays = import ./overlays;
      nixosModules = {
        common = import ./modules/common;
      } // import ./modules/nixos;
      darwinModules = {
        common = import ./modules/common;
      } // import ./modules/darwin;
      homeManagerModules = import ./modules/home;

      # NixOS configurations
      nixosConfigurations = {
        thinkpad = mkNixos { name = "thinkpad"; system = "x86_64-linux"; };
        "mac-pro-ai" = mkNixos { name = "mac-pro-ai"; system = "aarch64-linux"; };
        "media-server" = mkNixos { name = "media-server"; system = "x86_64-linux"; };
      };

      # nix-darwin configurations
      darwinConfigurations = {
        parsley = mkDarwin { name = "parsley"; system = "aarch64-darwin"; };
      };
    };
}
