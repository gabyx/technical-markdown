{
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      toolchains.python = [
        {
          packages = [
            pkgs.pyright
            pkgs.ruff
          ];

          languages.python = {
            enable = true;

            package = pkgs.python315.withPackages (p: [
              p.panflute
              p.pyyaml
              p.commentjson
            ]);

            uv = {
              enable = true;
              package = pkgs.uv;
              sync = {
                enable = false;
              };
            };
          };

          env = {
            RUFF_CACHE_DIR = ".output/cache/ruff";
          };
        }
      ];
    };
}
