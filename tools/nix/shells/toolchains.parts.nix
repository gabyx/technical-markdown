{
  ...
}:
{
  perSystem =
    {
      self',
      ...
    }:
    let
      format = [
        {
          packages = [
            self'.packages.treefmt
          ];
        }
      ];

      changelog = [
        {
          packages = [
            self'.packages.generate-changelog
          ];
        }
      ];

      general = format ++ [
        {
          packages = [
            self'.packages.bootstrap
          ];
        }
      ];
    in
    {
      # Define some toolchains.
      toolchains = {
        inherit format changelog general;
      };
    };
}
