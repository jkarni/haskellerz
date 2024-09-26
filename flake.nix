{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { nixpkgs, self } :
  let pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.myHaskellPackage =
      pkgs.haskell.packages.ghc98.callCabal2nix "myPackage" ./. {} ;
    devShells.x86_64-linux.myHaskellPackage =
      pkgs.mkShell {
        packages = [
          pkgs.ormolu
          pkgs.cabal-install
          (pkgs.haskell.packages.ghc98.ghcWithPackages
            (p : self.packages.x86_64-linux.myHaskellPackage.buildInputs))
        ];
      };
    checks.x86_64-linux.format =
      pkgs.runCommand "" {} ''
        set -o errexit
        mkdir $out
        ${pkgs.ormolu}/bin/ormolu --mode check ${./exe/Main.hs}
      '';

  };
}
