{
  self,
  ...
}:
{
  perSystem =
    {
      self',
      config,
      ...
    }:
    let
      args = config.allModuleArgs; # See https://flake.parts/module-arguments#obtaining-all-module-arguments
      toolchains = config.toolchains;
    in
    {
      devShells.default = self.lib.shell.mkShell {
        inherit (args) system;
        modules =
          toolchains.general
          ++ toolchains.pandoc
          ++ toolchains.python
          ++ [
            {
              env = {
                TECHMD_INSIDE_SHELL = true;
              };
            }
          ];
      };

      devShells.format = self.lib.shell.mkShell {
        inherit (args) system;
        modules = toolchains.format;
      };

      # The CI shell is the same as the default.
      devShells.ci = self'.devShells.default;
    };
}
