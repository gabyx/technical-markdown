{
  lib,
  inputs,
  ...
}:
{
  perSystem = { config, ... }: {
    process-compose."serve" = { ... }: {
      imports = [
        inputs.services-flake.processComposeModules.default
        ./all.nix
      ];

      cli.options = {
        keep-project = true;
        unix-socket = "./.output/process-compose/pc.sock";
      };

      settings = {
        log_level = "debug";
        log_location = ".output/process-compose/log.txt";
        ordered_shutdown = true;
      };

      defaults.processSettings = { name, ... }: {
        namespace = lib.mkDefault "serve";
        availability.restart = lib.mkDefault "on_failure";
        availability.max_restarts = lib.mkDefault 3;
        log_location = ".output/process-compose/log/${name}.log";
      };
    };

    # To inspect the process-compose nix settings.
    legacyPackages = {
      technical-markdown = {
        serve = config.process-compose.serve;
      };
    };
  };

}
