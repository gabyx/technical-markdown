{
  ...
}:
{
  settings.processes.watch-html = {
    command = "just nix::develop default just watch html";
  };

  settings.processes.watch-pdf = {
    command = "just nix::develop default just watch pdf";
  };

  settings.processes.watch-native = {
    command = "just nix::develop default just watch native";
  };

  settings.processes.view-html = {
    command = "just nix::develop default just main view-html";
  };
}
