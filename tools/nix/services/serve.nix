{
  config,
  lib,
  pkgs,
  ...
}:
{
  settings.processes.serve = {
    command = "${lib.getExe pkgs.cowsay}";
  };
}
