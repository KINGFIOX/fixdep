{
  description = "fixdep - optimize gcc -MD dependency list for kernel build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem ( system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fixdep = pkgs.stdenv.mkDerivation {
          pname = "fixdep";
          version = "1.0.0";
          src = self;
          nativeBuildInputs = [
            pkgs.meson
            pkgs.ninja
          ];
        };
      in
      {
        packages = {
          default = fixdep;
          inherit fixdep;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.meson
            pkgs.ninja
            pkgs.gcc
          ];
        };
      }
    );
}
