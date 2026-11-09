{ self, ... }: {
  flake.nixosModules.base = {
    imports = with self.nixosModules; [
      nixSettings
      networking
      locale
      keyboard
      fonts
    ];
  };
}
