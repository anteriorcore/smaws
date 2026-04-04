{
  description = "smaws";

  inputs = {
    dune2nix.url = "github:anteriorcore/dune2nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    aws-api-models = {
      # This is the version pinned in the submodule.
      url = "github:aws/api-models-aws/896693ac2e1c0efd9d03488109601e0c66ba7d35";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        ./nix/misc.nix
        ./nix/treefmt.nix
        inputs.treefmt-nix.flakeModule
      ];
    };
}
