{
  description = "A Haskell package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    garnix-lib.url = "github:garnix-io/garnix-lib";
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
  })
  // {
    nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.garnix-lib.outputs.nixosModules.garnix
        ({pkgs, ... } : {
          nixpkgs.hostPlatform = "x86_64-linux";
          garnix.server.enable = true;

          networking.firewall.allowedTCPPorts = [ 80 443 ];
          virtualisation.vmVariant = {
            services.getty.autologinUser = "root";
          };

          environment.systemPackages = [
            pkgs.tree
          ];

          system.stateVersion = "24.11";

          systemd.services.myServer = {
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            requires = [ "network-online.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${inputs.self.packages.x86_64-linux.haskellProject}/bin/haskellerz 80";
            };
          };
        })
      ];
    };
  }
  ;
}
