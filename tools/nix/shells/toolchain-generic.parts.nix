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
          packages = with pkgs; [
            nodejs-slim_26
            pnpm
            browser-sync

            pandoc
            haskellPackages.citeproc
            haskellPackages.pandoc-crossref

            watchman
            python315Packages.pywatchman

            process-compose
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
