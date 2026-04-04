{
  description = "smaws";

  inputs = {
    dune2nix.url = "github:anteriorcore/dune2nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { flake-parts, ... }@inputs:
    let
      flakeMod =
        { ... }:
        {
          perSystem =
            { pkgs, system, ... }:
            let
              dune2nix = pkgs.callPackage inputs.dune2nix.lib.dune2nix { };
            in
            {
              _module.args.pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [
                  inputs.dune2nix.overlays.dune
                ];
              };
              packages.default = dune2nix.mkDuneProject {
                src = ./.;
                nativeBuildInputs = [
                  pkgs.pkg-config
                ];
                buildInputs = [
                  pkgs.openssl
                ];
                doCheck = true;
              };
            };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        flakeMod
      ];
    };
}
