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
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
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
            # Configure nixpkgs
            { nixpkgs.config.allowUnfree = true; }
            
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
          ];
        };
      };
    };
}