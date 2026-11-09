{ self, inputs, ... }:

{
  flake.nixosConfigurations.nixos = 
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with self.nixosModules; [
        hostConfiguration
        base
        desktop
        development
        cli-tools
        ai
        vpn
        braam
      ];
    };

  flake.nixosModules.hostConfiguration = {
    imports = [ /etc/nixos/hardware-configuration.nix ];
    networking.hostName = "nixos";
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    # Preserve the version used when this system was first installed.
    system.stateVersion = "26.05";
  };
}
