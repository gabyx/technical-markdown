{
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      toolchains.pandoc = [
        {
          packages = [
            pkgs.nodejs-slim_26
            pkgs.pnpm
            pkgs.browser-sync

            pkgs.pandoc
            pkgs.haskellPackages.citeproc
            pkgs.haskellPackages.pandoc-crossref
            pkgs.lessc

            (pkgs.texliveFull.withPackages (p: [
              p.multirow
            ]))

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
