{ self, ... }: {
  flake.nixosModules.ai = {
    imports = [ self.nixosModules.pi-code ];
  };
}
