{
  self,
  inputs,
  ...
}:
let
  # This is the Nix base image built from `inputs.nix`.
  nixImageBase =
    pkgs:
    import (inputs.nix.outPath + "/docker.nix") {
      pkgs = pkgs;
      name = "devcontainer-nix-base";
      tag = "latest";

      bundleNixpkgs = false;

      extraPkgs = [ ];

      nixConf = {
        cores = "0";
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
in
{
  perSystem =
    { self', pkgs, ... }:
    {
      # Define the `devcontainer` OCI image.
      packages.devcontainer-image = pkgs.dockerTools.buildLayeredImage {
        fromImage = nixImageBase pkgs;
        name = "devcontainer";
        tag = "latest";

        maxLayers = 104;

        contents = [ self'.packages.bootstrap ];
        config = {
          WorkingDir = "/workspace";
          Volumes = {
            "/workspace" = { };
          };
          User = "root";
        };
      };
    };
}
