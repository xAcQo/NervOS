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
        # Hyprland: wired in Plan 01-02
        # Stylix + home-manager: wired in Plan 01-03
      ];
    };
  };
}
