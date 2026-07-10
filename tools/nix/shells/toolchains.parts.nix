{
  ...
}:
{
  perSystem =
    {
      self',
      pkgs,
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

      git-hooks = [
        {
          git-hooks = {
            enable = true;
            package = pkgs.prek;
            configPath = "./tools/configs/prek/prek.toml";
            # WARNING: Only `pre-commit`, because Git LFS hooks might be ignored since `prek` does not support LFS.
            default_stages = [ "pre-commit" ];
          };

          packages = [
            pkgs.prek
          ];
        }
      ];

      general =
        format
        ++ git-hooks
        ++ [
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
