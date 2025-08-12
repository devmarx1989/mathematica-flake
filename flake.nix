{
  description = "Wolfram Mathematica 14.3 (unfree) flake";

  inputs = {
    # Pick your preferred channel; 24.05 or unstable both work.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            (final: prev: {
              mathematica-14_3 = final.callPackage ./default.nix {
                # Pass-throughs that your existing default.nix expects:
                # cudaPackages from pkgs; you can also force-enable/disable cudaSupport here if needed.
                cudaPackages = final.cudaPackages;
                # Choose language; "en" matches the versions.nix entry we add below.
                lang = "en";
                # Pin the version we want explicitly so default.nix doesn't have to guess.
                version = "14.3.0";
              };

              # Convenience alias
              mathematica = final.mathematica-14_3;
            })
          ];
        };
      in {
        packages.default = pkgs.mathematica-14_3;
        packages.mathematica-14_3 = pkgs.mathematica-14_3;

        # Handy launcher (opens the desktop app if your generic.nix installs it in PATH)
        apps.default = {
          type = "app";
          program = "${pkgs.mathematica-14_3}/bin/mathematica";
        };
      });
}

