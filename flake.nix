{
  description = "A Haskell package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
