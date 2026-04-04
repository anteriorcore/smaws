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
  };

  outputs =
    { flake-parts, ... }@inputs:
    let
      flakeMod =
        { lib, ... }:
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
                awsApiModels = inputs.aws-api-models;
                postPatch = ''
                  if [[ ! -d api-models-aws ]]; then
                    cp -r --no-preserve=mode,ownership "$awsApiModels" api-models-aws
                  fi
                '';
                nativeBuildInputs = with pkgs; [
                  pkg-config
                  writableTmpDirAsHomeHook
                ];
                buildInputs = with pkgs; [
                  openssl
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
