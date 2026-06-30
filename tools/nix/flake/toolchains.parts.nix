{
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  # Creates a `perSystem.toolchains.<key> = [ <devenvModule> ]` option.
  options.perSystem = mkPerSystemOption (
    {
      lib,
      ...
    }:
    {
      options.toolchains = lib.mkOption {
        description = "Attrset of toolchain definitions keyed by toolchain name, where each value is a list of devenv modules.";
        default = { };
        type = lib.types.attrsOf (lib.types.listOf lib.types.deferredModule);
      };
    }
  );
}
