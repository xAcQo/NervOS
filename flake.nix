{
  description = "NervOS - Evangelion-themed NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nervos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self; };
      modules = [
        ./hosts/nervos
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.pilot = import ./modules/home;
        }
      ];
    };
  };
}
