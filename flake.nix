{
  description = "A Haskell package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs = inputs :
    inputs.flake-utils.lib.eachDefaultSystem (system:
     let pkgs = inputs.nixpkgs.legacyPackages.${system};
         haskell = pkgs.haskell.packages.ghc98;
     in
  {
    packages = {
      haskellProject = haskell.callCabal2nix "myProject" ./. {};
    };
    checks = {
      fmt = pkgs.runCommand "format" {} ''
        set -o errexit
        ${pkgs.ormolu}/bin/ormolu --mode check ${exe/Main.hs}
        mkdir $out
      '';
    };
    devShells = {
      default = pkgs.mkShell {
        packages = [
          pkgs.cabal-install
          pkgs.ormolu
          pkgs.entr
          (haskell.ghc.withPackages (p: inputs.self.packages.${system}.haskellProject.buildInputs))
        ];
      };
    };
  });
}
