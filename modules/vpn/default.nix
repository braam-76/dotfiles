{ self, ... }: {
  flake.nixosModules.vpn = {
    imports = with self.nixosModules; [
      throne
      happ
    ];
  };
}
