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

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, caelestia-shell, ... }:
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
          home-manager.sharedModules = [
            caelestia-shell.homeManagerModules.default
            # Use shell-only package (no caelestia-cli) to avoid fetching the CLI flake input.
            # caelestia CLI subcommands still work via the shell binary; this just skips the
            # standalone CLI overlay. Revisit if caelestia-cli becomes reliably fetchable.
            { programs.caelestia.package = caelestia-shell.packages.x86_64-linux.caelestia-shell; }
          ];
          home-manager.users.pilot = import ./modules/home;
        }
      ];
    };
  };
}
