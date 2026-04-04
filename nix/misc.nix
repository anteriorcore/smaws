{ inputs, lib, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      system,
      ...
    }:
    let
      dune2nix = pkgs.callPackage inputs.dune2nix.lib.dune2nix { };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.dune2nix.overlays.dune ];
      };
      packages.default = dune2nix.mkDuneProject {
        src = ../.;
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
        buildInputs = with pkgs; [ openssl ];
        doCheck = true;
        meta.license = lib.licenses.gpl3Only;
      };
      checks = self'.packages;
    };
}
