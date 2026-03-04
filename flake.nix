{
  description = "fixdep - optimize gcc -MD dependency list for kernel build";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    mkPkgs = system: import (nixpkgs.outPath) { inherit system; };
    # 包含所有文件（含未 git add 的），便于 nix build 能用到 meson.build 等
    src = builtins.path { path = ./.; name = "fixdep-src"; filter = _: _: true; };
    mkFixdep = pkgs: pkgs.stdenv.mkDerivation {
      pname = "fixdep";
      version = "1.0.0";
      inherit src;
      dontConfigure = true;
      nativeBuildInputs = [ pkgs.meson pkgs.ninja ];
      buildPhase = ''
        meson setup build --prefix $out
        meson compile -C build
      '';
      installPhase = ''
        meson install -C build
      '';
    };
  in {
    packages = forAllSystems (system: let pkgs = mkPkgs system; in {
      default = mkFixdep pkgs;
      fixdep = mkFixdep pkgs;
    });

    devShells = forAllSystems (system: let pkgs = mkPkgs system; in {
      default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.meson
          pkgs.ninja
          pkgs.gcc
        ];
      };
    });
  };
}
