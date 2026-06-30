{
  config,
  lib,
  pkgs,
  ...
}:
{
  settings.processes.hello = {
    command = "${lib.getExe pkgs.cowsay}";
  };
}
