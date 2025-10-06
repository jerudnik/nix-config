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
    
    # Declarative homebrew management
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    
    # Homebrew tap sources
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    
    # System-wide theming framework
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # MCP servers - Nix-based configuration framework for MCP servers
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, stylix, zen-browser, mcp-servers-nix, ... }:
    let
      system = "aarch64-darwin";
    in {
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      
      # Custom NixOS/nix-darwin modules
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeManagerModules = import ./modules/home;
      
      # Create specialArgs that all modules can access
      _specialArgs = {
        inherit inputs;
        outputs = self.outputs;
      };

      # nix-darwin configurations
      # Accessible via 'darwin-rebuild --flake .#parsley'
      darwinConfigurations = {
        parsley = nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = self._specialArgs;
          modules = [
            # Configure nixpkgs - overlays and unfree packages
            ({ lib, ... }: {
              nixpkgs = {
                overlays = [ self.overlays.mcp-servers ];
                config.allowUnfreePredicate = pkg:
                  lib.elem (lib.getName pkg) [ 
                    "raycast" 
                    "warp-terminal"
                    "claude"
                    "gh-copilot"  # GitHub Copilot CLI
                  ];
              };
            })
            
            # Import the host configuration
            ./hosts/parsley/configuration.nix
            
            # Make home-manager available to the system
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = self._specialArgs;
                users.jrudnik = import ./home/jrudnik/home.nix;
              };
            }
            
            # Declarative homebrew management
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon: Also install Homebrew under Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = "jrudnik";

                # Declarative tap management
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };

                # Enable fully-declarative tap management
                mutableTaps = false;
              };
            }
            
            # Align homebrew taps config with nix-homebrew
            ({ config, ... }: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
            
            # System-wide theming with Stylix
            stylix.darwinModules.stylix
          ];
        };
      };
    };
}