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
      inherit (self) outputs;
      system = "aarch64-darwin";
      
      # Create pkgs with our configuration
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      # Create specialArgs that all modules can access
      specialArgs = {
        inherit inputs outputs;
      };

    in {
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      
      # Custom NixOS/nix-darwin modules
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeManagerModules = import ./modules/home;

      # nix-darwin configurations
      # Accessible via 'darwin-rebuild --flake .#parsley'
      darwinConfigurations = {
        parsley = nix-darwin.lib.darwinSystem {
          inherit system specialArgs;
          modules = [
            # Import the host configuration
            ./hosts/parsley/configuration.nix
            
            # Make home-manager available to the system
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = specialArgs;
                users.jrudnik = import ./home/jrudnik/home.nix;
              };
            }
          ];
        };
      };

      # Standalone home-manager configurations  
      # Accessible via 'home-manager --flake .#jrudnik@parsley'
      homeConfigurations = {
        "jrudnik@parsley" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = specialArgs;
          modules = [ ./home/jrudnik/home.nix ];
        };
      };
    };
}