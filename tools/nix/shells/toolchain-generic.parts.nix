{
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      toolchains.generic = [
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

        {
          packages = [
            pkgs.nodejs-slim_26
            pkgs.pnpm
            pkgs.browser-sync

            pkgs.pandoc
            pkgs.haskellPackages.citeproc
            pkgs.haskellPackages.pandoc-crossref
            pkgs.lessc

            pkgs.texliveMedium
            pkgs.texlivePackages.multirow

            pkgs.watchman
            pkgs.python315Packages.pywatchman

            pkgs.process-compose
          ];

          # Disable all process-compose stuff.
          # Set to native manager to not have PC_ env. variables.
          process.manager.implementation = "native";

          env = {
            PC_SOCKET_PATH = lib.mkForce ".output/process-compose/pc.sock";
          };

          enterShell = ''
            just setup
          '';
        }
      ];
    };
}
