{
  description = "my_tool package and its devShell";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      poetry2nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        my_tool =
          { poetry2nix, lib }:
          poetry2nix.mkPoetryApplication {
            projectDir = self;
            overrides = poetry2nix.overrides.withDefaults (
              final: super:
              lib.mapAttrs
                (
                  attr: systems:
                  super.${attr}.overridePythonAttrs (old: {
                    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ map (a: final.${a}) systems;
                  })
                )
                {
                  # https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
                  # package = [ "setuptools" ];
                }
            );
          };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            poetry2nix.overlays.default
            (final: _: {
              my_tool = final.callPackage my_tool { };
            })
          ];
        };
      in
      {
        packages.default = pkgs.my_tool;
        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [ pkgs.my_tool ];
            packages = with pkgs; [
              ruff
              poetry

              nil
              nixfmt-rfc-style
            ];
          };

          poetry = pkgs.mkShell {
            packages = [ pkgs.poetry ];
          };
        };
        legacyPackages = pkgs;
      }
    );
}