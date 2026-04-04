{ ... }:
{
  perSystem.treefmt = {
    programs = {
      # keep-sorted start block=yes
      keep-sorted.enable = true;
      nixfmt = {
        enable = true;
        strict = true;
      };
      # keep-sorted end
    };
    settings.global.excludes = [ "api-models-aws" ];
  };
}
