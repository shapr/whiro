{
  description = "My machines flakes";
  inputs = {
    srvos.url = "github:nix-community/srvos";
    # Use the version of nixpkgs that has been tested to work with SrvOS
    # Alternatively we also support the latest nixos release and unstable
    nixpkgs.follows = "srvos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { self, nixpkgs, srvos, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: rec {
      nixosConfigurations.whiro = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs.inputs = inputs;
        modules = [
          srvos.nixosModules.hardware-hetzner-cloud
          srvos.nixosModules.mixins-terminfo
          srvos.nixosModules.mixins-trusted-nix-caches
          srvos.nixosModules.server
          # Finally add your configuration here
          ./configuration.nix
        ];
      };
      apps = rec {
        default = test;
        test = {
          type = "app";
          program = "${nixosConfigurations.whiro.config.system.build.vm}/bin/run-nixos-vm";
        };
      };
    });
}
